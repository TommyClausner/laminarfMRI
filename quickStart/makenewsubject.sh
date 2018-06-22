#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
max=`ls -1d $DIR/S* | tr -dc '[0-9\n]' | sort -k 1,1n | tail -1`
subj=S$((max + 1))
mkdir $DIR/$subj

scp -r $DIR/template_session/template* $DIR/$subj
cd $DIR/$subj
sh $DIR/$subj/template_scripts/setupfolders.sh
scp $DIR/$subj/template_helperfiles/* $DIR/$subj/A_helperfiles
rm -r $DIR/$subj/template_helperfiles

scp $DIR/$subj/template_scripts/* $DIR/$subj/B_scripts
rm -r $DIR/$subj/template_scripts