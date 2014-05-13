#!/bin/bash
docker run -h "example.dev.example.com" -name example -d -p 3306:3306 leviathan.example.com:5000/example
