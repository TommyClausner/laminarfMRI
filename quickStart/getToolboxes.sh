#!/bin/bash
mkdir toolboxes
cd toolboxes

GitHubOnly=1

if [[ $GitHubOnly -ne 1 ]]
then
unameOut=`uname -s`
case $unameOut in
Linux*)         machine=Linux;;
Darwin*)        machine=Mac
esac

echo $machine
if [ $machine == Mac ]
then
wget https://www.nitrc.org/frs/download.php/9330/MRIcron_macOS.dmg
wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Darwin-OSX-stable-pub-v6.0.0.dmg
else
wget https://www.nitrc.org/frs/download.php/9322/lx.zip
wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz
fi
fi
whichOne=analyzePRF
GHuser=kendrickkay
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=knkutils
if [ -d "$whichOne" ]
then
cd $whichOne 
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne 
fi

whichOne=OpenFmriAnalysis
GHuser=TimVanMourik
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=tc_functions
GHuser=TommyClausner
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=Pipeline
GHuser=Washington-University
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=Workbench
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=fieldtrip
GHuser=fieldtrip
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=vistasoft
GHuser=vistalab
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi

whichOne=Psychtoolbox-3
GHuser=Psychtoolbox-3
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/$GHuser/$whichOne
fi
echo Please goto the following websites and download the software manually:
echo http://www.fil.ion.ucl.ac.uk/spm/software/download/
echo https://fsl.fmrib.ox.ac.uk/fsldownloads_registration
