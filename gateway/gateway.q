// ============================================================
// Gateway
// - Listens on port 5013
// - Single entry point for Grafana (and QStudio)
// - Routes queries to RDB (today) or HDB (historical)
// ============================================================

\p 5013

// Connect to RDB and HDB
rdb:hopen `::5011
hdb:hopen `::5012

// Route query to correct process based on date range
// If querying today → RDB, otherwise → HDB
query:{[q]
    if[q like "*today*"; :rdb q];
    if[q like "*date*";  :hdb q];
    rdb q
    }

// Grafana/QStudio calls this to get metrics
// Example: getMetrics[.z.d; .z.d; `cpu_user`cpu_sys]
getMetrics:{[startDate; endDate; cols]
    today:.z.d;
    $[startDate=today;
        // Today only → RDB
        rdb (`getMetrics; startDate; endDate; cols);
        // Historical → HDB
        hdb (`getMetrics; startDate; endDate; cols)
    ]
    }

// Simple passthrough — Grafana sends raw q expressions
.z.pg:{[x] value x}

-1 "Gateway listening on port 5013";
-1 "Connected to RDB (5011) and HDB (5012)";
