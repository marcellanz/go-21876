#!/usr/bin/env bash

./clean.sh

mkdir d1 d2

echo 1234567890 > d1/f1.txt
echo 0987654321 > d2/f2.txt

echo ">> create test1.zip and enforce usage of data descriptors with '-fd'"

zip -r -fd test1.zip d1 d2
unzip -lv test1.zip

echo ">> remove directories with 'zip -d'"
zip test1.zip -d d1
zip test1.zip -d d2
unzip -lv test1.zip
> test1.tar
echo ">> go-21876 run it and succeed"
../go-21876 test1.zip test1.tar
rm test1.tar

echo ">> create test1.zip and enforce usage of data descriptors with '-fd'"
zip -r -fd test1.zip d1 d2
cp test1.zip j1.zip
cp test1.zip j2.zip

echo ">> remove directories with 'go-21876-issue-script-given-fixed.rb… and'"
ruby ../go-21876-issue-script-given${1}.rb j1.zip j2.zip
> j2.tar
../go-21876 j2.zip j2.tar
