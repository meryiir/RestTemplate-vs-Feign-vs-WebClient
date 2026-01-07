# Partie B, C et D - Guide d'Implémentation

## Partie B — Implémentation des 3 clients synchrones

### ✅ B1 — RestTemplate (synchrone classique)

**Implémentation** : `service-client/src/main/java/com/example/client/config/RestTemplateConfig.java`

- Bean `RestTemplate` annoté `@LoadBalanced` pour la résolution automatique via Eureka/Consul
- Utilisation dans `VoitureService.getVoitureByRestTemplate()`

**Validation** :
```bash
curl http://localhost:8082/api/clients/1/car/rest
```

**Remarque** : RestTemplate est simple mais considéré comme "ancien" dans les projets récents. Il reste utile pour comprendre la base du HTTP synchrone.

### ✅ B2 — Feign Client (déclaratif)

**Implémentation** : 
- Interface : `service-client/src/main/java/com/example/client/feign/VoitureFeignClient.java`
- Activation : `@EnableFeignClients` dans `ServiceClientApplication`

**Validation** :
```bash
curl http://localhost:8082/api/clients/1/car/feign
```

**Avantages** : Feign réduit fortement le code - pas de build d'URL manuel, pas de logique HTTP bas niveau. Très apprécié pour la lisibilité en microservices.

### ✅ B3 — WebClient (utilisé en synchrone)

**Implémentation** : `service-client/src/main/java/com/example/client/service/VoitureService.java`

- WebClient.Builder annoté `@LoadBalanced`
- Utilisation de `.block()` pour rendre l'appel synchrone (mode sync du TP)

**Validation** :
```bash
curl http://localhost:8082/api/clients/1/car/webclient
```

**Remarque importante** : WebClient est un client réactif. Le lab l'utilise en "synchrone" via `block()` pour comparer à armes égales. En production, il est souvent utilisé en non-bloquant.

---

## Partie C — Découverte de services : Eureka puis Consul

### ✅ C1 — Mode Eureka

**Configuration** :
- Eureka Server : `eureka-server` (port 8761)
- Services configurés avec profil `eureka` (par défaut)

**Démarrage** :
```bash
# Terminal 1 : Eureka Server
cd eureka-server
mvn spring-boot:run

# Terminal 2 : Service Voiture
cd service-voiture
mvn spring-boot:run

# Terminal 3 : Service Client
cd service-client
mvn spring-boot:run
```

**Validation** :
- Eureka UI : http://localhost:8761
- Vérifier que `SERVICE-CLIENT` et `SERVICE-VOITURE` apparaissent
- Les endpoints fonctionnent avec URL par nom : `http://service-voiture/...`

### ✅ C2 — Mode Consul (migration)

**Prérequis** : Consul doit être installé et démarré
```bash
# Option 1 : Consul en mode dev
consul agent -dev

# Option 2 : Docker
docker run -d -p 8500:8500 consul
```

**Configuration** :
- Profils Spring créés : `application-consul.properties`
- Dépendances Consul ajoutées dans les POMs

**Démarrage avec Consul** :
```bash
# Terminal 1 : Consul (si pas déjà démarré)
consul agent -dev

# Terminal 2 : Service Voiture avec profil Consul
cd service-voiture
mvn spring-boot:run -Dspring-boot.run.profiles=consul

# Terminal 3 : Service Client avec profil Consul
cd service-client
mvn spring-boot:run -Dspring-boot.run.profiles=consul
```

**Validation** :
- Consul UI : http://localhost:8500
- Vérifier que les 2 services sont en état "passing"
- Les endpoints côté Service Client fonctionnent exactement pareil

**Migration Eureka → Consul** :
1. Démarrer Consul
2. Arrêter les services
3. Redémarrer avec profil `consul` : `-Dspring-boot.run.profiles=consul`
4. Aucun changement de code nécessaire !

---

## Partie D — Tests de performance (JMeter)

### D1 — Préparer le scénario de test

**Endpoints à tester** :
- `/api/clients/1/car/rest` (RestTemplate)
- `/api/clients/1/car/feign` (Feign)
- `/api/clients/1/car/webclient` (WebClient)

**Charges recommandées** :
- 10 utilisateurs simultanés
- 50 utilisateurs simultanés
- 100 utilisateurs simultanés
- 200 utilisateurs simultanés
- 500 utilisateurs simultanés (ou 300 si la machine est saturée)

