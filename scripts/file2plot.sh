#!/bin/bash
cat $1 |gnuplot -p -e 'plot "/dev/stdin" with lines'
