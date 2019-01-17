package com.pluridev.cdsandbox.demoservice;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoServiceRestController {
    @Autowired
    @RequestMapping(value = "/", method = RequestMethod.GET)

    public String getVersion() {
        return "DemoService v0.0.1";
    }
}