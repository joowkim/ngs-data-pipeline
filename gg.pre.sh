#!/bin/bash

RAWDATA=$1
threads=$2
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
run_pear.pl -p $threads -o $StichedReads $RAWDATA/*


## Filter out poor & short reads
read_filter.pl -q 30 -p 90 -l 400 --primer_check none --thread $threads $StichedReads/*.assembled.*


## fastq to fasta
run_fastq_to_fasta.pl -p $threads -o $FastaFiles filtered_reads/*fastq


##
renamer -v 's/.assembled_filtered//' $FastaFiles/*.fasta


## Filter out chimeric reads
chimera_filter.pl --thread $threads -type 1 -db $RDP_DataSet $FastaFiles/*


##
renamer -v 's/.nonchimera//' $RemovedChimera/*.fasta


## Create a map file
create_qiime_map.pl $RemovedChimera/* > map.txt


## Combine files into single QIIME "seqs.fna"
add_qiime_labels.py -i $RemovedChimera -m map.txt -c FileInput -o $CombinedFasta


##
sed -i "s/.fasta//" $CombinedFasta/combined_seqs.fna


## OTU clustering (picking)
#pick_closed_reference_otus.py -i $CombinedFasta/combined_seqs.fna -o $Clustering -r $Ref_Fasta -t $Ref_Taxon -f -p $Picking_Parameter


## Remove low confidence
#remove_low_confidence_otus.py -i $Clustering/otu_table.biom -o $Clustering/$Biom


## summary
#biom summarize-table -i $Clustering/$Biom
#biom summarize-table -i $Clustering/$Biom -o $Clustering/stats_reads_per_sample.txt
#biom summarize-table -i $Clustering/$Biom -o $Clustering/stats_OTUs_per_sample.txt --qualitative
#biom summarize-table -i $Clustering/$Biom -o $Clustering/otu_table.tsv --to-tsv --header-key taxonomy



