"""Simple SQLite helpers."""

import sqlite3
import json
from typing import List, Optional
from models import User, RoommateProfile, profile_to_dict, classify_persona

DB_PATH = "roommates_api.db"
SCHOOLS_DB_PATH = "schools.db"


USER_COLUMNS = [
    ("uid", "TEXT PRIMARY KEY"),
    ("login_id", "TEXT NOT NULL UNIQUE"),
    ("student_id", "TEXT"),
    ("birth_year", "INTEGER DEFAULT 2005"),
    ("password_hash", "TEXT NOT NULL"),
    ("name", "TEXT NOT NULL"),
    ("is_enrolled", "INTEGER NOT NULL DEFAULT 1"),
    ("school_name", "TEXT"),
    ("college", "TEXT"),
    ("department", "TEXT"),
    ("region_name", "TEXT"),
    ("gender", "TEXT"),
]

PROFILE_COLUMNS = [
    ("uid", "TEXT PRIMARY KEY"),
    ("user_uid", "TEXT NOT NULL UNIQUE"),
    ("persona", "TEXT"),
    ("name", "TEXT NOT NULL"),
    ("student_id", "TEXT NOT NULL"),
    ("birth_year", "INTEGER"),
    ("college", "TEXT"),
    ("department", "TEXT"),
    ("dorm_duration", "INTEGER"),
    ("dormitory_hall", "TEXT"),
    ("non_negotiable_items", "TEXT"),
    ("non_negotiable_weights", "TEXT"),
    ("home_visit_cycle", "INTEGER"),
    ("perfume", "INTEGER"),
    ("indoor_scent_sensitivity", "INTEGER"),
    ("alcohol_tolerance", "REAL"),
    ("alcohol_frequency", "INTEGER"),
    ("drunk_habit", "INTEGER"),
    ("gaming_hours_per_week", "INTEGER"),
    ("speaker_use", "INTEGER"),
    ("exercise", "INTEGER"),
    ("bedtime", "INTEGER"),
    ("wake_time", "INTEGER"),
    ("sleep_habit", "INTEGER"),
    ("sleep_sensitivity", "INTEGER"),
    ("alarm_strength", "INTEGER"),
    ("sleep_light", "INTEGER"),
    ("snoring", "INTEGER"),
    ("shower_duration", "INTEGER"),
    ("shower_time", "INTEGER"),
    ("shower_cycle", "INTEGER"),
    ("cleaning_cycle", "INTEGER"),
    ("ventilation", "REAL"),
    ("hairdryer_in_bathroom", "INTEGER"),
    ("toilet_paper_share", "INTEGER"),
    ("indoor_eating", "INTEGER"),
    ("smoking", "INTEGER"),
    ("temperature_pref", "INTEGER"),
    ("indoor_call", "INTEGER"),
    ("bug_handling", "INTEGER"),
    ("laundry_cycle", "INTEGER"),
    ("drying_rack", "INTEGER"),
    ("fridge_use", "INTEGER"),
    ("study_in_room", "INTEGER"),
    ("noise_sensitivity", "INTEGER"),
    ("desired_intimacy", "INTEGER"),
    ("meal_together", "INTEGER"),
    ("exercise_together", "INTEGER"),
    ("friend_invite", "INTEGER"),
    ("matching_phase", "TEXT DEFAULT 'preliminary'"),
    ("hope_halls", "TEXT"),
    ("accepted_hall", "TEXT"),
    ("room_capacity", "INTEGER DEFAULT 2"),
]


def _ensure_table(conn: sqlite3.Connection, name: str, columns: List):
    col_defs = ", ".join(f"{c} {t}" for c, t in columns)
    conn.execute(f"CREATE TABLE IF NOT EXISTS {name} ({col_defs})")


def _add_missing_columns(conn: sqlite3.Connection, table: str, columns: List):
    """Best-effort migration: add columns if they do not exist."""
    existing_cols = {row[1] for row in conn.execute(f"PRAGMA table_info({table})")}
    for col_name, col_type in columns:
        if col_name not in existing_cols:
            try:
                conn.execute(f"ALTER TABLE {table} ADD COLUMN {col_name} {col_type}")
            except Exception:
                pass