**Métriques à collecter** :
- Temps moyen (ms)
- P95 (95ème percentile) - optionnel mais recommandé
- Débit (req/s)
- Taux d'erreur (%)

### D2 — Exécuter les tests (Eureka)

**Méthode manuelle** :
1. Ouvrir JMeter
2. Charger le plan de test : `jmeter-tests/test-resttemplate.jmx`
3. Modifier les variables :
   - `THREADS` : nombre d'utilisateurs
   - `LOOPS` : nombre d'itérations
4. Exécuter le test
5. Analyser les résultats dans "Summary Report" ou "Aggregate Report"

**Méthode automatisée (Linux/Mac)** :
```bash
cd jmeter-tests/scripts
chmod +x run-tests.sh
./run-tests.sh rest 10 50    # RestTemplate, 10 threads, 50 loops
./run-tests.sh feign 10 50   # Feign, 10 threads, 50 loops
./run-tests.sh webclient 10 50  # WebClient, 10 threads, 50 loops
```

**Méthode automatisée (Windows)** :
```cmd
cd jmeter-tests\scripts
run-tests.bat rest 10 50
run-tests.bat feign 10 50
run-tests.bat webclient 10 50
```

### D3 — Exécuter les tests (Consul)

**Même protocole, après migration** :
1. Démarrer les services avec profil Consul
2. Exécuter les mêmes tests JMeter
3. Comparer les résultats avec Eureka

**Comparaison attendue** :
- Les résultats peuvent varier légèrement entre Eureka et Consul
- L'important est de comparer les 3 méthodes (RestTemplate, Feign, WebClient) dans chaque contexte

### Analyse des résultats

**Tableau de comparaison recommandé** :

| Méthode | Threads | Temps moyen (ms) | P95 (ms) | Débit (req/s) | Taux d'erreur (%) |
|---------|---------|-------------------|----------|---------------|-------------------|
| RestTemplate | 10 | | | | |
| Feign | 10 | | | | |
| WebClient | 10 | | | | |
| RestTemplate | 50 | | | | |
| Feign | 50 | | | | |
| WebClient | 50 | | | | |
| ... | ... | | | | |

**Points d'attention** :
- **RestTemplate** : Bloquant, peut avoir une latence plus élevée sous charge
- **Feign** : Génère du code à la compilation, peut être plus rapide
- **WebClient** : Même en mode synchrone, peut avoir des différences de performance

**Conseils** :
1. **Échauffement** : Lancer quelques requêtes avant les tests pour "chauffer" la JVM
2. **Isolation** : Tester une méthode à la fois pour éviter les interférences
3. **Reproductibilité** : Noter les conditions (CPU, mémoire, autres processus)
4. **Durée** : Chaque test devrait durer au moins 1-2 minutes pour des résultats stables

---

## Fichiers de configuration

### Profils Spring

- **Eureka** : `application-eureka.properties` (profil par défaut)
- **Consul** : `application-consul.properties` (activé avec `-Dspring-boot.run.profiles=consul`)

### Scripts JMeter

- `jmeter-tests/test-resttemplate.jmx` : Plan de test pour RestTemplate
- `jmeter-tests/test-feign.jmx` : Plan de test pour Feign (à créer)
- `jmeter-tests/test-webclient.jmx` : Plan de test pour WebClient (à créer)
- `jmeter-tests/scripts/run-tests.sh` : Script d'exécution (Linux/Mac)
- `jmeter-tests/scripts/run-tests.bat` : Script d'exécution (Windows)

---

## Résumé des commandes

### Eureka
```bash
# Démarrer Eureka
cd eureka-server && mvn spring-boot:run

# Démarrer services (profil Eureka par défaut)
cd service-voiture && mvn spring-boot:run
cd service-client && mvn spring-boot:run
```

### Consul
```bash
# Démarrer Consul
consul agent -dev

# Démarrer services (profil Consul)
cd service-voiture && mvn spring-boot:run -Dspring-boot.run.profiles=consul
cd service-client && mvn spring-boot:run -Dspring-boot.run.profiles=consul
```

### Tests
```bash
# Tests manuels
curl http://localhost:8082/api/clients/1/car/rest
curl http://localhost:8082/api/clients/1/car/feign
curl http://localhost:8082/api/clients/1/car/webclient

# Tests JMeter
cd jmeter-tests/scripts
./run-tests.sh rest 10 50
```
