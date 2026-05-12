"""Simple SQLite helpers."""

import sqlite3
from typing import List, Optional
from models import User, RoommateProfile, profile_to_dict, classify_persona

DB_PATH = "roommates_api.db"


USER_COLUMNS = [
    ("uid", "TEXT PRIMARY KEY"),
    ("login_id", "TEXT NOT NULL UNIQUE"),
    ("student_id", "TEXT"),
    ("password_hash", "TEXT NOT NULL"),
    ("name", "TEXT NOT NULL"),
    ("is_enrolled", "INTEGER NOT NULL DEFAULT 1"),
    ("school_name", "TEXT"),
    ("region_name", "TEXT"),
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


def init_db(db_path: str = DB_PATH, drop_if_corrupt: bool = True):
    try:
        conn = sqlite3.connect(db_path)
        _ensure_table(conn, "users", USER_COLUMNS)
        _ensure_table(conn, "profiles", PROFILE_COLUMNS)
        _add_missing_columns(conn, "users", USER_COLUMNS)
        _add_missing_columns(conn, "profiles", PROFILE_COLUMNS)

        # 새 테이블: pairings (전체 매칭 결과)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS pairings (uid TEXT PRIMARY KEY, pair_json TEXT, generated_at TEXT)"
        )

        # 새 테이블: match_requests (요청/승인)
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_requests ("
            "          uid TEXT PRIMARY KEY, from_user TEXT, to_user TEXT, status TEXT, created_at TEXT, updated_at TEXT)"
        )

        # 새 테이블: chat_messages
        conn.execute(
            "CREATE TABLE IF NOT EXISTS chat_messages ("
            "          uid TEXT PRIMARY KEY, sender TEXT, receiver TEXT, content TEXT, type TEXT, read INTEGER, created_at TEXT)"
        )

        # 새 테이블: reviews
        conn.execute(
            "CREATE TABLE IF NOT EXISTS reviews ("
            "          uid TEXT PRIMARY KEY, reviewer TEXT, reviewee TEXT, rating REAL, body TEXT, created_at TEXT)"
        )

        # 새 테이블: match_history
        conn.execute(
            "CREATE TABLE IF NOT EXISTS match_history ("
            "          uid TEXT PRIMARY KEY, user_a TEXT, user_b TEXT, status TEXT, matched_at TEXT)"
        )

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
                "CREATE TABLE IF NOT EXISTS pairings (uid TEXT PRIMARY KEY, pair_json TEXT, generated_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_requests ("
                "          uid TEXT PRIMARY KEY, from_user TEXT, to_user TEXT, status TEXT, created_at TEXT, updated_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS chat_messages ("
                "          uid TEXT PRIMARY KEY, sender TEXT, receiver TEXT, content TEXT, type TEXT, read INTEGER, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS reviews ("
                "          uid TEXT PRIMARY KEY, reviewer TEXT, reviewee TEXT, rating REAL, body TEXT, created_at TEXT)"
            )
            conn.execute(
                "CREATE TABLE IF NOT EXISTS match_history ("
                "          uid TEXT PRIMARY KEY, user_a TEXT, user_b TEXT, status TEXT, matched_at TEXT)"
            )
            conn.commit()
            conn.close()
        else:
            raise


def save_user(user: User, db_path: str = DB_PATH):
    conn = sqlite3.connect(db_path)
    conn.execute(
        "INSERT OR REPLACE INTO users (uid, login_id, student_id, password_hash, name, is_enrolled, school_name, region_name) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        (user.uid, user.login_id, user.student_id, user.password_hash, user.name, user.is_enrolled, user.school_name, user.region_name),
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
    # 페르소나 자동 분류
    if not profile.persona:
        profile.persona = classify_persona(profile)

    conn = sqlite3.connect(db_path)
    cols = [c for c, _ in PROFILE_COLUMNS]
    placeholders = ", ".join(["?"] * len(cols))
    values = [getattr(profile, c, None) for c in cols]
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
    return RoommateProfile(**{k: row[k] for k in row.keys()})


def fetch_profiles(db_path: str = DB_PATH) -> List[RoommateProfile]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("SELECT * FROM profiles").fetchall()
    conn.close()
    return [RoommateProfile(**{k: r[k] for k in r.keys()}) for r in rows]


# --- 기존 student_id 기반 조회 유지 호환 ---

def get_user_by_student_id(student_id: str, db_path: str = DB_PATH) -> Optional[User]:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM users WHERE student_id = ? LIMIT 1", (student_id,)).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**{k: row[k] for k in row.keys()})
