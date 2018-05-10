#!/bin/bash
mkdir toolboxes
cd toolboxes

GitHubOnly=1
NonPrivateOnly=1

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
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/kendrickkay/$whichOne
fi

whichOne=knkutils
if [ -d "$whichOne" ]
then
cd $whichOne 
git pull
cd ..
else
git clone https://github.com/kendrickkay/$whichOne 
fi

whichOne=OpenFmriAnalysis
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/TimVanMourik/$whichOne
fi

whichOne=Scriptinator
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/TommyClausner/$whichOne
fi

if [[ $GitHubOnly -ne 1 ]]
then
whichOne=tc_functions
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/TommyClausner/$whichOne
fi
fi

whichOne=Pipeline
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/Washington-University/$whichOne
fi

whichOne=Workbench
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/Washington-University/$whichOne
fi

whichOne=fieldtrip
if [ -d "$whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/fieldtrip/$whichOne
fi
echo Please goto the following websites and download the software manually:
echo http://www.fil.ion.ucl.ac.uk/spm/software/download/
echo https://fsl.fmrib.ox.ac.uk/fsldownloads_registration
