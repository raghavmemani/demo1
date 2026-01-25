package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Demo1Application {

    @GetMapping("/welcome")
    public String welcome(){
        return "Welcome to javatechie !";
    }

    public static void main(String[] args) {
        SpringApplication.run(Demo1Application.class, args);
    }

}
