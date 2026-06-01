#!/bin/bash
# Stop all KDB+ processes by killing their ports

echo "Stopping all KDB+ processes..."
lsof -ti:5010 | xargs kill -9 2>/dev/null && echo "  Tickerplant (5010) stopped"
lsof -ti:5011 | xargs kill -9 2>/dev/null && echo "  RDB (5011) stopped"
lsof -ti:5012 | xargs kill -9 2>/dev/null && echo "  HDB (5012) stopped"
lsof -ti:5013 | xargs kill -9 2>/dev/null && echo "  Gateway (5013) stopped"
pkill -f "collector.q" 2>/dev/null && echo "  Collector stopped"
echo "Done."
