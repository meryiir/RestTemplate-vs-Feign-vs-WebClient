package com.example.voiture.service;

import com.example.voiture.model.Voiture;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class VoitureService {

	// Simulation d'une base de données en mémoire
	private final Map<Long, Voiture> voitures = new HashMap<>();

	public VoitureService() {
		// Initialisation avec quelques données de test
		voitures.put(1L, new Voiture(10L, "Toyota", "Yaris", 1L));
		voitures.put(2L, new Voiture(11L, "Renault", "Clio", 2L));
		voitures.put(3L, new Voiture(12L, "Peugeot", "208", 3L));
		voitures.put(4L, new Voiture(13L, "Volkswagen", "Polo", 4L));
		voitures.put(5L, new Voiture(14L, "Ford", "Fiesta", 5L));
	}

	public Voiture getVoitureByClientId(Long clientId) {
		// Simuler un temps de traitement (20ms pour rendre les différences visibles)
		try {
			Thread.sleep(20);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		}
		
		return voitures.getOrDefault(clientId, 
			new Voiture(0L, "Inconnue", "Inconnu", clientId));
	}
}
