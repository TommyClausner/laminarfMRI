#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
max=`ls -1d $DIR/S* | tr -dc '[0-9\n]' | sort -k 1,1n | tail -1`
mkdir $DIR/S$((max + 1))

scp -r $DIR/template_session/* $DIR/S$((max + 1))
cd $DIR/S$((max + 1))
sh $DIR/S$((max + 1))/template_scripts/setupfolders.sh
scp $DIR/S$((max + 1))/template_helperfiles/* $DIR/S$((max + 1))/A_helperfiles
rm -r $DIR/S$((max + 1))/template_helperfiles

scp $DIR/S$((max + 1))/template_scripts/* $DIR/S$((max + 1))/B_scripts
rm -r $DIR/S$((max + 1))/template_scripts