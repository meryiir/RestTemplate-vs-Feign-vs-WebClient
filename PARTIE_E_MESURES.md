# Partie E — Mesures CPU / Mémoire

## Objectif

Mesurer la consommation CPU et mémoire des services pendant les tests de performance pour comparer les trois méthodes de communication HTTP (RestTemplate, Feign, WebClient).

## Étape E1 — Mesure simple (sans outils lourds)

### Option 1 : Via Task Manager / htop

#### Windows - Task Manager

1. **Ouvrir le Gestionnaire des tâches** :
   - `Ctrl + Shift + Esc` ou `Ctrl + Alt + Del` → Gestionnaire des tâches
   - Onglet "Détails"

2. **Identifier les processus Java** :
   - Chercher les processus `java.exe` correspondant à :
     - `service-voiture` (port 8081)
     - `service-client` (port 8082)

3. **Noter les métriques** :
   - **CPU (%)** : Colonne "CPU"
   - **Mémoire (MB)** : Colonne "Mémoire (ensemble de travail privé)" ou "Mémoire"

4. **Pendant les tests JMeter** :
   - Lancer un test avec 100/200/500 threads
   - Observer les valeurs CPU et RAM
   - Noter les valeurs moyennes et maximales

#### Linux/Mac - htop ou top

1. **Installer htop** (si nécessaire) :
   ```bash
   # Ubuntu/Debian
   sudo apt-get install htop
   
   # Mac
   brew install htop
   ```

2. **Lancer htop** :
   ```bash
   htop
   ```

3. **Identifier les processus Java** :
   - Chercher les processus `java` avec les arguments contenant :
     - `service-voiture`
     - `service-client`

4. **Noter les métriques** :
   - **CPU (%)** : Colonne "%CPU"
   - **Mémoire (MB)** : Colonne "RES" (Résident) ou "MEM%"

5. **Pendant les tests JMeter** :
   - Lancer un test avec 100/200/500 threads
   - Observer les valeurs en temps réel
   - Noter les valeurs moyennes et maximales

#### Script d'aide pour Linux/Mac

Créer un script pour surveiller automatiquement :

```bash
#!/bin/bash
# monitor-java.sh

while true; do
    echo "=== $(date) ==="
    ps aux | grep java | grep -E "(service-voiture|service-client)" | awk '{print $2, $3"% CPU", $4"% MEM", $6/1024" MB"}'
    sleep 5
done
```

### Option 2 : Via Spring Boot Actuator (métriques JVM)

#### Accéder aux métriques

1. **Métriques JVM disponibles** :
   ```
   http://localhost:8081/actuator/metrics/jvm.memory.used
   http://localhost:8081/actuator/metrics/jvm.memory.max
   http://localhost:8081/actuator/metrics/process.cpu.usage
   http://localhost:8081/actuator/metrics/system.cpu.usage
   ```

2. **Exemple de réponse** :
   ```json
   {
     "name": "jvm.memory.used",
     "measurements": [
       {
         "statistic": "VALUE",
         "value": 157286400
       }
     ],
     "availableTags": []
   }
   ```
   (Valeur en bytes, diviser par 1024² pour obtenir MB)

3. **Métriques utiles** :
   - `jvm.memory.used` : Mémoire utilisée (heap + non-heap)
   - `jvm.memory.max` : Mémoire maximale disponible
   - `jvm.memory.committed` : Mémoire allouée
   - `process.cpu.usage` : Utilisation CPU du processus
   - `system.cpu.usage` : Utilisation CPU système

#### Script de collecte automatique

```bash
#!/bin/bash
# collect-metrics.sh

SERVICE_VOITURE="http://localhost:8081/actuator/metrics"
SERVICE_CLIENT="http://localhost:8082/actuator/metrics"

echo "Collecte des métriques toutes les 5 secondes..."
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

while true; do
    echo "=== $(date) ==="
    
    # Service Voiture
    echo "Service Voiture:"
    MEM_USED=$(curl -s "$SERVICE_VOITURE/jvm.memory.used" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    MEM_MAX=$(curl -s "$SERVICE_VOITURE/jvm.memory.max" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    CPU=$(curl -s "$SERVICE_VOITURE/process.cpu.usage" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    
    if [ ! -z "$MEM_USED" ]; then
        MEM_USED_MB=$(echo "$MEM_USED / 1024 / 1024" | bc)
        MEM_MAX_MB=$(echo "$MEM_MAX / 1024 / 1024" | bc)
        CPU_PCT=$(echo "$CPU * 100" | bc)
        echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB"
        echo "  CPU: ${CPU_PCT}%"
    fi
    
    # Service Client
    echo "Service Client:"
    MEM_USED=$(curl -s "$SERVICE_CLIENT/jvm.memory.used" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    MEM_MAX=$(curl -s "$SERVICE_CLIENT/jvm.memory.max" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    CPU=$(curl -s "$SERVICE_CLIENT/process.cpu.usage" | grep -o '"value":[0-9.]*' | cut -d: -f2)
    
    if [ ! -z "$MEM_USED" ]; then
        MEM_USED_MB=$(echo "$MEM_USED / 1024 / 1024" | bc)
        MEM_MAX_MB=$(echo "$MEM_MAX / 1024 / 1024" | bc)
        CPU_PCT=$(echo "$CPU * 100" | bc)
        echo "  Mémoire: ${MEM_USED_MB} MB / ${MEM_MAX_MB} MB"
        echo "  CPU: ${CPU_PCT}%"
    fi
    
    echo ""
    sleep 5
done
```

