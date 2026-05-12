"""Flask backend for Roomantic roommate matching app."""

import uuid
import datetime
import queue
import sqlite3
import threading
from typing import Dict, Set

from flask import Flask, request, jsonify, Response, stream_with_context
from flask_cors import CORS

import db
from models import User, RoommateProfile, profile_to_dict, classify_persona
from matcher import rank_matches, best_pairings
from auth import hash_password, verify_password, create_token, login_required

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# In-memory SSE queues: user_uid -> [queue]
_SSE_QUEUES: Dict[str, list] = {}
_SSE_LOCK = threading.Lock()


def _add_sse_queue(user_uid: str, q: queue.Queue):
    with _SSE_LOCK:
        _SSE_QUEUES.setdefault(user_uid, []).append(q)


def _remove_sse_queue(user_uid: str, q: queue.Queue):
    with _SSE_LOCK:
        queues = _SSE_QUEUES.get(user_uid, [])
        if q in queues:
            queues.remove(q)
        if not queues:
            _SSE_QUEUES.pop(user_uid, None)


def broadcast_message(user_uid: str, event_type: str, data: dict):
    with _SSE_LOCK:
        queues = _SSE_QUEUES.get(user_uid, [])
        for q in list(queues):
            try:
                q.put({"event": event_type, "data": data}, block=False)
            except queue.Full:
                pass


def generate_uid() -> str:
    return str(uuid.uuid4())


def _now() -> str:
    return datetime.datetime.utcnow().isoformat() + "Z"


# ─── Auth ────────────────────────────────────────────────────────────────

@app.route("/api/auth/register", methods=["POST"])
def register():
    data = request.get_json(force=True)
    login_id = data.get("login_id", "").strip()
    student_id = data.get("student_id", "").strip()
    password = data.get("password", "")
    name = data.get("name", "").strip()
    is_enrolled = data.get("is_enrolled", True)
    school_name = data.get("school_name", "").strip() or data.get("school", "").strip()
    region_name = data.get("region_name", "").strip() or data.get("region", "").strip()

    # Frontend compatibility: student_id doubles as login_id
    if not login_id and student_id:
        login_id = student_id

    if not login_id or not password or not name:
        return jsonify({"error": "ID, 비밀번호, 이름은 필수입니다."}), 400

    if db.get_user_by_login_id(login_id):
        return jsonify({"error": "이미 등록된 ID입니다."}), 409

    user = User(
        login_id=login_id,
        student_id=student_id,
        password_hash=hash_password(password),
        name=name,
        is_enrolled=1 if is_enrolled else 0,
        school_name=school_name,
        region_name=region_name,
    )
    db.save_user(user)
    token = create_token(user.uid, user.login_id, user.name, user.student_id)
    return jsonify({
        "token": token,
        "user": {"uid": user.uid, "login_id": user.login_id, "student_id": user.student_id, "name": user.name},
    }), 201


@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json(force=True)
    login_id = data.get("login_id", "").strip()
    password = data.get("password", "")

    user = db.get_user_by_login_id(login_id)
    if not user or not verify_password(password, user.password_hash):
        return jsonify({"error": "ID 또는 비밀번호가 올바르지 않습니다."}), 401

    token = create_token(user.uid, user.login_id, user.name, user.student_id)
    return jsonify({
        "token": token,
        "user": {"uid": user.uid, "login_id": user.login_id, "student_id": user.student_id, "name": user.name},
    })


@app.route("/api/me", methods=["GET"])
@login_required
def me():
    payload = request.current_user
    user = db.get_user_by_uid(payload["user_uid"])
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify({
        "uid": user.uid,
        "login_id": user.login_id,
        "student_id": user.student_id,
        "name": user.name,
        "is_enrolled": user.is_enrolled,
        "school_name": user.school_name,
        "region_name": user.region_name,
    })


# ─── Profile ─────────────────────────────────────────────────────────────

@app.route("/api/profile", methods=["GET"])
@login_required
def get_profile():
    payload = request.current_user
    profile = db.get_profile_by_user_uid(payload["user_uid"])
    if not profile:
        return jsonify({"error": "설문조사를 먼저 작성해주세요."}), 404
    return jsonify(profile_to_dict(profile))


