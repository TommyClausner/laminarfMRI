#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

convert_xfm -omat $DIR/$2 -inverse $DIR/$1 

