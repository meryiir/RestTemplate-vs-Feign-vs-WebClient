#!/bin/bash
# Script pour surveiller les processus Java avec ps

echo "Surveillance des processus Java (service-voiture et service-client)"
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

while true; do
    clear
    echo "=== $(date) ==="
    echo ""
    echo "Processus Java:"
    ps aux | grep java | grep -E "(service-voiture|service-client)" | grep -v grep | awk '{printf "PID: %-8s CPU: %6s%% MEM: %6s%% RAM: %8.2f MB  CMD: %s\n", $2, $3, $4, $6/1024, $11" "$12" "$13" "$14" "$15" "$16" "$17" "$18" "$19" "$20" "$21}'
    echo ""
    sleep 5
done
