# Lab Microservices - RestTemplate vs Feign vs WebClient

Ce projet pédagogique compare trois méthodes de communication HTTP entre microservices :
- **RestTemplate** (synchronique, bloquant)
- **Feign** (déclaratif, basé sur des interfaces)
- **WebClient** (réactif, non-bloquant)

## Architecture

Le projet contient 3 modules :

1. **eureka-server** : Serveur de découverte de services (port 8761)
2. **service-voiture** : Microservice exposant l'API des voitures (port 8081)
3. **service-client** : Microservice client consommant l'API voiture avec les 3 méthodes (port 8082)

## Prérequis

- Java 17+
- Maven 3.6+

## Démarrage des services

### Étape 1 : Démarrer Eureka Server

```bash
cd eureka-server
mvn spring-boot:run
```

Vérifier que Eureka est démarré : http://localhost:8761

### Étape 2 : Démarrer Service Voiture

Dans un nouveau terminal :

```bash
cd service-voiture
mvn spring-boot:run
```

Le service s'enregistre automatiquement auprès d'Eureka.

### Étape 3 : Démarrer Service Client

Dans un nouveau terminal :

```bash
cd service-client
mvn spring-boot:run
```

## Tests des endpoints

Une fois tous les services démarrés, vous pouvez tester les trois méthodes :

### 1. RestTemplate
```bash
curl http://localhost:8082/api/clients/1/car/rest
```

### 2. Feign
```bash
curl http://localhost:8082/api/clients/1/car/feign
```

### 3. WebClient
```bash
curl http://localhost:8082/api/clients/1/car/webclient
```

### Test direct du Service Voiture
```bash
curl http://localhost:8081/api/cars/byClient/1
```

## Réponse attendue

```json
{
  "id": 10,
  "marque": "Toyota",
  "modele": "Yaris",
  "clientId": 1
}
```

## Structure du projet

```
microservices-lab/
├── eureka-server/          # Serveur de découverte
├── service-voiture/        # API des voitures
│   ├── controller/         # VoitureController
│   ├── service/            # VoitureService
│   └── model/              # Modèle Voiture
└── service-client/         # Client consommant l'API
    ├── controller/         # ClientController (3 endpoints)
    ├── service/            # VoitureService (3 implémentations)
    ├── feign/              # Interface Feign
    └── config/             # Configuration RestTemplate/WebClient
```

## Parties B, C, D et E - Implémentation complète

Voir les fichiers détaillés :
- **[PARTIE_B_C_D.md](PARTIE_B_C_D.md)** : Parties B, C et D
  - **Partie B** : Implémentation des 3 clients synchrones (RestTemplate, Feign, WebClient)
  - **Partie C** : Configuration Eureka et Consul
  - **Partie D** : Tests de performance avec JMeter
- **[PARTIE_E_MESURES.md](PARTIE_E_MESURES.md)** : Partie E
  - **Partie E** : Mesures CPU/Mémoire (Task Manager, Actuator, Prometheus/Grafana)
- **[LIVRABLES.md](LIVRABLES.md)** : Liste des livrables attendus

### Résumé rapide

**Partie B** : Les 3 méthodes sont déjà implémentées et fonctionnelles
- RestTemplate : `/api/clients/{id}/car/rest`
- Feign : `/api/clients/{id}/car/feign`
- WebClient : `/api/clients/{id}/car/webclient` (mode synchrone avec `block()`)

**Partie C** : Support Eureka (par défaut) et Consul (via profil)
- Eureka : `mvn spring-boot:run` (profil par défaut)
- Consul : `mvn spring-boot:run -Dspring-boot.run.profiles=consul`

**Partie D** : Scripts JMeter disponibles dans `jmeter-tests/`
- Plans de test : `test-resttemplate.jmx`, `test-feign.jmx`, `test-webclient.jmx`
- Scripts d'exécution : `scripts/run-tests.sh` (Linux/Mac) et `run-tests.bat` (Windows)

**Partie E** : Mesures CPU/Mémoire
- Option simple : Task Manager (Windows) ou htop (Linux/Mac)
- Option avancée : Prometheus + Grafana
- Scripts de collecte : `scripts/collect-metrics.sh` et `scripts/monitor-java.sh`

## Notes techniques

- **Délai artificiel** : Le service voiture inclut un délai de 20ms pour rendre les différences de performance plus visibles
- **Service Discovery** : Les services utilisent Eureka pour la résolution automatique des noms de services
- **Load Balancing** : RestTemplate et Feign utilisent `@LoadBalanced` pour la résolution via Eureka
