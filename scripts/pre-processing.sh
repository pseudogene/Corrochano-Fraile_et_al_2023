#!/bin/bash
echo "Data Pre-processing..."

#Prepare location
export CPU=16

## Download raw data
fastq-dump --split-3 ERR9585930
fastq-dump --split-3 ERR9610053
fastq-dump --split-3 ERR9633201
fastq-dump --split-3 ERR10558077

# Demultiplex libraries
mkdir -p samples
process_radtags --threads "${CPU}" -E phred33 --filter_illumina -s 20 -c -q -t 135 -i fastq -y gzfastq -1 ERR9585930_1.fq -2 ERR9585930_2.fq -b data/L1.barcodes.txt --inline_inline --renz_1 sbfI --renz_2 sphI -o ./samples
for A in samples/*_1.1.fq.gz;
do
  B=$(echo "${A}" | cut -f1 -d'_' | cut -f2 -d'/')
  cat "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz" > "samples/${B}.fq.gz"
  rm -f "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz"
done
mv samples samples.1

mkdir -p samples
process_radtags --threads ${CPU} -E phred33 --filter_illumina -s 20 -c -q -t 135 -i fastq -y gzfastq -1 ERR9610053_1.fq -2 ERR9610053_2.fq -b data/L2.barcodes.txt --inline_inline --renz_1 sbfI --renz_2 sphI -o ./samples
for A in samples/*_1.1.fq.gz;
do
  B=$(echo "${A}" | cut -f1 -d'_' | cut -f2 -d'/')
  cat "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz" > "samples/${B}.fq.gz"
  rm -f "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz"
done
mv samples samples.2

mkdir -p samples
process_radtags --threads ${CPU}  -E phred33 --filter_illumina -s 20 -c -q -t 135 -i fastq -y gzfastq -1 ERR9633201_1.fq -2 ERR9633201_2.fq -b data/L3.barcodes.txt --inline_inline --renz_1 sbfI --renz_2 sphI -o ./samples
for A in samples/*_1.1.fq.gz;
do
  B=$(echo "${A}" | cut -f1 -d'_' | cut -f2 -d'/')
  cat "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz" > "samples/${B}.fq.gz"
  rm -f "samples/${B}_1.1.fq.gz" "samples/${B}_1.2.fq.gz" "samples/${B}_1.rem.1.fq.gz" "samples/${B}_1.rem.2.fq.gz" "samples/${B}_2.1.fq.gz" "samples/${B}_2.2.fq.gz" "samples/${B}_2.rem.1.fq.gz" "samples/${B}_2.rem.2.fq.gz"
done
mv samples samples.3

mkdir -p samples
process_radtags --threads "${CPU}" -E phred33 --filter_illumina -s 20 -c -q -t 135 -i fastq -y gzfastq -1 ERR10558077_1.fq -2 ERR10558077_2.fq -b data/L4.barcodes.txt --inline_inline --renz_1 sbfI --renz_2 sphI -o ./samples
for A in samples/*.rem.1.fq.gz;
do
  B=$(echo "${A}" | cut -f2 -d'/' | cut -f1 -d'.')
  cat "samples/${B}.1.fq.gz" "samples/${B}.2.fq.gz" "samples/${B}.rem.1.fq.gz" "samples/${B}.rem.2.fq.gz" > "samples/${B}.fq.gz"
  rm -f "samples/${B}.1.fq.gz" "samples/${B}.2.fq.gz" "samples/${B}.rem.1.fq.gz" "samples/${B}.rem.2.fq.gz"
done
mv samples samples.4

# Merge samples
mkdir -p samples
cp samples.1/*.fq.gz samples
for A in samples.2/*.fq.gz
do
    B=$(echo "${A}" | cut -f2 -d'/')
    cat "${A}" >> "samples/${B}"
done
for A in samples.3/*.fq.gz
do
    B=$(echo "$A" | cut -f2 -d'/')
    cat "${A}" >> "samples/${B}"
done
cp samples.4/*.fq.gz samples

# Prepare genome
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/905/397/895/GCA_905397895.1_MEDL1/GCA_905397895.1_MEDL1_genomic.fna.gz
gunzip GCA_905397895.1_MEDL1_genomic.fna.gz
mv GCA_905397895.1_MEDL1_genomic.fna mussel.genome.fasta

bwa index mussel.genome.fasta

# Align reads to genome
mkdir -p bam
for A in samples/*.fq.gz;
do
  B=$(echo "${A}" | cut -f1 -d'.' | cut -f2 -d'/')
  if [ ! -f "bam/${B}.bam" ]
  then
    C=$(echo "${B}" | cut -f1 -d'-')
    echo -e "${B}\t${C}" >> species.pop.txt

    gunzip -c "./samples/${B}.fq.gz" > "./samples/${B}.fq"
    bwa mem -t "${CPU}" mussel.genome.fasta "./samples/${B}.fq" > "./bam/$B.sam"
    samtools view -F 0x4 -bS -o "./bam/$B.tmp.bam" "./bam/$B.sam"
    samtools sort -@"${CPU}" --reference mussel.genome.fasta -o "./bam/$B.bam" "./bam/$B.tmp.bam"
    rm -rf "./bam/$B.sam" "./bam/$B.tmp.bam" "./samples/${B}.fq"
  fi
done

# Run STACK analysis
mkdir -p ref
ref_map.pl -T "${CPU}" --samples ./bam --popmap species.pop.txt -o ./ref

# Call and export SNPs
populations -P ./ref -M species.pop.txt -r 0.50 -t "${CPU}" --write-single-snp --vcf
cp ref/populations.snps.vcf populations.snps.vcf

echo "[done]"
