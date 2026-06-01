// ============================================================
// Tickerplant (TP)
// - Listens on port 5010
// - Receives metrics from collector
// - Logs to disk
// - Fans out to all subscribers (RDB etc.)
// ============================================================

// Port
\p 5010

// Log file path (binary, written via -1)
logfile:"tickerplant/tp.log"

// Subscriber list: list of handles
.u.w:()

// Schema of metrics table
metrics:([]
    time:`timestamp$();
    cpu_user:`float$();
    cpu_sys:`float$();
    mem_used:`long$();
    mem_free:`long$();
    disk_read:`long$();
    disk_write:`long$();
    net_in:`long$();
    net_out:`long$()
    )

// Subscribe: RDB calls this on startup — adds its handle to subscriber list
.u.sub:{[tbl]
    .u.w,:enlist .z.w;
    }

// Publish: collector sends (tbl;data) — fan out to all subscribers
.u.pub:{[tbl;data]
    {[h;t;d] neg[h] (`.u.upd; t; d)}[;tbl;data] each .u.w;
    }

// Upd: called on TP itself for local insert (optional)
.u.upd:{[tbl;data] insert[tbl;data]}

// Clean up dead subscribers
.z.pc:{.u.w:.u.w except enlist x}

-1 "Tickerplant listening on port 5010";
