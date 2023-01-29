#!/bin/bash

##### WARNING. This will create 52700 files #####

for s in $(echo {0..850});
do
  touch "${s}-pain";
  for i in $(echo {a..z} {A..Z} {0..9});
  do
    touch "${i}-${s}-pain";
  done;
done
