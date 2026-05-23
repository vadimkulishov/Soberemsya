#!/bin/bash
set -e

if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! brew list postgresql@16 &>/dev/null; then
    brew install postgresql@16
fi

brew services start postgresql@16

PG_BIN="$(brew --prefix postgresql@16)/bin"
export PATH="$PG_BIN:$PATH"

sleep 3

"$PG_BIN/createdb" soberemsya 2>/dev/null || echo "База данных уже существует"

cd "$(dirname "$0")"

pip3 install -r requirements.txt

python3 seed.py

uvicorn main:app --reload --host 0.0.0.0 --port 8000
