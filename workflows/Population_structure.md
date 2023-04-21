# Population structure

### Dependancies

* plink v2.00a3.7LM
* split_vcf.py (local)
* faststructure v1.0


### Prepare the population list

```sh
plink --vcf mussels.snps.vcf --make-bed --allow-extra-chr --no-sex --out mussels.plink
tail -n +2 mussels.plink.fam |  cut -f1 -d- > pop.txt
```

## Run fastSTRUCTURE

Test K = 1 (one single population) to K = 20 (one population per sample point and time).

```sh
mkdir admixture
for I in $(seq 1 1 20)
do
  structure.py -K "${I}" --input mussels.plink --output admixture/admixture --full --prior logistic
  distruct.py -K "${I}" --popfile pop.txt --input=admixture/admixture --output="admixture/admixture.${I}.svg"
done
```

### Choose the best model
```sh
chooseK.py --input=admixture/admixture
rm -f mussels.plink.* pop.txt
```

```plaintext
Model complexity that maximizes marginal likelihood = 5
Model components used to explain structure in data = 9
```

### Tidy

```sh
cp admixture/admixture.5.svg Figure_Structure.5.svg
```

## Final artefact

* `Figure_Structure.5.svg`
