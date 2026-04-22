#!/bin/bash
set -e

PG_BIN="$(brew --prefix postgresql@16)/bin"
export PATH="$PG_BIN:$PATH"

brew services start postgresql@16 2>/dev/null || true

cd "$(dirname "$0")"

uvicorn main:app --reload --host 0.0.0.0 --port 8000
