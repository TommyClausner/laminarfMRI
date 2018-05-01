#!/bin/bash
filename_=$(basename "$1")
dirname_=$(dirname "$1")
echo converting $filename_ to pdf
filename_="${filename_%.*}"
pandoc -o $dirname_/$filename_.pdf $1
