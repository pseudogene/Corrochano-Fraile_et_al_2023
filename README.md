# Estimating blue mussel (_Mytilus edulis_) connectivity and settlement capacity in mid-latitude fjord regions

This companion repository records, in a reproducible manner, all of the steps taken when assessing the performance of the method presented in Corrochano-Fraile et al. 2023. 


> **Estimating blue mussel (_Mytilus edulis_) connectivity and settlement capacity in mid-latitude fjord regions**.
> Corrochano-Fraile A, Carboni S, Green DM, Taggart JB, Thomas PA, Dmitry A, and Bekaert M.

![DOI](https://img.shields.io/badge/Submitted-orange.svg)


## How to use this repository?

This repository hosts both the scripts and tools used by this study and the raw results generated at the time. Feel free to adapt the scripts and tools but remember to cite their authors!

To look at our scripts and raw results, **browse** through this repository. If you want to reproduce our results, you will need to **clone** this repository, and the run all the scripts. If you want to use our data for our own research, **fork** this repository and **cite** the authors.


### Browse through the scripts

* Visit the local tutorials or browse into the file system.
* Data pre-processing [[shell script](workflows/Pre-processing.md)]
* SNP filtering and imputation [[shell script](workflows/SNP_filtering.md)]
* Connectivity analysis [[R workflow](workflows/Connectivity.md)]
* Population structure [[shell script](workflows/Population_structure.md)]
* Biophysical model [[shell script](workflows/Biophysical_model.md)]
* Model connectivity (per year) [[R workflow](workflows/Model_connectivity_all.md)]
* Model connectivity (per week) [[R workflow](workflows/Model_connectivity_per_week.md)]


### Clone the repository

```sh
git clone https://github.com/pseudogene/Corrochano-Fraile_et_al_2023.git
```


### Re-run the analysis

```sh
cd larvae

scripts/pre-processing.sh
scripts/SNP_filters.sh
# connectivity.ipynb
scripts/population_structure.sh
scripts/Biophysical_model.sh
# model_connectivity_all.ipynb
# model_connectivity_per_week.ipynb
```

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/pseudogene/Corrochano-Fraile_et_al_2023/blob/master/LICENSE)
