STAR_INDEX=/app/ref/gencode/human/GRCh37.19/idx
GTF=/app/ref/gencode/human/GRCh37.19/gtf/gencode.v19.annotation.gtf
TRUESEQ_ADAPTER=/home/corea/miniconda3/envs/mRNAseq/opt/bbmap-37.90/resources/trueseq.adapter.fa


## trim
mkdir -p 01.Trim
ls 00.Rawdata/*_1*.gz | sed 's/_1.fastq.gz//' | sed 's/00.Rawdata\///' | parallel -j 2 --load 80% "bbduk.sh -Xmx30g in1=00.Rawdata/{}_1.fastq.gz in2=00.Rawdata/{}_2.fastq.gz ref=$TRUESEQ_ADAPTER out1=01.Trim/{}_1.fastq.gz out2=01.Trim/{}_2.fastq.gz ktrim=r k=23 mink=11 hdist=1 tpe tbo trimq=20"


## alignment
mkdir -p 02.Align
ls 00.Rawdata/*_1*.gz | sed 's/_1.fastq.gz//' | sed 's/00.Rawdata\///' | parallel -j 2 --load 80% "STAR --genomeDir $STAR_INDEX --sjdbOverhang 100 --twopassMode Basic --readFilesCommand zcat --readFilesIn 01.Trim/{}_1.fastq.gz 01.Trim/{}_2.fastq.gz --runThreadN 20 --outSAMtype BAM SortedByCoordinate --outFileNamePrefix 02.Align/{}."


## get the read counts table
mkdir -p 03.GeneCountTable
#ls 00.Rawdata/*_1*.gz | sed 's/_1.fastq.gz//' | sed 's/00.Rawdata\///' | parallel -j 2 --load 80% "featureCounts -p -t exon -g gene_id -a $GTF -o 03.GeneCountTable/{}.bam.featureCounts 02.Align/*.bam -T 20"
