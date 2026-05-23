#!/bin/bash
set -e

cd "$(dirname "$0")"

if [ -x ".venv/bin/python" ]; then
    PYTHON=".venv/bin/python"
else
    PYTHON="python3"
fi

HOST="${HOST:-0.0.0.0}"
MOBILE_APP_MODULE="${MOBILE_APP_MODULE:-main_mobile:app}"
ADMIN_APP_MODULE="${ADMIN_APP_MODULE:-main:app}"
MOBILE_PORT="${MOBILE_PORT:-8002}"
ADMIN_PORT="${ADMIN_PORT:-8001}"

PIDS=()
CLEANED_UP=0

cleanup() {
    if [ "$CLEANED_UP" = "1" ]; then
        return
    fi
    CLEANED_UP=1

    echo
    echo "Stopping Soberemsya services..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    wait 2>/dev/null || true
}

trap cleanup EXIT INT TERM

start_uvicorn() {
    local name="$1"
    local module="$2"
    local port="$3"

    echo "Starting $name on http://$HOST:$port"

    if [ "${RELOAD:-0}" = "1" ]; then
        "$PYTHON" -m uvicorn "$module" --reload --host "$HOST" --port "$port" &
    else
        "$PYTHON" -m uvicorn "$module" --host "$HOST" --port "$port" &
    fi

    PIDS+=("$!")
}

start_uvicorn "mobile API" "$MOBILE_APP_MODULE" "$MOBILE_PORT"
start_uvicorn "admin API and panel" "$ADMIN_APP_MODULE" "$ADMIN_PORT"

echo
echo "Mobile API:  http://$HOST:$MOBILE_PORT"
echo "Admin docs:  http://$HOST:$ADMIN_PORT/docs"
echo "Admin panel: http://$HOST:$ADMIN_PORT/admin/"
echo "Press Ctrl+C to stop both services."

sleep 1

for pid in "${PIDS[@]}"; do
    if ! jobs -pr | grep -q "^$pid$"; then
        echo "Service with PID $pid stopped during startup."
        exit 1
    fi
done

wait "${PIDS[@]}"
