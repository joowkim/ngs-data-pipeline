#!/bin/sh

if [ $# -ne 2 ]
then 
	echo "bash this.sh [sampling_depth] [threads]"
	exit 1
fi

SamplingDepth=$1
Threads=$2
StichedReads="01.StichedReads"
FilteredFq="02.FilteredFq"
FastaFiles="03.FastaFiles"
RemovedChimera="04.RemovedChimera"
CombinedFasta="05.CombinedFasta"
Clustering="06.Clustering"
RDP_DataSet="/app/src/Microbiome/qiime_db/rdp/RDP_trainset16_022016.fa"
Biom="otu_table.biom"
Diversity="07.Diversity"
Map="map.txt"
TREE="/app/src/Microbiome/qiime_db/gg_13_8_otus/trees/99_otus.tree"
Param="/app/src/Microbiome/qiime_db/params/16s_div.txt"

echo $1 $2
## estimate diversity analysis
core_diversity_analyses.py -i $Clustering/$Biom -o $Diversity -m $Map -e $1 -a -O $2 -t $TREE -p $Param