## Étape E2 — Option avancée : Prometheus + Grafana

### Installation

#### Prometheus

1. **Télécharger Prometheus** :
   ```bash
   # Linux/Mac
   wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
   tar xvfz prometheus-*.tar.gz
   cd prometheus-*
   ```

2. **Créer la configuration** (`prometheus.yml`) :
   ```yaml
   global:
     scrape_interval: 15s

   scrape_configs:
     - job_name: 'service-voiture'
       metrics_path: '/actuator/prometheus'
       static_configs:
         - targets: ['localhost:8081']
     
     - job_name: 'service-client'
       metrics_path: '/actuator/prometheus'
       static_configs:
         - targets: ['localhost:8082']
   ```

3. **Démarrer Prometheus** :
   ```bash
   ./prometheus --config.file=prometheus.yml
   ```
   Accès : http://localhost:9090

#### Grafana

1. **Installer Grafana** :
   ```bash
   # Ubuntu/Debian
   sudo apt-get install -y software-properties-common
   sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
   sudo apt-get update
   sudo apt-get install grafana
   
   # Mac
   brew install grafana
   ```

2. **Démarrer Grafana** :
   ```bash
   # Linux
   sudo systemctl start grafana-server
   
   # Mac
   brew services start grafana
   ```
   Accès : http://localhost:3000 (admin/admin)

3. **Configurer la source de données** :
   - Ajouter Prometheus comme source de données
   - URL : http://localhost:9090

4. **Créer un dashboard** :
   - Importer ou créer des graphiques pour :
     - CPU usage : `process_cpu_usage`
     - Memory used : `jvm_memory_used_bytes`
     - Memory max : `jvm_memory_max_bytes`
     - HTTP requests : `http_server_requests_seconds_count`

### Métriques Prometheus disponibles

Une fois Prometheus configuré, accéder aux métriques via :
- Service Voiture : http://localhost:8081/actuator/prometheus
- Service Client : http://localhost:8082/actuator/prometheus

**Métriques utiles** :
- `jvm_memory_used_bytes{area="heap"}` : Mémoire heap utilisée
- `jvm_memory_max_bytes{area="heap"}` : Mémoire heap maximale
- `process_cpu_usage` : Utilisation CPU du processus
- `system_cpu_usage` : Utilisation CPU système
- `http_server_requests_seconds_count` : Nombre de requêtes HTTP

## Protocole de mesure

### 1. Préparation

1. Démarrer tous les services (Eureka, Service Voiture, Service Client)
2. Attendre que les services soient stables (2-3 minutes)
3. Noter les valeurs de base (CPU et RAM au repos)

### 2. Tests avec différentes charges

Pour chaque méthode (RestTemplate, Feign, WebClient) et chaque charge (10, 50, 100, 200, 500 threads) :

1. **Avant le test** :
   - Noter CPU et RAM de base
   - Vérifier que les services sont stables

2. **Pendant le test** :
   - Lancer le test JMeter
   - Observer CPU et RAM toutes les 5-10 secondes
   - Noter les valeurs maximales

3. **Après le test** :
   - Attendre 30 secondes après la fin du test
   - Noter les valeurs finales
   - Noter le temps de retour à la normale

### 3. Tableau de collecte

| Méthode | Threads | CPU Max (%) | RAM Max (MB) | CPU Moyen (%) | RAM Moyen (MB) |
|---------|---------|-------------|--------------|---------------|----------------|
| RestTemplate | 10 | | | | |
| RestTemplate | 50 | | | | |
| RestTemplate | 100 | | | | |
| RestTemplate | 200 | | | | |
| RestTemplate | 500 | | | | |
| Feign | 10 | | | | |
| Feign | 50 | | | | |
| Feign | 100 | | | | |
| Feign | 200 | | | | |
| Feign | 500 | | | | |
| WebClient | 10 | | | | |
| WebClient | 50 | | | | |
| WebClient | 100 | | | | |
| WebClient | 200 | | | | |
| WebClient | 500 | | | | |

**Note** : Séparer les mesures pour Service Voiture et Service Client.

## Conseils

1. **Isolation** : Tester une méthode à la fois pour éviter les interférences
2. **Repos** : Attendre 1-2 minutes entre chaque test pour laisser les services se stabiliser
3. **Environnement** : Noter les conditions (autres processus, CPU disponible, etc.)
4. **Reproductibilité** : Répéter les tests 2-3 fois et prendre la moyenne

## Métriques Actuator disponibles

### Endpoints utiles

- `/actuator/metrics` : Liste toutes les métriques disponibles
- `/actuator/metrics/{metric.name}` : Détails d'une métrique
- `/actuator/prometheus` : Format Prometheus (si activé)
- `/actuator/health` : État de santé du service

### Exemples de requêtes

```bash
# Liste des métriques
curl http://localhost:8081/actuator/metrics

# Mémoire utilisée
curl http://localhost:8081/actuator/metrics/jvm.memory.used

# CPU usage
curl http://localhost:8081/actuator/metrics/process.cpu.usage

# Format Prometheus
curl http://localhost:8081/actuator/prometheus
```
