#!/bin/bash

# Script pour exécuter les tests de performance JMeter
# Usage: ./run-tests.sh [rest|feign|webclient] [threads] [loops]

METHOD=${1:-rest}
THREADS=${2:-10}
LOOPS=${3:-50}

echo "========================================="
echo "Test de performance: $METHOD"
echo "Threads: $THREADS"
echo "Loops: $LOOPS"
echo "========================================="

# Vérifier que JMeter est installé
if ! command -v jmeter &> /dev/null; then
    echo "JMeter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Déterminer le fichier JMX
JMX_FILE=""
case $METHOD in
    rest)
        JMX_FILE="../test-resttemplate.jmx"
        ;;
    feign)
        JMX_FILE="../test-feign.jmx"
        ;;
    webclient)
        JMX_FILE="../test-webclient.jmx"
        ;;
    *)
        echo "Méthode inconnue: $METHOD"
        echo "Utilisez: rest, feign, ou webclient"
        exit 1
        ;;
esac

# Vérifier que le fichier existe
if [ ! -f "$JMX_FILE" ]; then
    echo "Fichier JMX non trouvé: $JMX_FILE"
    exit 1
fi

# Créer le répertoire de résultats
RESULTS_DIR="../results"
mkdir -p "$RESULTS_DIR"

# Nom du fichier de résultats
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_FILE="$RESULTS_DIR/${METHOD}_${THREADS}threads_${TIMESTAMP}.jtl"
REPORT_DIR="$RESULTS_DIR/${METHOD}_${THREADS}threads_${TIMESTAMP}_report"

echo "Exécution du test..."
echo "Résultats: $RESULT_FILE"
echo ""

# Exécuter JMeter
jmeter -n -t "$JMX_FILE" \
    -JTHREADS=$THREADS \
    -JLOOPS=$LOOPS \
    -JRAMP_UP=10 \
    -l "$RESULT_FILE" \
    -e -o "$REPORT_DIR"

echo ""
echo "========================================="
echo "Test terminé!"
echo "Résultats: $RESULT_FILE"
echo "Rapport HTML: $REPORT_DIR/index.html"
echo "========================================="
