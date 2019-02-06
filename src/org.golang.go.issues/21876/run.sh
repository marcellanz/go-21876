#!/bin/sh

cp java-spring.jar j1.jar && cp j1.jar j2.jar && ruby go-21876.rb j1.jar j2.jar && touch j2.tar && ./go-21876 j2.jar j2.tar && rm j2.tar j2.jar j1.jar
