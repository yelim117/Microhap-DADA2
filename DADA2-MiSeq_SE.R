#Source
#https://benjjneb.github.io/dada2/tutorial.html
#https://benjjneb.github.io/dada2/ITS_workflow.html


# DADA2 Pipeline for Microhalotype NGS using MiSeq

library(dada2)
library(ShortRead)

rm(list=ls())
path <- "E:/DADA2/MH-MiSeq" # CHANGE ME to the directory containing the fastq file after unzipping.
list.files(path)

# Get forward fastq filenames
fnFs <- sort(list.files(path, pattern="_L001_R1_001.fastq", full.names = TRUE))


# Extract sample names
sample.names <- sapply(strsplit(basename(fnFs), "_L00"), `[`, 1)
sample.names

# Place filtered files in filtered subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
names(filtFs) <- sample.names


out <- filterAndTrim(fnFs, filtFs,  
                     maxN = 0, maxEE = 2, truncQ = 2, minLen = 120, 
                     rm.phix = TRUE, compress = TRUE, 
                     multithread = FALSE) # on windows, set multithread = FALSE
head(out)


errF <- learnErrors(filtFs, multithread=TRUE)


derepFs <- derepFastq(filtFs, verbose=TRUE)

dadaFs <- dada(derepFs, err=errF, multithread=TRUE)
dadaFs[[1]]



# Convert DADA2 result to STRait Razor format
# 2023. 9. 13 ~ 15, 19, 22, 2024. 4. 24 ~ 25.

library(stringr)

configInfo <- read.table("E:/DADA2/MH3_230913(LRRC63-A).config", sep="\t") # Config file for STRait Razor
countMH <- nrow(configInfo)

outputDir <- paste0(path, "/", "Output") # Set subdirectory for STRait Razor-formatted result
if (!file.exists(outputDir)) dir.create(outputDir)

for(i in 1:length(sample.names)){
  cat(sample.names[i], "is converting...\n")
  resultFile <- file(paste0(outputDir, "/", sample.names[i], "_DADA2.txt"), open="w")
  
  noAllele <- length(dadaFs[[i]]$denoised)
  for(j in 1:countMH){
    calledFlag <- FALSE
    for (k in 1:noAllele){
      alleleSeq <- dadaFs[[i]]$sequence[k]
      abundance <- dadaFs[[i]]$denoised[k]
      
      fwdPos <- str_locate(alleleSeq, configInfo[[3]][j])
      revPos <- str_locate(alleleSeq, configInfo[[4]][j])
      if (!is.na(fwdPos[2]) & !is.na(revPos[1])){
        cat(configInfo[[1]][j], "\t",
            revPos[1] - fwdPos[2] - 1, "bases\t",
            str_sub(alleleSeq, start=fwdPos[2]+1, end=revPos[1]-1), "\t",
            abundance, "\t 0\n",
            file=resultFile)
        calledFlag <- TRUE
      } else if ((!is.na(fwdPos[2]) | !is.na(revPos[1])) 
                 & (abundance > 100)){
        cat("Chimera?", k, str_sub(alleleSeq, 1, 50),
            abundance, configInfo[[1]][j], "+ ?\n")
      }
    }
    
    if (!calledFlag)
      cat(configInfo[[1]][j], "\t", "0 bases\t",
          "SumBelowThreshold\t", "0\t 0\n",
          file=resultFile)
    
    if (j < countMH) cat("\n", file=resultFile)
  }
  close(resultFile)
}
