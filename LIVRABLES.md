# Livrables du Lab - RestTemplate vs Feign vs WebClient

## 📋 Liste des livrables attendus

### 1. Code des 2 services (client + voiture) ✅

**Service Voiture** :
- ✅ Code source complet dans `service-voiture/`
- ✅ Endpoint : `GET /api/cars/byClient/{clientId}`
- ✅ Configuration Eureka et Consul
- ✅ Actuator configuré pour les métriques

**Service Client** :
- ✅ Code source complet dans `service-client/`
- ✅ 3 endpoints (RestTemplate, Feign, WebClient)
- ✅ Configuration Eureka et Consul
- ✅ Actuator configuré pour les métriques

**Structure** :
```
service-voiture/
├── controller/VoitureController.java
├── service/VoitureService.java
└── model/Voiture.java

service-client/
├── controller/ClientController.java
├── service/VoitureService.java
├── feign/VoitureFeignClient.java
└── config/RestTemplateConfig.java
```

### 2. Preuve d'enregistrement (capture Eureka/Consul) 📸

#### Eureka

1. **Démarrer Eureka Server** :
   ```bash
   cd eureka-server
   mvn spring-boot:run
   ```

2. **Accéder à l'UI Eureka** :
   - URL : http://localhost:8761
   - Capturer l'écran montrant :
     - Les services enregistrés : `SERVICE-VOITURE` et `SERVICE-CLIENT`
     - Leur statut (UP)
     - Leurs instances

3. **Exemple de capture attendue** :
   - Section "Instances currently registered with Eureka"
   - Liste des applications avec leurs instances

#### Consul

1. **Démarrer Consul** :
   ```bash
   consul agent -dev
   ```

2. **Démarrer les services avec profil Consul** :
   ```bash
   cd service-voiture
   mvn spring-boot:run -Dspring-boot.run.profiles=consul
   
   cd service-client
   mvn spring-boot:run -Dspring-boot.run.profiles=consul
   ```

3. **Accéder à l'UI Consul** :
   - URL : http://localhost:8500
   - Naviguer vers "Services"
   - Capturer l'écran montrant :
     - Les services : `service-voiture` et `service-client`
     - Leur statut (passing)
     - Leurs health checks

4. **Exemple de capture attendue** :
   - Liste des services avec statut "passing"
   - Détails des health checks

### 3. Résultats de tests (latence, débit, CPU/RAM) 📊

#### Tests de performance JMeter

**Tableau de résultats - Latence et Débit** :

| Méthode | Threads | Temps moyen (ms) | P95 (ms) | Débit (req/s) | Taux d'erreur (%) |
|---------|---------|------------------|----------|---------------|-------------------|
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

**Tableau de résultats - CPU et Mémoire** :

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

**Note** : Séparer les mesures pour Service Voiture et Service Client si nécessaire.

#### Fichiers de résultats JMeter

- Sauvegarder les fichiers `.jtl` générés par JMeter
- Sauvegarder les rapports HTML générés
- Organiser dans un dossier `results/` :
  ```
  results/
  ├── resttemplate_10threads_20240101_120000.jtl
  ├── resttemplate_10threads_20240101_120000_report/
  ├── feign_10threads_20240101_120500.jtl
  └── ...
  ```

### 4. Analyse comparée (1-2 pages) 📝

#### Structure recommandée de l'analyse

**1. Introduction** (1 paragraphe)
- Contexte du lab
- Objectifs de la comparaison

**2. Méthodologie** (1 paragraphe)
- Environnement de test (OS, Java version, etc.)
- Charges testées
- Outils utilisés (JMeter, Task Manager, etc.)

**3. Résultats de performance** (2-3 paragraphes)
- Comparaison des latences
- Comparaison des débits
- Analyse des différences observées

**4. Consommation de ressources** (1-2 paragraphes)
- Comparaison CPU
- Comparaison mémoire
- Impact sur la scalabilité

**5. Avantages et inconvénients** (1 paragraphe)
- RestTemplate : points forts/faibles
- Feign : points forts/faibles
- WebClient : points forts/faibles

**6. Conclusion** (1 paragraphe)
- Recommandations selon les cas d'usage
- Méthode la plus performante dans ce contexte
- Méthode la plus adaptée selon les besoins

#### Exemple de structure détaillée

```markdown
# Analyse Comparée : RestTemplate vs Feign vs WebClient

## 1. Introduction
[Contexte et objectifs]

## 2. Méthodologie
- Environnement : Windows 10, Java 17, Spring Boot 3.2.0
- Tests : JMeter avec 10, 50, 100, 200, 500 threads
- Mesures : Latence, débit, CPU, RAM

## 3. Résultats de Performance

### 3.1 Latence
[Analyse des temps de réponse moyens et P95]

### 3.2 Débit
[Analyse des requêtes par seconde]

## 4. Consommation de Ressources

### 4.1 CPU
[Comparaison de l'utilisation CPU]

### 4.2 Mémoire
[Comparaison de l'utilisation mémoire]

## 5. Comparaison des Méthodes

### 5.1 RestTemplate
- Avantages : [simplicité, compatibilité]
- Inconvénients : [bloquant, maintenance mode]

### 5.2 Feign
- Avantages : [déclaratif, lisibilité]
- Inconvénients : [overhead, compilation]

### 5.3 WebClient
- Avantages : [réactif, non-bloquant]
- Inconvénients : [complexité, courbe d'apprentissage]

## 6. Conclusion
[Recommandations et synthèse]
```

## 📁 Organisation des livrables

Créer un dossier `livrables/` avec :

```
livrables/
├── code/
│   ├── service-voiture/
│   └── service-client/
├── captures/
│   ├── eureka-services.png
│   ├── consul-services.png
│   └── consul-health-checks.png
├── resultats/
│   ├── performance-latence-debit.csv
│   ├── performance-cpu-ram.csv
│   ├── jmeter-results/
│   └── graphs/
└── analyse/
    └── analyse-comparee.md
```

## ✅ Checklist de validation

- [ ] Code source des 2 services complet et fonctionnel
- [ ] Capture d'écran Eureka montrant les services enregistrés
- [ ] Capture d'écran Consul montrant les services enregistrés
- [ ] Tableau de résultats de performance (latence, débit)
- [ ] Tableau de résultats de ressources (CPU, RAM)
- [ ] Fichiers de résultats JMeter sauvegardés
- [ ] Analyse comparée rédigée (1-2 pages)
- [ ] Graphiques de comparaison (optionnel mais recommandé)

## 📊 Outils pour créer les graphiques

- **Excel/Google Sheets** : Pour les tableaux et graphiques simples
- **Python (matplotlib)** : Pour des graphiques plus avancés
- **Grafana** : Si Prometheus est utilisé
- **JMeter HTML Report** : Rapports générés automatiquement

## 💡 Conseils pour l'analyse

1. **Être objectif** : Présenter les faits, pas seulement les préférences
2. **Contextualiser** : Expliquer pourquoi certaines différences existent
3. **Visualiser** : Utiliser des graphiques pour rendre l'analyse plus claire
4. **Conclure** : Donner des recommandations pratiques selon les cas d'usage
