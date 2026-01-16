import requests
import time
import pytest

BASE = "http://127.0.0.1:8000/api"  # zmień jeśli inny

def unique_email():
    return f"test_{int(time.time())}@example.com"

def test_register_success():
    payload = {
        "name": "ApiTestUser",
        "email": unique_email(),
        "password": "Password1",
        "password_confirmation": "Password1"
    }
    r = requests.post(f"{BASE}/register", json=payload, timeout=5)
    assert r.status_code in (200, 201)
    jb = r.json()
    assert isinstance(jb, dict)

def test_register_validation_error():
    payload = {"name": "", "email": "bad", "password": "1", "password_confirmation": "2"}
    r = requests.post(f"{BASE}/register", json=payload, timeout=5)
    assert r.status_code >= 400

def test_login_success():
    # Wymaga wcześniej utworzonego konta; zakładamy test_register_success zapewnia konto
    email = unique_email()
    # utwórz konto
    requests.post(f"{BASE}/register", json={
        "name": "ApiTestUser",
        "email": email,
        "password": "Password1",
        "password_confirmation": "Password1"
    }, timeout=5)
    r = requests.post(f"{BASE}/login", json={"email": email, "password": "Password1"}, timeout=5)
    assert r.status_code == 200
    body = r.json()
    assert isinstance(body, dict)

def test_login_wrong_password():
    email = unique_email()
    requests.post(f"{BASE}/register", json={
        "name": "ApiTestUser",
        "email": email,
        "password": "Password1",
        "password_confirmation": "Password1"
    }, timeout=5)
    r = requests.post(f"{BASE}/login", json={"email": email, "password": "wrong"}, timeout=5)
    assert r.status_code >= 400