#!/bin/bash
unameOut=`uname -s`
case $unameOut in
Linux*)         machine=Linux;;
Darwin*)        machine=Mac
esac

echo $machine
if [ $machine == Mac ]
then
wget https://www.nitrc.org/frs/download.php/9330/MRIcron_macOS.dmg
else
wget https://www.nitrc.org/frs/download.php/9322/lx.zip
fi

whichOne=analyzePRF
if [ -d $whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/kendrickkay/$whichOne
fi

whichOne=knkutils
if [ -d $whichOne" ]
then
cd $whichOne 
git pull
cd ..
else
git clone https://github.com/kendrickkay/$whichOne 
fi

whichOne=OpenFmriAnalysis
if [ -d $whichOne" ]
then
cd $whichOne
git pull
cd ..
else
git clone https://github.com/TimVanMourik/$whichOne
fi

echo Please goto the following websites and download the software manually:
echo http://www.fil.ion.ucl.ac.uk/spm/software/download/
echo https://fsl.fmrib.ox.ac.uk/fsldownloads_registration
