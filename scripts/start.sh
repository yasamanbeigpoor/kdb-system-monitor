#!/bin/bash
# Start all KDB+ processes in order

# Find q binary automatically from PATH, fallback to common locations
if command -v q &>/dev/null; then
    Q=$(which q)
elif [ -f "$HOME/q/m64/q" ]; then
    Q="$HOME/q/m64/q"
elif [ -f "$HOME/q/l64/q" ]; then
    Q="$HOME/q/l64/q"
else
    echo "ERROR: q binary not found. Add q to your PATH."
    exit 1
fi

# Root is wherever this script lives (one level up)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Starting KDB+ System Monitor..."

# 1. Tickerplant
echo "[1/5] Starting Tickerplant on port 5010..."
$Q $ROOT/tickerplant/tp.q -q &
sleep 3

# 2. RDB
echo "[2/5] Starting RDB on port 5011..."
$Q $ROOT/rdb/rdb.q -q &
sleep 3

# 3. HDB
echo "[3/5] Starting HDB on port 5012..."
$Q $ROOT/hdb/hdb.q -q &
sleep 2

# 4. Gateway
echo "[4/5] Starting Gateway on port 5013..."
$Q $ROOT/gateway/gateway.q -q &
sleep 2

# 5. Collector
echo "[5/5] Starting Collector..."
$Q $ROOT/collector/collector.q -q &

echo ""
echo "All processes running!"
echo "  Tickerplant : port 5010"
echo "  RDB         : port 5011"
echo "  HDB         : port 5012"
echo "  Gateway     : port 5013"
echo ""
echo "Connect QStudio to localhost:5011 to browse live data"
echo "To stop everything: bash scripts/stop.sh"
