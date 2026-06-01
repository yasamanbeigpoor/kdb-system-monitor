# kdb-system-monitor

Real-time system metrics monitor built with KDB+/q and Grafana.

Tracks CPU, memory, disk and network stats on your local machine using a full KDB+ tickerplant architecture (TP → RDB → HDB) with a Grafana dashboard for visualization.

## Architecture
- **Collector** — polls macOS system metrics every 1s
- **Tickerplant** — receives and fans out live data
- **RDB** — holds today's data in memory
- **HDB** — partitioned on-disk historical data
- **Gateway** — single query entry point for Grafana

## Stack
- KDB+/q 4.1
- Grafana
- macOS
