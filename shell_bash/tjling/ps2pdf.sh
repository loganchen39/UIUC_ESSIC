#!/bin/bash
for i in $@
do
  ps2pdf $i
done