@app.route("/api/profile", methods=["POST"])
@login_required
def post_profile():
    payload = request.current_user
    data = request.get_json(force=True)
    user = db.get_user_by_uid(payload["user_uid"])
    if not user:
        return jsonify({"error": "User not found"}), 404

    existing = db.get_profile_by_user_uid(payload["user_uid"])
    uid = existing.uid if existing else None

    # 이름/학번은 User에서 자동 연동
    profile = RoommateProfile(
        uid=uid or generate_uid(),
        user_uid=payload["user_uid"],
        name=user.name,
        student_id=user.student_id,
        birth_year=data.get("birth_year", 2005),
        college=data.get("college", ""),
        department=data.get("department", ""),
        dorm_duration=data.get("dorm_duration", 1),
        home_visit_cycle=data.get("home_visit_cycle", 2),
        perfume=data.get("perfume", 0),
        indoor_scent_sensitivity=data.get("indoor_scent_sensitivity", 3),
        alcohol_tolerance=data.get("alcohol_tolerance", 2.5),
        alcohol_frequency=data.get("alcohol_frequency", 2),
        drunk_habit=data.get("drunk_habit", 0),
        gaming_hours_per_week=data.get("gaming_hours_per_week", 10),
        speaker_use=data.get("speaker_use", 0),
        exercise=data.get("exercise", 0),
        bedtime=data.get("bedtime", 23),
        wake_time=data.get("wake_time", 8),
        sleep_habit=data.get("sleep_habit", 0),
        sleep_sensitivity=data.get("sleep_sensitivity", 3),
        alarm_strength=data.get("alarm_strength", 3),
        sleep_light=data.get("sleep_light", 0),
        snoring=data.get("snoring", 0),
        shower_duration=data.get("shower_duration", 15),
        shower_time=data.get("shower_time", 22),
        shower_cycle=data.get("shower_cycle", 2),
        cleaning_cycle=data.get("cleaning_cycle", 7),
        ventilation=data.get("ventilation", 1.0),
        hairdryer_in_bathroom=data.get("hairdryer_in_bathroom", 1),
        toilet_paper_share=data.get("toilet_paper_share", 1),
        indoor_eating=data.get("indoor_eating", 0),
        smoking=data.get("smoking", 0),
        temperature_pref=data.get("temperature_pref", 3),
        indoor_call=data.get("indoor_call", 0),
        bug_handling=data.get("bug_handling", 3),
        laundry_cycle=data.get("laundry_cycle", 7),
        drying_rack=data.get("drying_rack", 1),
        fridge_use=data.get("fridge_use", 1),
        study_in_room=data.get("study_in_room", 0),
        noise_sensitivity=data.get("noise_sensitivity", 3),
        desired_intimacy=data.get("desired_intimacy", 3),
        meal_together=data.get("meal_together", 2),
        exercise_together=data.get("exercise_together", 1),
        friend_invite=data.get("friend_invite", 1),
    )
    db.save_profile(profile)
    return jsonify(profile_to_dict(profile))


@app.route("/api/persona", methods=["GET"])
@login_required
def get_persona():
    payload = request.current_user
    profile = db.get_profile_by_user_uid(payload["user_uid"])
    if not profile:
        return jsonify({"error": "프로필이 없습니다."}), 404
    persona = profile.persona or classify_persona(profile)
    return jsonify({"persona": persona})


# ─── Matching ────────────────────────────────────────────────────────────

@app.route("/api/match/top", methods=["GET"])
@login_required
def match_top():
    payload = request.current_user
    top_n = request.args.get("top_n", 5, type=int)
    exclude_blocked = request.args.get("exclude_blocked", "true").lower() == "true"

    target = db.get_profile_by_user_uid(payload["user_uid"])
    if not target:
        return jsonify({"error": "설문조사를 먼저 작성해주세요."}), 404

    pool = db.fetch_profiles()
    results = rank_matches(target, pool, top_n=top_n, exclude_blocked=exclude_blocked)
    return jsonify({"matches": [r.to_dict() for r in results]})


