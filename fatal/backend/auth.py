"""JWT authentication helpers."""

import hashlib
import secrets
import datetime
from functools import wraps

import jwt
from flask import request, jsonify

SECRET_KEY = "roomantic-secret-key-change-in-production"
ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    """SHA-256 단방향 해싱 (salted)."""
    salt = secrets.token_hex(16)
    return f"{salt}${hashlib.sha256((password + salt).encode()).hexdigest()}"


def verify_password(password: str, password_hash: str) -> bool:
    if "$" not in password_hash:
        return False
    salt, stored = password_hash.split("$", 1)
    return hashlib.sha256((password + salt).encode()).hexdigest() == stored


def create_token(user_uid: str, login_id: str, name: str, student_id: str = "") -> str:
    payload = {
        "user_uid": user_uid,
        "login_id": login_id,
        "student_id": student_id,
        "name": name,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(days=7),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        return {"error": "Token expired"}
    except jwt.InvalidTokenError:
        return {"error": "Invalid token"}


def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing token"}), 401
        token = auth_header.split(" ")[1]
        payload = decode_token(token)
        if "error" in payload:
            return jsonify({"error": payload["error"]}), 401
        request.current_user = payload
        return f(*args, **kwargs)
    return decorated
