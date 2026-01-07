package com.example.client.service;

import com.example.client.feign.VoitureFeignClient;
import com.example.client.model.Voiture;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class VoitureService {

	@Autowired
	private RestTemplate restTemplate;

	@Autowired
	private WebClient webClient;

	@Autowired
	private VoitureFeignClient feignClient;

	/**
	 * Méthode 1 : RestTemplate
	 * Utilise RestTemplate pour appeler le service voiture via Eureka
	 * Le @LoadBalanced permet la résolution automatique du nom de service
	 */
	public Voiture getVoitureByRestTemplate(Long clientId) {
		// Utilisation du nom de service au lieu de l'URL complète
		// Eureka résout automatiquement "service-voiture" vers l'instance disponible
		String url = String.format("http://service-voiture/api/cars/byClient/%d", clientId);
		return restTemplate.getForObject(url, Voiture.class);
	}

	/**
	 * Méthode 2 : Feign
	 * Utilise Feign pour appeler le service voiture (résolution automatique via Eureka)
	 */
	public Voiture getVoitureByFeign(Long clientId) {
		return feignClient.getVoitureByClientId(clientId);
	}

	/**
	 * Méthode 3 : WebClient (utilisé en synchrone dans ce lab)
	 * Utilise WebClient pour appeler le service voiture via Eureka
	 * Note: WebClient est un client réactif, mais on l'utilise en "synchrone" via block()
	 * pour comparer à armes égales avec RestTemplate et Feign.
	 * En production, il est souvent utilisé en non-bloquant.
	 */
	public Voiture getVoitureByWebClient(Long clientId) {
		// Utilisation du nom de service au lieu de l'URL complète
		String url = String.format("http://service-voiture/api/cars/byClient/%d", clientId);
		
		// Utilisation de block() pour rendre l'appel synchrone (mode sync du TP)
		return webClient.get()
			.uri(url)
			.retrieve()
			.bodyToMono(Voiture.class)
			.block(); // Blocage pour comparaison synchrone avec RestTemplate et Feign
	}
}
