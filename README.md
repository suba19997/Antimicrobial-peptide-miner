# AMP Discovery Pipeline from Transcriptome Data

This repository provides an automated, reproducible workflow for identifying **Antimicrobial Peptides (AMPs)** from de novo assembled transcriptome sequences. The pipeline combines **ORF prediction**, **custom BLASTp filtering**, and **HMMER domain detection** to generate a curated list of potential AMP candidates.

## Overview

This pipeline performs the following steps:

1. **Predict Open Reading Frames (ORFs)** from transcriptomic data using `TransDecoder`.
2. **Filter ORFs** to retain only short peptides between **10 and 100 amino acids**, suitable for AMP candidates.
3. **Build a custom AMP database** from known sequences (APD3, UniProt, NCBI) and run **BLASTp** for homology-based screening.
4. Apply strict **BLASTp filters**: E-value ≤ 0.001, identity ≥ 80%, and alignment length ≥ 50.
5. Perform **domain analysis** on all ORFs using `HMMER` and the `Pfam-A.hmm` database to identify AMP-like motifs.
6. **Merge results** into a final tabular summary (`.tsv`) for downstream analysis, annotation, or validation.

## Input Requirements

Before you begin, you will need:

- A de novo assembled **transcriptome file** in FASTA format.
- A **custom AMP protein database** in FASTA format (retrieved from [APD3](https://aps.unmc.edu/), [UniProt](https://www.uniprot.org/), and [NCBI]).
- A **Pfam-A HMM database** file (downloaded from [Pfam FTP](https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/)).

---

## Software Dependencies

| Tool            | Purpose                        | Version |
|------------------|----------------------------------|----------|
| TransDecoder     | ORF prediction                   | ≥ v5.5   |
| seqkit           | FASTA filtering                  | ≥ v0.15  |
| BLAST+           | Homology search (BLASTp)         | ≥ v2.10  |
| HMMER            | Domain identification            | ≥ v3.3   |
| Python 3 + pandas| Result merging & manipulation    | ≥ 3.6    |

## To install Python dependencies:

pip install pandas

## Ensure all tools are installed and available in your system's PATH.

## Repository Structure
AMP_Discovery_Pipeline/
├── run_amp_pipeline.sh        # Main bash script for full pipeline
├── merge_results.py           # Python script to combine BLAST and HMMER outputs
├── AMP_output/                # Folder containing final filtered results
├── README.md                  # Pipeline documentation (you are here!)
## How to Run
## Step 1: Clone the Repository
git clone https://github.com/<your-username>/AMP_Discovery_Pipeline.git
cd AMP_Discovery_Pipeline
## Step 2: Run the Pipeline
## Example:
bash run_amp_pipeline.sh transcriptome.fasta AMP_db.fasta Pfam-A.hmm

## All output files are stored in the AMP_output/ directory:

transdecoderout.fasta: Filtered ORFs (10–100 amino acids)

blast_output_filtered.txt: BLASTp results with identity ≥ 80% and alignment length ≥ 50

pfam_results.tbl: HMMER output showing AMP-related domain matches

Final_AMP_Results.tsv: Merged and annotated table combining BLASTp + Pfam data
