# Soberemsya Backend

FastAPI backend for the Soberemsya ecosystem.

## Repositories

- [Soberemsya](https://github.com/vadimkulishov/Soberemsya) — iOS + watchOS app
- [Soberemsya-backend](https://github.com/vadimkulishov/Soberemsya-backend) — this API
- [Soberemsya-web](https://github.com/vadimkulishov/Soberemsya-web) — web/admin panel

## Stack

- FastAPI
- SQLAlchemy
- SQLite

## Available apps

- `main_mobile.py` — mobile API for the iOS app
- `main.py` — admin-oriented API

## Quick start

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export SECRET_KEY="change-this-to-a-long-random-value"
uvicorn main_mobile:app --host 0.0.0.0 --port 8002 --reload
```

## Admin API

```bash
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

## Notes

- Static image assets are served from `./static`
- The web/admin client now lives in the separate [Soberemsya-web](https://github.com/vadimkulishov/Soberemsya-web) repository
