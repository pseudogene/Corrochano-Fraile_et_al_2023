#!/bin/bash
echo "SNP filtering..."

#Prepare location
export CPU=16

# Run filtering ( MAP >= 0.05 and HW >= 10^-8 )
bgzip -d -c populations.snps.vcf.gz | awk '$1 ~ /^#/ {print $0;next} {print $0 | "sort -k1,1V -k2,2n"}' > populations.snps.vcf
plink2 --thread-num ${CPU} --vcf populations.snps.vcf --make-bed --allow-extra-chr --no-sex --max-alleles 2 --out tmp1
plink2 --bfile tmp1 --maf 0.05 --hwe 0.000000001 --make-bed --allow-extra-chr --no-sex --out tmp2
plink2 --bfile tmp2 --recode vcf --allow-extra-chr --no-sex --out populations.hwe
rm -f tmp* populations.snps.vcf

# Run imputation
# Remove chromosomes with single SNP
scripts/split_vcf.py -in populations.hwe.vcf -out populations.no_singleton.vcf

# Genotype imputation: Beagle GT
bgzip -l9 populations.no_singleton.vcf
java -jar beagle.22Jul22.46e.jar gt=populations.no_singleton.vcf.gz out=populations.imputed

# Add chromosome with single SNP
bgzip -d populations.imputed.vcf.gz
scripts/split_vcf.py -in populations.hwe.vcf --imputed populations.imputed.vcf -out mussels.snps.vcf

# Tidy
rm -f populations.hwe.vcf populations.no_singleton.vcf populations.imputed.vcf populations.no_singleton.vcf.gz populations.*.log
bgzip -l9 mussels.snps.vcf
tabix -h mussels.snps.vcf.gz

echo "[done]"
