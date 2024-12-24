# Microhap-DADA2-Rscript
R scripts for microhaplotype analysis of MiSeq data using DADA2.


## Requirements
- R version >= 4.0
- Required packages: `dada2`, `ShortRead`, `stringr`


## Configuration File Preparation
- The `example/` directory contains a configuration file (`MH24_241224.config`) for STRait Razor format conversion. 
- Make sure to modify the path in the script to reflect the actual path of your config file.
  (e.g., "E:/DADA2/MH24_241224.config")


## FASTQ File Preparation
- At least **two FASTQ files** are required to run the DADA2 pipeline.
- Make sure to modify the path in the script to reflect the actual path of your FASTQ files
  (e.g., "E:/DADA2/MH-MiSeq"). 


## Usage
1. Place your Configuration and FASTQ files in the appropriate directories.
2. Modify the Configuration and FASTQ file paths in the script to reflect the correct paths.
3. Run the script.
