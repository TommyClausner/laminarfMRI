#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo Define ROIs... estimated duration 40min
echo create masks from labels...
sh labels2masks.sh
sh expandROIs.sh
echo done.
echo compute layer segmentation...
sh do_getLayers.sh
sh do_getLayerWeights.sh
echo done.
