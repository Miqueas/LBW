#!/usr/bin/bash

for m in 5.{1,2,3,4}; do
  case $m in
    5.1 ) for p in $m.{0,1,2,3,4,5}; do ./build.sh $p; done ;;
    5.2 ) for p in $m.{0,1,2,3,4}; do ./build.sh $p; done ;;
    5.3 ) for p in $m.{0,1,2,3,4,5,6}; do ./build.sh $p; done ;;
    5.4 ) for p in $m.{0,1,2,3,4}; do ./build.sh $p; done ;;
  esac
done