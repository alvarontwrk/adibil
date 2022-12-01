#!/bin/sh

cat packages.list | while read line; do
  package=$(echo $line | sed 's/#.*//g')
  apt -qq list $package 2>/dev/null | grep installed
done
