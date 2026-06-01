// ============================================================
// Real-Time Database (RDB)
// - Listens on port 5011
// - Subscribes to Tickerplant on port 5010
// - Holds today's data in memory
// - At midnight: saves to HDB and clears memory
// ============================================================

\p 5011

// Connect to tickerplant
tp:hopen `::5010

// Schema — mirrors what TP publishes
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

// Called by TP to push new rows
.u.upd:{[tbl;data]
    insert[tbl; data]
    }

// Subscribe to tickerplant — call sub on TP passing table name
tp (`.u.sub; `metrics)

// -- End of Day: save to HDB --
eod:{
    dt:.z.d;
    -1 "EOD: saving ",string[dt]," to HDB...";
    // Create date partition folder
    path:`$"hdb/",string[dt],"/metrics/";
    // Save table to disk as splayed table
    .[path; (); :; metrics];
    // Clear in-memory table for new day
    delete from `metrics;
    -1 "EOD: done.";
    }

// Schedule EOD at midnight
.z.ts:{if[.z.T within 00:00:00.000 00:00:01.000; eod[]]}
\t 60000

-1 "RDB listening on port 5011, subscribed to TP on 5010";
