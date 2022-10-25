#!/bin/bash

folders="./auxillary ./common ./core ./sim"
file_name="vfile.txt"

echo "" > $file_name

for path in $folders; do
  list=$(find $path -name '*.v')
  for i in $list; do
    echo "${i} \\" >> $file_name
  done
done