@app.route("/api/match/pairs", methods=["GET"])
@login_required
def match_pairs():
    exclude_blocked = request.args.get("exclude_blocked", "true").lower() == "true"
    profiles = db.fetch_profiles()
    if len(profiles) < 2:
        return jsonify({"error": "매칭할 프로필이 부족합니다."}), 400
    results = best_pairings(profiles, exclude_blocked=exclude_blocked)
    return jsonify({"pairs": [r.to_dict() for r in results]})


# ─── Match Requests ──────────────────────────────────────────────────────

@app.route("/api/match/request", methods=["POST"])
@login_required
def create_match_request():
    payload = request.current_user
    data = request.get_json(force=True)
    to_user = data.get("to_user", "")
    if not to_user:
        return jsonify({"error": "대상 사용자가 필요합니다."}), 400

    conn = sqlite3.connect(db.DB_PATH)
    # 중복 검사
    existing = conn.execute(
        "SELECT * FROM match_requests WHERE from_user=? AND to_user=?",
        (payload["user_uid"], to_user),
    ).fetchone()
    if existing:
        conn.close()
        return jsonify({"error": "이미 요청한 상태입니다."}), 409

    uid = generate_uid()
    now = _now()
    conn.execute(
        "INSERT INTO match_requests (uid, from_user, to_user, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
        (uid, payload["user_uid"], to_user, "pending", now, now),
    )
    conn.commit()
    conn.close()

    # 실시간 푸시 (SSE)
    broadcast_message(to_user, "match_request", {
        "from_user": payload["user_uid"],
        "from_name": payload.get("name", ""),
        "status": "pending",
    })

    return jsonify({"uid": uid, "status": "pending"}), 201


@app.route("/api/match/request/<uid>", methods=["PATCH"])
@login_required
def update_match_request(uid):
    payload = request.current_user
    data = request.get_json(force=True)
    status = data.get("status", "")
    if status not in ("accepted", "rejected"):
        return jsonify({"error": "status는 accepted 또는 rejected만 가능합니다."}), 400

    conn = sqlite3.connect(db.DB_PATH)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM match_requests WHERE uid=?", (uid,)).fetchone()
    if not row:
        conn.close()
        return jsonify({"error": "요청을 찾을 수 없습니다."}), 404

    req = dict(row)
    if req["to_user"] != payload["user_uid"]:
        conn.close()
        return jsonify({"error": "권한이 없습니다."}), 403

    now = _now()
    conn.execute(
        "UPDATE match_requests SET status=?, updated_at=? WHERE uid=?",
        (status, now, uid),
    )

    if status == "accepted":
        # match_history 추가
        muid = generate_uid()
        conn.execute(
            "INSERT INTO match_history (uid, user_a, user_b, status, matched_at) VALUES (?, ?, ?, ?, ?)",
            (muid, req["from_user"], req["to_user"], "active", now),
        )
    conn.commit()
    conn.close()

    # 알림
    broadcast_message(req["from_user"], "match_response", {
        "request_uid": uid,
        "status": status,
    })

    return jsonify({"uid": uid, "status": status})


@app.route("/api/match/requests", methods=["GET"])
@login_required
def list_match_requests():
    payload = request.current_user
    direction = request.args.get("direction", "in")
    conn = sqlite3.connect(db.DB_PATH)
    conn.row_factory = sqlite3.Row
    if direction == "in":
        rows = conn.execute(
            "SELECT * FROM match_requests WHERE to_user=? ORDER BY created_at DESC",
            (payload["user_uid"],),
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM match_requests WHERE from_user=? ORDER BY created_at DESC",
            (payload["user_uid"],),
        ).fetchall()
    conn.close()
    return jsonify([dict(r) for r in rows])


# ─── Chat (SSE) ──────────────────────────────────────────────────────────