def init_schools_db(db_path: str = SCHOOLS_DB_PATH):
    conn = sqlite3.connect(db_path)
    conn.execute(
        "CREATE TABLE IF NOT EXISTS schools ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT NOT NULL UNIQUE, "
        "recruitment_start TEXT, "
        "recruitment_end TEXT, "
        "matching_enabled INTEGER NOT NULL DEFAULT 1"
        ")"
    )
    conn.execute(
        "CREATE TABLE IF NOT EXISTS dormitories ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "school_id INTEGER NOT NULL, "
        "name TEXT NOT NULL, "
        "gender TEXT NOT NULL CHECK(gender IN ('male','female','coed')), "
        "UNIQUE(school_id, name), "
        "FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE"
        ")"
    )
    conn.execute(
        "CREATE TABLE IF NOT EXISTS colleges ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "school_id INTEGER NOT NULL, "
        "name TEXT NOT NULL, "
        "UNIQUE(school_id, name), "
        "FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE"
        ")"
    )
    conn.execute(
        "CREATE TABLE IF NOT EXISTS departments ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "college_id INTEGER NOT NULL, "
        "name TEXT NOT NULL, "
        "UNIQUE(college_id, name), "
        "FOREIGN KEY(college_id) REFERENCES colleges(id) ON DELETE CASCADE"
        ")"
    )

    # 고려대학교 기본 데이터 보존 (SQL 명령어 기반)
    conn.execute(
        "INSERT OR IGNORE INTO schools (name, recruitment_start, recruitment_end, matching_enabled) VALUES (?, ?, ?, ?)",
        ("고려대학교", None, None, 1),
    )
    school_row = conn.execute("SELECT id FROM schools WHERE name=?", ("고려대학교",)).fetchone()
    if school_row:
        school_id = school_row[0]
        conn.execute(
            "INSERT OR REPLACE INTO dormitories (id, school_id, name, gender) VALUES ("
            "COALESCE((SELECT id FROM dormitories WHERE school_id=? AND name=?), NULL), ?, ?, ?)",
            (school_id, "자유관", school_id, "자유관", "male"),
        )
        conn.execute(
            "INSERT OR REPLACE INTO dormitories (id, school_id, name, gender) VALUES ("
            "COALESCE((SELECT id FROM dormitories WHERE school_id=? AND name=?), NULL), ?, ?, ?)",
            (school_id, "미래관", school_id, "미래관", "coed"),
        )
        conn.execute(
            "INSERT OR REPLACE INTO dormitories (id, school_id, name, gender) VALUES ("
            "COALESCE((SELECT id FROM dormitories WHERE school_id=? AND name=?), NULL), ?, ?, ?)",
            (school_id, "진리관", school_id, "진리관", "coed"),
        )
        conn.execute(
            "INSERT OR REPLACE INTO dormitories (id, school_id, name, gender) VALUES ("
            "COALESCE((SELECT id FROM dormitories WHERE school_id=? AND name=?), NULL), ?, ?, ?)",
            (school_id, "정의관", school_id, "정의관", "female"),
        )

    conn.commit()
    conn.close()
