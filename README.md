# ExML-pipe

This repository contains code, data, and pipelines for processing exome sequencing results and applying machine learning models for downstream analysis.  
The workflow covers the full cycle: from raw sequencing files (`*.fq.gz`) to annotated variant tables and predictive ML models.

## Repository structure

```
├── bio-raw/                  # Raw bioinformatics data (FASTQ, BAM, unprocessed VCF)
├── preprml-raw/              # Raw machine learning and preprocessing code (before preprocessing)
├── preprocessing/             # Python/R preprocessing; outputs tidy CSVs
├── training/                  # ML training code and experiments
├── trained-models/            # Model artifacts, configs, and metrics
├── metadata/                  # Example of clinical information of patients
└── bioinformatics-pipelines/  # FASTQ (*.fq.gz) → VCF → annotated CSV workflows
```

## Workflow overview

1. **Bioinformatics stage**  
   Raw sequencing data (`bio-raw/`) is processed through pipelines in `bioinformatics-pipelines/` to produce annotated variant tables (VCF/CSV).  

2. **Data preprocessing**  
   Scripts in `preprocessing/` clean and normalize the outputs, generating final tidy CSV files suitable for analysis.  

3. **Machine learning**  
   - Raw ML datasets are stored in `ml-raw/`.  
   - Training code in `training/` builds models on preprocessed data.  
   - Final trained models, configurations, and evaluation metrics are stored in `trained-models/`.  

## Requirements

!!!!!

## Usage

### 1. Bioinformatics pipeline
Run from raw FASTQ to annotated VCF/CSV:

### 2. Data preprocessing
Convert annotated tables into tidy CSV:

### 3. Model training
Train and evaluate ML models on processed datasets:

### 4. Load trained models
Use trained models for prediction:

---

## License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details. 
