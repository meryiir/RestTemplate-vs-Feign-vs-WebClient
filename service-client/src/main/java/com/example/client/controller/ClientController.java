package com.example.client.controller;

import com.example.client.model.Voiture;
import com.example.client.service.VoitureService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

	private static final Logger logger = LoggerFactory.getLogger(ClientController.class);

	@Autowired
	private VoitureService voitureService;

	/**
	 * Endpoint utilisant RestTemplate
	 */
	@GetMapping("/{id}/car/rest")
	public ResponseEntity<?> getVoitureByRestTemplate(@PathVariable Long id) {
		try {
			Voiture voiture = voitureService.getVoitureByRestTemplate(id);
			return ResponseEntity.ok(voiture);
		} catch (Exception e) {
			logger.error("Error getting voiture by RestTemplate for clientId: " + id, e);
			Map<String, String> error = new HashMap<>();
			error.put("error", e.getClass().getSimpleName());
			error.put("message", e.getMessage());
			error.put("method", "RestTemplate");
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
		}
	}

	/**
	 * Endpoint utilisant Feign
	 */
	@GetMapping("/{id}/car/feign")
	public ResponseEntity<?> getVoitureByFeign(@PathVariable Long id) {
		try {
			Voiture voiture = voitureService.getVoitureByFeign(id);
			return ResponseEntity.ok(voiture);
		} catch (Exception e) {
			logger.error("Error getting voiture by Feign for clientId: " + id, e);
			Map<String, String> error = new HashMap<>();
			error.put("error", e.getClass().getSimpleName());
			error.put("message", e.getMessage());
			error.put("method", "Feign");
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
		}
	}

	/**
	 * Endpoint utilisant WebClient (utilisé en synchrone via block())
	 */
	@GetMapping("/{id}/car/webclient")
	public ResponseEntity<?> getVoitureByWebClient(@PathVariable Long id) {
		try {
			Voiture voiture = voitureService.getVoitureByWebClient(id);
			return ResponseEntity.ok(voiture);
		} catch (Exception e) {
			logger.error("Error getting voiture by WebClient for clientId: " + id, e);
			Map<String, String> error = new HashMap<>();
			error.put("error", e.getClass().getSimpleName());
			error.put("message", e.getMessage());
			error.put("method", "WebClient");
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
		}
	}
}
