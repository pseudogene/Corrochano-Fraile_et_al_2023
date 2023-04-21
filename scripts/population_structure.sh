#!/bin/bash
echo "Population structure..."

# Prepare the population list
plink --vcf mussels.snps.vcf --make-bed --allow-extra-chr --no-sex --out mussels.plink
tail -n +2 mussels.plink.fam |  cut -f1 -d- > pop.txt

# Run fastSTRUCTURE
mkdir admixture
for I in $(seq 1 1 20)
do
  structure.py -K "${I}" --input mussels.plink --output admixture/admixture --full --prior logistic
  distruct.py -K "${I}" --popfile pop.txt --input=admixture/admixture --output="admixture/admixture.${I}.svg"
done

# Choose the best model
chooseK.py --input=admixture/admixture
rm -f mussels.plink.* pop.txt

# Tidy
cp admixture/admixture.5.svg Figure_Structure.5.svg

echo "[done]"