def init_db(db_path: str = DB_PATH, drop_if_corrupt: bool = True):
    try:
        init_schools_db()
        conn = sqlite3.connect(db_path)
        _ensure_table(conn, "users", USER_COLUMNS)
        _ensure_table(conn, "profiles", PROFILE_COLUMNS)
        _add_missing_columns(conn, "users", USER_COLUMNS)
        _add_missing_columns(conn, "profiles", PROFILE_COLUMNS)

        # ???뚯씠釉? match_pool_candidates (? ?꾨낫)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_pool_candidates ("
            "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL, "
            "          candidate_uid TEXT, candidate_type TEXT DEFAULT 'individual', "
            "          display_name TEXT, shared_score REAL, member_scores TEXT, member_names TEXT, "
            "          tier TEXT, room_capacity INTEGER, detail TEXT, created_at TEXT)"
        )

        # ???뚯씠釉? match_sessions (留ㅼ묶 ?몄뀡)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_sessions ("
            "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL, "
            "          candidate_uid TEXT NOT NULL, candidate_type TEXT DEFAULT 'individual', "
            "          room_member_uids TEXT, delegate_uid TEXT, status TEXT, "
            "          user_confirmed INTEGER DEFAULT 0, candidate_confirmed INTEGER DEFAULT 0, "
            "          user_decision TEXT, candidate_decision TEXT, "
            "          user_reject_reason TEXT, candidate_reject_reason TEXT, "
            "          user_survey_opened INTEGER DEFAULT 0, candidate_survey_opened INTEGER DEFAULT 0, "
            "          last_activity_at TEXT, created_at TEXT, confirmed_at TEXT, closed_at TEXT)"
        )

        # ???뚯씠釉? match_session_members (?몄뀡 李멸???
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_session_members ("
            "          uid TEXT PRIMARY KEY, session_uid TEXT, user_uid TEXT, "
            "          role TEXT, joined_at TEXT)"
        )

        # ???뚯씠釉? chat_threads (梨꾪똿 ?ㅻ젅??
        conn.execute(
            "CREATE TABLE IF NOT EXISTS chat_threads ("
            "          uid TEXT PRIMARY KEY, session_uid TEXT, "
            "          user_a TEXT, user_b TEXT, status TEXT, "
            "          closed_reason TEXT, chat_exchange_count INTEGER DEFAULT 0, "
            "          last_message_at TEXT, created_at TEXT, closed_at TEXT)"
        )

        # ???뚯씠釉? match_cooldowns (?щℓ移?荑⑤떎??
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_cooldowns ("
            "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL UNIQUE, "
            "          cooldown_until TEXT, reason TEXT, created_at TEXT)"
        )

        # ???뚯씠釉? system_events (?쒖뒪???대깽??濡쒓렇)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS system_events ("
            "          uid TEXT PRIMARY KEY, user_uid TEXT, event_type TEXT, "
            "          payload TEXT, created_at TEXT, expire_at TEXT)"
        )

        # ???뚯씠釉? pairings (?꾩껜 留ㅼ묶 寃곌낵)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS pairings (uid TEXT PRIMARY KEY, pair_json TEXT, generated_at TEXT)"
        )

        # ???뚯씠釉? match_requests (?붿껌/?뱀씤)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_requests ("
            "          uid TEXT PRIMARY KEY, from_user TEXT, to_user TEXT, status TEXT, created_at TEXT, updated_at TEXT)"
        )

        # ???뚯씠釉? chat_messages
        conn.execute(
            "CREATE TABLE IF NOT EXISTS chat_messages ("
            "          uid TEXT PRIMARY KEY, session_uid TEXT, thread_uid TEXT, "
            "          sender TEXT, receiver TEXT, content TEXT, type TEXT, read INTEGER, "
            "          delivered_at TEXT, expires_at TEXT, created_at TEXT)"
        )

        # ???뚯씠釉? reviews
        conn.execute(
            "CREATE TABLE IF NOT EXISTS reviews ("
            "          uid TEXT PRIMARY KEY, reviewer TEXT, reviewee TEXT, rating REAL, body TEXT, created_at TEXT)"
        )

        # notices (admin editable announcements)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS notices ("
            "          id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "          title TEXT NOT NULL, "
            "          body TEXT NOT NULL, "
            "          is_pinned INTEGER NOT NULL DEFAULT 0, "
            "          created_at TEXT NOT NULL, "
            "          updated_at TEXT NOT NULL)"
        )

        # ???뚯씠釉? match_history
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_history ("
            "          uid TEXT PRIMARY KEY, session_uid TEXT, user_a TEXT, user_b TEXT, status TEXT, matched_at TEXT)"
        )

        _add_missing_columns(conn, "match_pool_candidates", [
            ("candidate_uid", "TEXT"),
            ("candidate_type", "TEXT DEFAULT 'individual'"),
            ("display_name", "TEXT"),
            ("shared_score", "REAL"),
            ("member_scores", "TEXT"),
            ("member_names", "TEXT"),
            ("detail", "TEXT"),
        ])
        _add_missing_columns(conn, "match_sessions", [
            ("user_uid", "TEXT"),
            ("candidate_uid", "TEXT"),
            ("candidate_type", "TEXT DEFAULT 'individual'"),
            ("room_member_uids", "TEXT"),
            ("delegate_uid", "TEXT"),
            ("user_confirmed", "INTEGER DEFAULT 0"),
            ("candidate_confirmed", "INTEGER DEFAULT 0"),
            ("user_decision", "TEXT"),
            ("candidate_decision", "TEXT"),
            ("user_reject_reason", "TEXT"),
            ("candidate_reject_reason", "TEXT"),
            ("user_survey_opened", "INTEGER DEFAULT 0"),
            ("candidate_survey_opened", "INTEGER DEFAULT 0"),
            ("last_activity_at", "TEXT"),
        ])
        _add_missing_columns(conn, "chat_threads", [
            ("closed_reason", "TEXT"),
            ("chat_exchange_count", "INTEGER DEFAULT 0"),
            ("last_message_at", "TEXT"),
        ])
        _add_missing_columns(conn, "chat_messages", [
            ("session_uid", "TEXT"),
            ("thread_uid", "TEXT"),
            ("delivered_at", "TEXT"),
            ("expires_at", "TEXT"),
        ])
        _add_missing_columns(conn, "match_cooldowns", [
            ("cooldown_until", "TEXT"),
            ("created_at", "TEXT"),
        ])
        _add_missing_columns(conn, "system_events", [
            ("user_uid", "TEXT"),
            ("expire_at", "TEXT"),
        ])
        _add_missing_columns(conn, "match_history", [
            ("session_uid", "TEXT"),
        ])
        _add_missing_columns(conn, "notices", [
            ("is_pinned", "INTEGER NOT NULL DEFAULT 0"),
            ("created_at", "TEXT"),
            ("updated_at", "TEXT"),
        ])

        conn.commit()
        conn.close()
    except Exception as e:
        if drop_if_corrupt:
            import os
            if os.path.exists(db_path):
                os.remove(db_path)
            conn = sqlite3.connect(db_path)
            _ensure_table(conn, "users", USER_COLUMNS)
            _ensure_table(conn, "profiles", PROFILE_COLUMNS)
            _add_missing_columns(conn, "users", USER_COLUMNS)
            _add_missing_columns(conn, "profiles", PROFILE_COLUMNS)
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_pool_candidates ("
                "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL, "
                "          candidate_uid TEXT, candidate_type TEXT DEFAULT 'individual', "
                "          display_name TEXT, shared_score REAL, member_scores TEXT, member_names TEXT, "
                "          tier TEXT, room_capacity INTEGER, detail TEXT, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_sessions ("
                "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL, "
                "          candidate_uid TEXT NOT NULL, candidate_type TEXT DEFAULT 'individual', "
                "          room_member_uids TEXT, delegate_uid TEXT, status TEXT, "
                "          user_confirmed INTEGER DEFAULT 0, candidate_confirmed INTEGER DEFAULT 0, "
                "          user_decision TEXT, candidate_decision TEXT, "
                "          user_reject_reason TEXT, candidate_reject_reason TEXT, "
                "          user_survey_opened INTEGER DEFAULT 0, candidate_survey_opened INTEGER DEFAULT 0, "
                "          last_activity_at TEXT, created_at TEXT, confirmed_at TEXT, closed_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_session_members ("
                "          uid TEXT PRIMARY KEY, session_uid TEXT, user_uid TEXT, "
                "          role TEXT, joined_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS chat_threads ("
                "          uid TEXT PRIMARY KEY, session_uid TEXT, "
                "          user_a TEXT, user_b TEXT, status TEXT, "
                "          closed_reason TEXT, chat_exchange_count INTEGER DEFAULT 0, "
                "          last_message_at TEXT, created_at TEXT, closed_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_cooldowns ("
                "          uid TEXT PRIMARY KEY, user_uid TEXT NOT NULL UNIQUE, "
                "          cooldown_until TEXT, reason TEXT, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS system_events ("
                "          uid TEXT PRIMARY KEY, user_uid TEXT, event_type TEXT, "
                "          payload TEXT, created_at TEXT, expire_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS pairings (uid TEXT PRIMARY KEY, pair_json TEXT, generated_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_requests ("
                "          uid TEXT PRIMARY KEY, from_user TEXT, to_user TEXT, status TEXT, created_at TEXT, updated_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS chat_messages ("
                "          uid TEXT PRIMARY KEY, session_uid TEXT, thread_uid TEXT, "
                "          sender TEXT, receiver TEXT, content TEXT, type TEXT, read INTEGER, "
                "          delivered_at TEXT, expires_at TEXT, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS reviews ("
                "          uid TEXT PRIMARY KEY, reviewer TEXT, reviewee TEXT, rating REAL, body TEXT, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_history ("
                "          uid TEXT PRIMARY KEY, session_uid TEXT, user_a TEXT, user_b TEXT, status TEXT, matched_at TEXT)"
            )
            conn.commit()
            conn.close()
        else:
            raise


