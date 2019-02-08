#!/usr/bin/env bash

echo ">> building go-21876.go"
go build go-21876.go &&
echo ">> run test1"
cd test1 && ./run.sh ${1} || cd -

echo
echo ">> run me with -fixed to see it going 'everything is ok'…"