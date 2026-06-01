// ============================================================
// Collector
// - Polls system metrics every 1 second
// - Supports macOS (m64) and Linux (l64)
// - Sends each row to the Tickerplant on port 5010
// ============================================================

tp:hopen `::5010

// Detect OS: `m64 = macOS, `l64 = Linux
os:first string .z.o
-1 "Detected OS: ",string .z.o;

// ============================================================
// CPU
// ============================================================

getCPU_mac:{
    // "CPU usage: 12.93% user, 22.23% sys, 64.83% idle"
    raw:first system "top -l 1 -n 0 | grep 'CPU usage'";
    tokens:" " vs raw;
    user:first "F"$"%" vs tokens[2];
    sys :first "F"$"%" vs tokens[4];
    (user%100; sys%100)
    }

getCPU_linux:{
    // /proc/stat first line: "cpu user nice sys idle ..."
    raw:" " vs first system "head -1 /proc/stat";
    vals:"J"$raw where not raw like "cpu*";
    user:vals 0; sys:vals 2; idle:vals 3;
    total:sum vals;
    (user%total; sys%total)
    }

getCPU:$[os="m"; getCPU_mac; getCPU_linux]

// ============================================================
// Memory
// ============================================================

getMem_mac:{
    raw:system "vm_stat";
    getPages:{[raw;k]
        line:first raw where raw like "*",k,"*";
        if[0=count line; :0];
        4096 * "J"$last " " vs line
        };
    used:getPages[raw;"Pages active:"];
    free:getPages[raw;"Pages free:"];
    (used;free)
    }

getMem_linux:{
    raw:system "cat /proc/meminfo";
    getKB:{[raw;k]
        line:first raw where raw like k,"*";
        if[0=count line; :0];
        1024 * "J"$first " " vs (last " " vs line)
        };
    total:getKB[raw;"MemTotal"];
    free: getKB[raw;"MemAvailable"];
    used: total - free;
    (used;free)
    }

getMem:$[os="m"; getMem_mac; getMem_linux]

// ============================================================
// Disk
// ============================================================

getDisk_mac:{
    raw:system "iostat -d disk0 2 1 | tail -1";
    if[0=count raw; :(0;0)];
    vals:"F"$" " vs first raw;
    vals:vals where not null vals;
    read: `long$$[2<=count vals; 1024*1024*vals 2; 0f];
    write:`long$$[3<=count vals; 1024*1024*vals 3; 0f];
    (read;write)
    }

getDisk_linux:{
    // /proc/diskstats: find first real disk (sda or nvme0n1)
    raw:system "cat /proc/diskstats";
    line:first raw where (raw like "* sda *") or (raw like "* nvme0n1 *");
    if[0=count line; :(0;0)];
    vals:"J"$" " vs line;
    vals:vals where not null vals;
    // fields: major minor name rio rmerge rsect rms wio wmerge wsect wms
    read: `long$$[5<=count vals; 512*vals 5; 0];
    write:`long$$[9<=count vals; 512*vals 9; 0];
    (read;write)
    }

getDisk:$[os="m"; getDisk_mac; getDisk_linux]

// ============================================================
// Network
// ============================================================

getNet_mac:{
    raw:system "netstat -ib | grep -e 'en0' | head -1";
    if[0=count raw; :(0;0)];
    vals:"J"$" " vs first raw;
    vals:vals where not null vals;
    inn:$[4<=count vals; vals 4; 0];
    out:$[6<=count vals; vals 6; 0];
    (inn;out)
    }

getNet_linux:{
    // /proc/net/dev: find eth0 or ens3 or enp0s3
    raw:system "cat /proc/net/dev";
    line:first raw where (raw like "*eth0*") or (raw like "*ens*") or (raw like "*enp*");
    if[0=count line; :(0;0)];
    vals:"J"$" " vs line;
    vals:vals where not null vals;
    inn:$[0<count vals; vals 0; 0];
    out:$[8<=count vals; vals 8; 0];
    (inn;out)
    }

getNet:$[os="m"; getNet_mac; getNet_linux]

// ============================================================
// Collect and publish
// ============================================================

collect:{
    ts:.z.p;
    cpu:getCPU[];
    mem:getMem[];
    disk:getDisk[];
    net:getNet[];
    row:(enlist ts),(cpu),(mem),(disk),(net);
    neg[tp] (`.u.pub; `metrics; row);
    -1 "published row at ",(string ts);
    }

.z.ts:{collect[]}
\t 1000

-1 "Collector started — pushing to TP on port 5010";
