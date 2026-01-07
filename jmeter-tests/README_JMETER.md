# Guide des Tests de Performance avec JMeter

## Objectif

Comparer les performances de trois méthodes de communication HTTP :
- RestTemplate
- Feign
- WebClient (en mode synchrone)

## Prérequis

- JMeter installé (https://jmeter.apache.org/download_jmeter.cgi)
- Les services démarrés :
  - Eureka Server (port 8761)
  - Service Voiture (port 8081)
  - Service Client (port 8082)

## Configuration des Tests

### Endpoints à tester

1. **RestTemplate** : `http://localhost:8082/api/clients/1/car/rest`
2. **Feign** : `http://localhost:8082/api/clients/1/car/feign`
3. **WebClient** : `http://localhost:8082/api/clients/1/car/webclient`

### Charges recommandées

Pour chaque méthode, tester avec :
- 10 utilisateurs simultanés
- 50 utilisateurs simultanés
- 100 utilisateurs simultanés
- 200 utilisateurs simultanés
- 500 utilisateurs simultanés (ou 300 si la machine est saturée)

### Métriques à collecter

Pour chaque test, noter :
- **Temps moyen de réponse** (ms)
- **P95** (95ème percentile) - optionnel mais recommandé
- **Débit** (requêtes/seconde)
- **Taux d'erreur** (%)

## Création du Plan de Test JMeter

### Étape 1 : Créer un Thread Group

1. Clic droit sur "Test Plan" → Add → Threads (Users) → Thread Group
2. Configurer :
   - **Number of Threads** : 10 (commencer petit)
   - **Ramp-up Period** : 10 secondes
   - **Loop Count** : 50 (ou "Forever" avec Duration)

### Étape 2 : Ajouter HTTP Request Sampler

1. Clic droit sur Thread Group → Add → Sampler → HTTP Request
2. Configurer :
   - **Server Name** : localhost
   - **Port Number** : 8082
   - **Path** : `/api/clients/1/car/rest` (ou `/feign` ou `/webclient`)

### Étape 3 : Ajouter des Listeners

1. **View Results Tree** : Pour voir les réponses individuelles (désactiver en production)
2. **Summary Report** : Pour les statistiques
3. **Aggregate Report** : Pour les métriques détaillées
4. **Response Times Over Time** : Graphique des temps de réponse

### Étape 4 : Répéter pour chaque méthode

Créer 3 Thread Groups séparés (un par méthode) ou utiliser des variables.

## Exécution des Tests

### Test avec Eureka

1. Démarrer Eureka Server
2. Démarrer Service Voiture
3. Démarrer Service Client (profil Eureka)
4. Exécuter les tests JMeter
5. Noter les résultats

### Test avec Consul

1. Démarrer Consul : `consul agent -dev` (ou via Docker)
2. Démarrer Service Voiture avec profil Consul : `mvn spring-boot:run -Dspring-boot.run.profiles=consul`
3. Démarrer Service Client avec profil Consul : `mvn spring-boot:run -Dspring-boot.run.profiles=consul`
4. Exécuter les mêmes tests JMeter
5. Comparer les résultats avec Eureka

## Scripts de Test Automatisés

Voir les fichiers `.jmx` dans ce répertoire pour des plans de test pré-configurés.

## Analyse des Résultats

### Comparaison attendue

Les résultats peuvent varier selon :
- La charge système
- La latence réseau locale
- Les performances de la JVM

### Points d'attention

- **RestTemplate** : Bloquant, peut avoir une latence plus élevée sous charge
- **Feign** : Génère du code à la compilation, peut être plus rapide
- **WebClient** : Même en mode synchrone, peut avoir des différences de performance

## Conseils

1. **Échauffement** : Lancer quelques requêtes avant les tests pour "chauffer" la JVM
2. **Isolation** : Tester une méthode à la fois pour éviter les interférences
3. **Reproductibilité** : Noter les conditions (CPU, mémoire, autres processus)
4. **Durée** : Chaque test devrait durer au moins 1-2 minutes pour des résultats stables
