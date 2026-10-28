#!/bin/bash

LOG_FILE="logs/system.log"   #will store all previous check too

mkdir -p logs

STATUS_FILE="logs/current_status.tmp" #will only store the currrent check
: > "$STATUS_FILE"  #resets the file on eevery run

check_disk() {
    echo ""
    echo "[ DISK HEALTH CHECK ]"

    df -P | awk 'NR > 1 {
        gsub(/%/, "", $5)
        if ($5 >= 80)
            print "WARNING: " $6 " is " $5 "% full"
        else
            print "FINE: " $6 " is " $5 "% full"
    }'
}


check_memory() {
    echo ""
    echo "[ MEMORY HEALTH CHECK ]"

    free | awk '/Mem:/ {
        usage = ($3 / $2) * 100
        printf "RAM usage: %.1f%%\n", usage

        if (usage >= 80)
            print "WARNING: RAM usage is high"
        else
            print "FINE: RAM usage is normal"
    }'
}


check_service() {
    SERVICE="$1"

    if systemctl is-active --quiet "$SERVICE"; then
        echo "FINE: $SERVICE service is running"
    else
        echo "WARNING: $SERVICE service is not running"
    fi
}


{
    echo "========================================"
    echo "       LINUX SYSTEM HEALTH REPORT"
    echo "========================================"
    echo "Check time : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Hostname   : $(hostname)"
    echo "========================================"

    echo ""
    echo "[ DISK USAGE ]"
    df -h

    check_disk 

    echo ""
    echo "[ MEMORY USAGE ]"
    free -h

    check_memory

    echo ""
    echo "[ CPU LOAD ]"

    uptime
    
    LOAD=$(awk '{print $1}' /proc/loadavg)
    CPU_COUNT=$(nproc)  

    echo "Load average (1 min): $LOAD"
    echo "Logical CPUs: $CPU_COUNT"

    if awk -v cpu_load="$LOAD" -v cpus="$CPU_COUNT" 'BEGIN { exit !(cpu_load >= cpus * 0.8) }'
    then
        echo "WARNING: CPU load is high"
    else
        echo "FINE: CPU load is normal"
    fi
 
    #add wtever service you want to check in future here
    check_service cron
    check_service ssh

    echo ""
    echo "============== END OF REPORT ==========="
    echo ""


} 2>&1 | tee -a "$LOG_FILE" | tee "$STATUS_FILE" > /dev/null #storing it to log file and temp file

#only displays the fine/warning texts
    echo "===== DISK CHECK ====="
    grep -E "WARNING:|FINE:" "$STATUS_FILE" | grep -E "full"

    echo ""
    echo "===== RAM CHECK ====="
    grep -E "RAM usage" "$STATUS_FILE"| grep -E "WARNING: RAM|FINE: RAM" "$STATUS_FILE"

    echo ""
    echo "===== CPU CHECK ====="
    grep -E "CPU load is" "$STATUS_FILE"

    echo ""
    echo "===== SERVICE CHECK ====="
    grep -E "service is running|service is not running" "$STATUS_FILE"