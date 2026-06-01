# kdb-system-monitor

Real-time system metrics monitor built with KDB+/q and Grafana.

Tracks CPU, memory, disk and network stats on your local machine using a full KDB+ tickerplant architecture (TP → RDB → HDB) with a Grafana dashboard for visualization.

## Architecture
- **Collector** — polls system metrics every 1s (macOS + Linux)
- **Tickerplant** — receives and fans out live data
- **RDB** — holds today's data in memory
- **HDB** — partitioned on-disk historical data
- **Gateway** — single query entry point for Grafana

## Supported OS
- macOS ✅
- Linux ✅
- Windows ❌ (not supported)

## Storage Estimates
At 1 row/second, approximate disk usage for the HDB:

| Timeframe | Rows | Size |
|---|---|---|
| 1 hour | ~3,600 | ~350 KB |
| 1 day | ~86,400 | ~8 MB |
| 1 month | ~2.6M | ~250 MB |
| 1 year | ~31M | ~3 GB |

## Stack
- KDB+/q 4.1
- Grafana
