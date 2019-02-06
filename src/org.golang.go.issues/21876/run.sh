#!/bin/sh

echo "build"
go build go-21876.go &&
cp java-spring.jar j1.jar && cp j1.jar j2.jar &&

echo "remove entries"
ruby go-21876.rb j1.jar j2.jar &&

echo "clean run"
touch j1.ok.tar && ./go-21876 j1.jar j1.ok.tar &&
rm j1.ok.tar &&

echo "err run"
touch j2.tar && ./go-21876 j2.jar j2.tar &&
rm j2.tar j2.jar