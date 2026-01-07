# Guide de Démarrage Rapide

## Ordre de démarrage

### 1. Eureka Server (Port 8761)
```bash
cd eureka-server
mvn spring-boot:run
```
**Vérification** : Ouvrir http://localhost:8761 dans le navigateur

### 2. Service Voiture (Port 8081)
```bash
cd service-voiture
mvn spring-boot:run
```
**Vérification** : 
- Vérifier dans Eureka Dashboard que le service apparaît
- Tester : `curl http://localhost:8081/api/cars/byClient/1`

### 3. Service Client (Port 8082)
```bash
cd service-client
mvn spring-boot:run
```
**Vérification** :
- Vérifier dans Eureka Dashboard que le service apparaît
- Tester les 3 endpoints

## Tests des 3 méthodes HTTP

### RestTemplate
```bash
curl http://localhost:8082/api/clients/1/car/rest
```

### Feign
```bash
curl http://localhost:8082/api/clients/1/car/feign
```

### WebClient
```bash
curl http://localhost:8082/api/clients/1/car/webclient
```

## Réponse attendue

Tous les endpoints devraient retourner :
```json
{
  "id": 10,
  "marque": "Toyota",
  "modele": "Yaris",
  "clientId": 1
}
```

## Dépannage

### Le service ne s'enregistre pas dans Eureka
- Vérifier que Eureka Server est démarré
- Vérifier l'URL dans `application.properties` : `eureka.client.service-url.defaultZone=http://localhost:8761/eureka/`

### Erreur "Service voiture non disponible"
- Vérifier que le service-voiture est bien démarré et enregistré dans Eureka
- Attendre quelques secondes après le démarrage pour que l'enregistrement soit effectif

### Port déjà utilisé
- Modifier le port dans `application.properties` de chaque service
- Ou arrêter le processus utilisant le port
