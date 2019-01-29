package com.pluridev.cdsandbox.demoservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


@SpringBootApplication
public class DemoserviceApplication {

	static String[] argstring;

	public static void main(String[] args) {
		argstring = args;
		SpringApplication.run(DemoserviceApplication.class, args);
	}

}