def save_user(user: User, db_path: str = DB_PATH):
    conn = sqlite3.connect(db_path)
    conn.execute(
        "INSERT OR REPLACE INTO users (uid, login_id, student_id, birth_year, password_hash, name, is_enrolled, school_name, college, department, region_name, gender) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (
            user.uid,
            user.login_id,
            user.student_id,
            user.birth_year,
            user.password_hash,
            user.name,
            user.is_enrolled,
            user.school_name,
            user.college,
            user.department,
            user.region_name,
            user.gender,
        ),
    )
    conn.commit()
    conn.close()


def get_user_by_login_id(login_id: str, db_path: str = DB_PATH) -> Optional[User]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM users WHERE login_id = ? LIMIT 1", (login_id,)).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**{k: row[k] for k in row.keys()})


def get_user_by_uid(uid: str, db_path: str = DB_PATH) -> Optional[User]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM users WHERE uid = ? LIMIT 1", (uid,)).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**{k: row[k] for k in row.keys()})


def save_profile(profile: RoommateProfile, db_path: str = DB_PATH):
    # ?섎Ⅴ?뚮굹 ?먮룞 遺꾨쪟
    if not profile.persona:
        profile.persona = classify_persona(profile)

    conn = sqlite3.connect(db_path)
    cols = [c for c, _ in PROFILE_COLUMNS]
    placeholders = ", ".join(["?"] * len(cols))
    # JSON 吏곷젹?붽? ?꾩슂??而щ읆 泥섎━
    values = []
    for c in cols:
        v = getattr(profile, c, None)
        if c in ("non_negotiable_items", "non_negotiable_weights", "hope_halls") and v is not None:
            v = json.dumps(v, ensure_ascii=False)
        values.append(v)
    conn.execute(
        f"INSERT OR REPLACE INTO profiles ({', '.join(cols)}) VALUES ({placeholders})",
        values,
    )
    conn.commit()
    conn.close()


