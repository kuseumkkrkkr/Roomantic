"""JWT authentication helpers."""

import datetime
from functools import wraps

import jwt
from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify, current_app

SECRET_KEY = "dorm-match-secret-key-change-in-production"
ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    return generate_password_hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    return check_password_hash(password_hash, password)


def create_token(user_uid: str, student_id: str, name: str) -> str:
    payload = {
        "user_uid": user_uid,
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
