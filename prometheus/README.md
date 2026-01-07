# Configuration Prometheus

## Installation

### Linux/Mac

1. **Télécharger Prometheus** :
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
   tar xvfz prometheus-*.tar.gz
   cd prometheus-*
   ```

2. **Copier la configuration** :
   ```bash
   cp ../prometheus.yml .
   ```

3. **Démarrer Prometheus** :
   ```bash
   ./prometheus --config.file=prometheus.yml
   ```

4. **Accéder à l'UI** : http://localhost:9090

### Windows

1. **Télécharger Prometheus** :
   - Télécharger depuis : https://prometheus.io/download/
   - Extraire dans un dossier

2. **Copier la configuration** :
   - Copier `prometheus.yml` dans le dossier Prometheus

3. **Démarrer Prometheus** :
   ```cmd
   prometheus.exe --config.file=prometheus.yml
   ```

4. **Accéder à l'UI** : http://localhost:9090

## Configuration

Le fichier `prometheus.yml` configure Prometheus pour scraper les métriques des deux services :

- **Service Voiture** : http://localhost:8081/actuator/prometheus
- **Service Client** : http://localhost:8082/actuator/prometheus

## Requêtes Prometheus utiles

Une fois Prometheus démarré, vous pouvez exécuter des requêtes dans l'interface :

### CPU
```
process_cpu_usage{application="service-voiture"}
process_cpu_usage{application="service-client"}
```

### Mémoire
```
jvm_memory_used_bytes{area="heap",application="service-voiture"}
jvm_memory_max_bytes{area="heap",application="service-voiture"}
```

### Requêtes HTTP
```
http_server_requests_seconds_count{application="service-client"}
```

## Intégration avec Grafana

1. **Installer Grafana** (voir PARTIE_E_MESURES.md)
2. **Ajouter Prometheus comme source de données** :
   - URL : http://localhost:9090
3. **Créer un dashboard** avec les métriques CPU et mémoire
