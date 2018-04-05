#!/bin/bash

#RAWDATA=$1
#threads=$2
StichedReads="01.StichedReads"
FilteredFq="02.FilteredFq"
FastaFiles="03.FastaFiles"
RemovedChimera="04.RemovedChimera"
CombinedFasta="05.CombinedFasta"
Clustering="06.Clustering"
RDP_DataSet="/app/src/Microbiome/qiime_db/rdp/RDP_trainset16_022016.fa"
Picking_Parameter="/app/src/Microbiome/qiime_db/params/microbiome_helper/gg.txt"
Ref_Fasta="/app/src/Microbiome/qiime_db/gg_13_8_otus/rep_set/99_otus.fasta"
Ref_Taxon="/app/src/Microbiome/qiime_db/gg_13_8_otus/taxonomy/99_otu_taxonomy.txt"
Biom="otu_table.biom"



## Merge Reads
#run_pear.pl -p $threads -o $StichedReads $RAWDATA/*


## Filter out poor & short reads
#read_filter.pl -q 30 -p 90 -l 400 --primer_check none --thread $threads $StichedReads/*.assembled.* -o $FilteredFq


## fastq to fasta
#run_fastq_to_fasta.pl -p $threads -o $FastaFiles $FilteredFq/*.fastq


## rename
#renamer -v 's/.assembled_filtered//' $FastaFiles/*.fasta


## Filter out chimeric reads
#chimera_filter.pl --thread $threads -type 1 -db $RDP_DataSet $FastaFiles/* -o $RemovedChimera


## Create a map file
#create_qiime_map.pl $RemovedChimera/* > map.txt


## Combine files into single QIIME "seqs.fna"
#add_qiime_labels.py -i $RemovedChimera -m map.txt -c FileInput -o $CombinedFasta


## OTU clustering (picking)
pick_closed_reference_otus.py -i $CombinedFasta/combined_seqs.fna -o $Clustering -r $Ref_Fasta -t $Ref_Taxon -f -p $Picking_Parameter


## Remove low confidence
#remove_low_confidence_otus.py.bak -i $Clustering/otu_table.biom -o $Clustering/$Biom


## summary
biom summarize-table -i $Clustering/$Biom
biom summarize-table -i $Clustering/$Biom -o $Clustering/stats_reads_per_sample.txt
biom summarize-table -i $Clustering/$Biom -o $Clustering/stats_OTUs_per_sample.txt --qualitative
biom convert -i $Clustering/$Biom -o $Clustering/otu_table.tsv --to-tsv --header-key taxonomy


## add this line...
#biom add-metadata -i otu_table_high_conf.biom -m ../map.txt  -o otu_table_high_conf.map.biom
#biom convert -i ./otu_table_high_conf.map.biom -o otu_table.meta.tsv --to-tsv --header-key taxonomy --output-metadata-id "Consensus Lineage"
