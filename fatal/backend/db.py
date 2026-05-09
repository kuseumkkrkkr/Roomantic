"""SQLite helpers for roommate backend."""

import sqlite3
from typing import Optional

from models import User, RoommateProfile

DB_PATH = "roommates_api.db"

USER_COLUMNS = [
    ("uid", "TEXT PRIMARY KEY"),
    ("student_id", "TEXT NOT NULL UNIQUE"),
    ("password_hash", "TEXT NOT NULL"),
    ("name", "TEXT NOT NULL"),
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


def init_db(db_path: str = DB_PATH) -> None:
    conn = sqlite3.connect(db_path)
    user_sql = ", ".join([f"{name} {ctype}" for name, ctype in USER_COLUMNS])
    conn.execute(f"CREATE TABLE IF NOT EXISTS users ({user_sql})")
    prof_sql = ", ".join([f"{name} {ctype}" for name, ctype in PROFILE_COLUMNS])
    conn.execute(f"CREATE TABLE IF NOT EXISTS profiles ({prof_sql})")
    conn.commit()
    conn.close()


def save_user(user: User, db_path: str = DB_PATH) -> None:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    cols = ", ".join([c[0] for c in USER_COLUMNS])
    placeholders = ", ".join(["?"] * len(USER_COLUMNS))
    sql = f"INSERT OR REPLACE INTO users ({cols}) VALUES ({placeholders})"
    d = user.__dict__
    conn.execute(sql, tuple(d[c[0]] for c in USER_COLUMNS))
    conn.commit()
    conn.close()


def get_user_by_student_id(student_id: str, db_path: str = DB_PATH) -> Optional[User]:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    cols = [c[0] for c in USER_COLUMNS]
    row = conn.execute(
        f"SELECT {', '.join(cols)} FROM users WHERE student_id = ?", (student_id,)
    ).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**dict(zip(cols, row)))


def get_user_by_uid(uid: str, db_path: str = DB_PATH) -> Optional[User]:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    cols = [c[0] for c in USER_COLUMNS]
    row = conn.execute(
        f"SELECT {', '.join(cols)} FROM users WHERE uid = ?", (uid,)
    ).fetchone()
    conn.close()
    if row is None:
        return None
    return User(**dict(zip(cols, row)))


def save_profile(profile: RoommateProfile, db_path: str = DB_PATH) -> None:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    placeholders = ", ".join(["?"] * len(PROFILE_COLUMNS))
    cols = ", ".join([c[0] for c in PROFILE_COLUMNS])
    sql = f"INSERT OR REPLACE INTO profiles ({cols}) VALUES ({placeholders})"
    d = profile.__dict__
    conn.execute(sql, tuple(d[c[0]] for c in PROFILE_COLUMNS))
    conn.commit()
    conn.close()


def get_profile_by_user_uid(user_uid: str, db_path: str = DB_PATH) -> Optional[RoommateProfile]:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    cols = [c[0] for c in PROFILE_COLUMNS]
    row = conn.execute(
        f"SELECT {', '.join(cols)} FROM profiles WHERE user_uid = ?", (user_uid,)
    ).fetchone()
    conn.close()
    if row is None:
        return None
    return RoommateProfile(**dict(zip(cols, row)))


def fetch_profiles(db_path: str = DB_PATH) -> list[RoommateProfile]:
    init_db(db_path)
    conn = sqlite3.connect(db_path)
    cols = [c[0] for c in PROFILE_COLUMNS]
    rows = conn.execute(f"SELECT {', '.join(cols)} FROM profiles").fetchall()
    conn.close()
    return [RoommateProfile(**dict(zip(cols, row))) for row in rows]
