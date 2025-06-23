# app/core/firebase_auth.py
from fastapi import Request, HTTPException, Depends
import firebase_admin
from firebase_admin import auth, credentials
import os

cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)

async def verify_token(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Unauthorized")
    
    token = auth_header.split(" ")[1]
    try:
        decoded_token = auth.verify_id_token(token)
        request.state.user = decoded_token
        return decoded_token
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")
