package com.example.voiture.controller;

import com.example.voiture.model.Voiture;
import com.example.voiture.service.VoitureService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cars")
public class VoitureController {

	@Autowired
	private VoitureService voitureService;

	@GetMapping("/byClient/{clientId}")
	public Voiture getVoitureByClientId(@PathVariable Long clientId) {
		return voitureService.getVoitureByClientId(clientId);
	}
}
