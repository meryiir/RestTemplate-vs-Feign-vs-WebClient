package com.example.client.config;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class RestTemplateConfig {

	@Bean
	@LoadBalanced
	public RestTemplate restTemplate() {
		return new RestTemplate();
	}

	@Bean
	@LoadBalanced
	public WebClient.Builder webClientBuilder() {
		return WebClient.builder();
	}

	@Bean
	public WebClient webClient(WebClient.Builder webClientBuilder) {
		// In Spring Cloud 2023.0.0, the @LoadBalanced annotation on the builder
		// automatically configures load balancing via ReactiveLoadBalancerClientExchangeFilterFunction
		return webClientBuilder.build();
	}
}
