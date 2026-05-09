"""Flask backend for Dorm Mate matching app."""

from flask import Flask, request, jsonify
from flask_cors import CORS

import db
from models import User, RoommateProfile
from matcher import rank_matches, best_pairings
from auth import hash_password, verify_password, create_token, login_required

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})


@app.route("/api/auth/register", methods=["POST"])
def register():
    data = request.get_json(force=True)
    student_id = data.get("student_id", "").strip()
    password = data.get("password", "")
    name = data.get("name", "").strip()

    if not student_id or not password or not name:
        return jsonify({"error": "학번, 비밀번호, 이름은 필수입니다."}), 400

    if db.get_user_by_student_id(student_id):
        return jsonify({"error": "이미 등록된 학번입니다."}), 409

    user = User(
        student_id=student_id,
        password_hash=hash_password(password),
        name=name,
    )
    db.save_user(user)
    token = create_token(user.uid, user.student_id, user.name)
    return jsonify({
        "token": token,
        "user": {"uid": user.uid, "student_id": user.student_id, "name": user.name},
    }), 201


@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json(force=True)
    student_id = data.get("student_id", "").strip()
    password = data.get("password", "")

    user = db.get_user_by_student_id(student_id)
    if not user or not verify_password(password, user.password_hash):
        return jsonify({"error": "학번 또는 비밀번호가 올바르지 않습니다."}), 401

    token = create_token(user.uid, user.student_id, user.name)
    return jsonify({
        "token": token,
        "user": {"uid": user.uid, "student_id": user.student_id, "name": user.name},
    })


@app.route("/api/me", methods=["GET"])
@login_required
def me():
    payload = request.current_user
    return jsonify({
        "uid": payload["user_uid"],
        "student_id": payload["student_id"],
        "name": payload["name"],
    })


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

    required = ["name", "student_id"]
    for field in required:
        if not data.get(field):
            return jsonify({"error": f"{field}는 필수입니다."}), 400

    existing = db.get_profile_by_user_uid(payload["user_uid"])
    uid = existing.uid if existing else None

    profile = RoommateProfile(
        uid=uid or generate_uid(),
        user_uid=payload["user_uid"],
        name=data.get("name", ""),
        student_id=data.get("student_id", ""),
        birth_year=data.get("birth_year", 2000),
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
        bedtime=data.get("bedtime", 24),
        wake_time=data.get("wake_time", 8),
        sleep_habit=data.get("sleep_habit", 0),
        sleep_sensitivity=data.get("sleep_sensitivity", 3),
        alarm_strength=data.get("alarm_strength", 3),
        sleep_light=data.get("sleep_light", 0),
        snoring=data.get("snoring", 0),
        shower_duration=data.get("shower_duration", 10),
        shower_time=data.get("shower_time", 22),
        shower_cycle=data.get("shower_cycle", 1),
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
        friend_invite=data.get("friend_invite", 3),
    )
    db.save_profile(profile)
    return jsonify(profile_to_dict(profile))


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
    return jsonify([r.to_dict() for r in results])


@app.route("/api/match/pairs", methods=["GET"])
@login_required
def match_pairs():
    exclude_blocked = request.args.get("exclude_blocked", "true").lower() == "true"
    profiles = db.fetch_profiles()
    if len(profiles) < 2:
        return jsonify({"error": "매칭할 프로필이 부족합니다."}), 400
    results = best_pairings(profiles, exclude_blocked=exclude_blocked)
    return jsonify([r.to_dict() for r in results])


def profile_to_dict(p: RoommateProfile) -> dict:
    return p.__dict__


def generate_uid() -> str:
    import uuid
    return str(uuid.uuid4())


if __name__ == "__main__":
    db.init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)