@app.route("/api/chat/stream", methods=["GET"])
@login_required
def chat_stream():
    payload = request.current_user
    user_uid = payload["user_uid"]

    def event_stream():
        q: queue.Queue = queue.Queue(maxsize=100)
        _add_sse_queue(user_uid, q)
        try:
            # 초기 연결 heartbeat
            yield f"event: connected\ndata: {jsonify({'user_uid': user_uid}).data.decode()}\n\n"
            while True:
                try:
                    msg = q.get(timeout=30)
                    event = msg["event"]
                    data_str = __import__("json").dumps(msg["data"], ensure_ascii=False)
                    yield f"event: {event}\ndata: {data_str}\n\n"
                except queue.Empty:
                    yield ":keep-alive\n\n"
        except GeneratorExit:
            pass
        finally:
            _remove_sse_queue(user_uid, q)

    return Response(
        stream_with_context(event_stream()),
        mimetype="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


@app.route("/api/chat/send", methods=["POST"])
@login_required
def chat_send():
    payload = request.current_user
    data = request.get_json(force=True)
    receiver = data.get("receiver", "")
    content = data.get("content", "").strip()
    msg_type = data.get("type", "text")
    if not receiver or not content:
        return jsonify({"error": "receiver와 content는 필수입니다."}), 400

    uid = generate_uid()
    now = _now()
    conn = sqlite3.connect(db.DB_PATH)
    conn.execute(
        "INSERT INTO chat_messages (uid, sender, receiver, content, type, read, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
        (uid, payload["user_uid"], receiver, content, msg_type, 0, now),
    )
    conn.commit()
    conn.close()

    # 실시간 전달
    broadcast_message(receiver, "chat_message", {
        "uid": uid,
        "sender": payload["user_uid"],
        "sender_name": payload.get("name", ""),
        "content": content,
        "type": msg_type,
        "created_at": now,
    })

    return jsonify({"uid": uid, "created_at": now}), 201


@app.route("/api/chat/messages", methods=["GET"])
@login_required
def chat_messages():
    payload = request.current_user
    other = request.args.get("with", "")
    limit = request.args.get("limit", 50, type=int)
    if not other:
        return jsonify({"error": "with 파라미터가 필요합니다."}), 400

    conn = sqlite3.connect(db.DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        "SELECT * FROM chat_messages WHERE (sender=? AND receiver=?) OR (sender=? AND receiver=?) "
        "ORDER BY created_at DESC LIMIT ?",
        (payload["user_uid"], other, other, payload["user_uid"], limit),
    ).fetchall()
    conn.close()
    return jsonify([dict(r) for r in reversed(rows)])


@app.route("/api/chat/read", methods=["POST"])
@login_required
def chat_read():
    payload = request.current_user
    data = request.get_json(force=True)
    other = data.get("with", "")
    if not other:
        return jsonify({"error": "with 파라미터가 필요합니다."}), 400

    conn = sqlite3.connect(db.DB_PATH)
    conn.execute(
        "UPDATE chat_messages SET read=1 WHERE sender=? AND receiver=? AND read=0",
        (other, payload["user_uid"]),
    )
    conn.commit()
    conn.close()
    return jsonify({"ok": True})


# ─── Reviews ─────────────────────────────────────────────────────────────

@app.route("/api/reviews", methods=["POST"])
@login_required
def create_review():
    payload = request.current_user
    data = request.get_json(force=True)
    reviewee = data.get("reviewee", "")
    rating = data.get("rating")
    body = data.get("body", "").strip()
    if not reviewee or rating is None:
        return jsonify({"error": "reviewee와 rating은 필수입니다."}), 400

    uid = generate_uid()
    now = _now()
    conn = sqlite3.connect(db.DB_PATH)
    conn.execute(
        "INSERT INTO reviews (uid, reviewer, reviewee, rating, body, created_at) VALUES (?, ?, ?, ?, ?, ?)",
        (uid, payload["user_uid"], reviewee, rating, body, now),
    )
    conn.commit()
    conn.close()
    return jsonify({"uid": uid}), 201


@app.route("/api/reviews/<reviewee>", methods=["GET"])
@login_required
def list_reviews(reviewee):
    conn = sqlite3.connect(db.DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        "SELECT * FROM reviews WHERE reviewee=? ORDER BY created_at DESC",
        (reviewee,),
    ).fetchall()
    conn.close()
    return jsonify([dict(r) for r in rows])


# ─── Stats ───────────────────────────────────────────────────────────────

@app.route("/api/stats", methods=["GET"])
def stats():
    conn = sqlite3.connect(db.DB_PATH)
    user_count = conn.execute("SELECT COUNT(*) FROM users").fetchone()[0]
    profile_count = conn.execute("SELECT COUNT(*) FROM profiles").fetchone()[0]
    conn.close()
    return jsonify({"users": user_count, "profiles": profile_count})


# ─── Init ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    db.init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)