def get_profile_by_user_uid(user_uid: str, db_path: str = DB_PATH) -> Optional[RoommateProfile]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    row = conn.execute(
        "SELECT * FROM profiles WHERE user_uid = ? LIMIT 1", (user_uid,)
    ).fetchone()
    conn.close()
    if row is None:
        return None
    d = {k: row[k] for k in row.keys()}
    # JSON ??쭅?ы솕
    for k in ("non_negotiable_items", "non_negotiable_weights", "hope_halls"):
        if d.get(k) and isinstance(d[k], str):
            try:
                d[k] = json.loads(d[k])
            except Exception:
                d[k] = []
        elif d.get(k) is None:
            d[k] = []
    return RoommateProfile(**d)


def fetch_profiles(db_path: str = DB_PATH) -> List[RoommateProfile]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("SELECT * FROM profiles").fetchall()
    conn.close()
    result = []
    for r in rows:
        d = {k: r[k] for k in r.keys()}
        for k in ("non_negotiable_items", "non_negotiable_weights", "hope_halls"):
            if d.get(k) and isinstance(d[k], str):
                try:
                    d[k] = json.loads(d[k])
                except Exception:
                    d[k] = []
        result.append(RoommateProfile(**d))
    return result


# --- 湲곗〈 student_id 湲곕컲 議고쉶 ?좎? ?명솚 ---

def get_user_by_student_id(student_id: str, db_path: str = DB_PATH) -> Optional[User]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM users WHERE student_id = ? LIMIT 1", (student_id,)).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**{k: row[k] for k in row.keys()})
