#!/bin/bash
# Script de collecte automatique des métriques via Actuator

SERVICE_VOITURE="http://localhost:8081/actuator/metrics"
SERVICE_CLIENT="http://localhost:8082/actuator/metrics"
INTERVAL=5

echo "Collecte des métriques toutes les ${INTERVAL} secondes..."
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

# Vérifier que bc est installé
if ! command -v bc &> /dev/null; then
    echo "Erreur: 'bc' n'est pas installé. Installez-le avec: sudo apt-get install bc"
    exit 1
fi

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== $TIMESTAMP ==="
    
    # Service Voiture
    echo "Service Voiture:"
    MEM_USED=$(curl -s "$SERVICE_VOITURE/jvm.memory.used" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    MEM_MAX=$(curl -s "$SERVICE_VOITURE/jvm.memory.max" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    CPU=$(curl -s "$SERVICE_VOITURE/process.cpu.usage" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    
    if [ ! -z "$MEM_USED" ] && [ ! -z "$MEM_MAX" ]; then
        MEM_USED_MB=$(echo "scale=2; $MEM_USED / 1024 / 1024" | bc)
        MEM_MAX_MB=$(echo "scale=2; $MEM_MAX / 1024 / 1024" | bc)
        MEM_PCT=$(echo "scale=2; ($MEM_USED / $MEM_MAX) * 100" | bc)
        if [ ! -z "$CPU" ]; then
            CPU_PCT=$(echo "scale=2; $CPU * 100" | bc)
            echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB (${MEM_PCT}%)"
            echo "  CPU: ${CPU_PCT}%"
        else
            echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB (${MEM_PCT}%)"
            echo "  CPU: N/A"
        fi
    else
        echo "  Service non disponible"
    fi
    
    # Service Client
    echo "Service Client:"
    MEM_USED=$(curl -s "$SERVICE_CLIENT/jvm.memory.used" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    MEM_MAX=$(curl -s "$SERVICE_CLIENT/jvm.memory.max" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    CPU=$(curl -s "$SERVICE_CLIENT/process.cpu.usage" 2>/dev/null | grep -o '"value":[0-9.]*' | cut -d: -f2 | head -1)
    
    if [ ! -z "$MEM_USED" ] && [ ! -z "$MEM_MAX" ]; then
        MEM_USED_MB=$(echo "scale=2; $MEM_USED / 1024 / 1024" | bc)
        MEM_MAX_MB=$(echo "scale=2; $MEM_MAX / 1024 / 1024" | bc)
        MEM_PCT=$(echo "scale=2; ($MEM_USED / $MEM_MAX) * 100" | bc)
        if [ ! -z "$CPU" ]; then
            CPU_PCT=$(echo "scale=2; $CPU * 100" | bc)
            echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB (${MEM_PCT}%)"
            echo "  CPU: ${CPU_PCT}%"
        else
            echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB (${MEM_PCT}%)"
            echo "  CPU: N/A"
        fi
    else
        echo "  Service non disponible"
    fi
    
    echo ""
    sleep $INTERVAL
done
