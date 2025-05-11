#!/bin/bash
set -euo pipefail

### 👋 INPUTS ###
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <transcriptome.fasta> <AMP_db.fasta> <Pfam-A.hmm>"
    exit 1
fi

TRANSCRIPTS=$1
AMP_DB=$2
PFAM_DB=$3

### 🔍 STEP 1: ORF Prediction ###
echo "🧬 Predicting ORFs using TransDecoder..."
TransDecoder.LongOrfs -t "$TRANSCRIPTS" --min_length 10
TransDecoder.Predict -t "$TRANSCRIPTS" --single_best_only

### ✂️ STEP 2: Filter ORFs 10-100 AA ###
echo "📏 Filtering ORFs between 10–100 AA..."
seqkit seq -m 10 -M 100 "${TRANSCRIPTS}.transdecoder.pep" > transdecoderout.fasta

### 🧱 STEP 3: Create AMP BLAST DB ###
echo "🔬 Creating BLAST DB for AMP sequences..."
makeblastdb -in "$AMP_DB" -dbtype prot -out AMPdb

### 🚀 STEP 4: Run BLASTp and Filter Results ###
echo "💥 Running BLASTp with filters (e-value 0.001, identity ≥ 80%, alignment length ≥ 50)..."
blastp -query transdecoderout.fasta -db AMPdb -evalue 0.001 -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore' -out blast_output_raw.txt

# Filtering with awk: identity >= 80, alignment length >= 50
awk '$3 >= 80 && $4 >= 50' blast_output_raw.txt > blast_output_filtered.txt

### 🔎 STEP 5: Run HMMER ###
echo "🧠 Running HMMER search against Pfam-A..."
hmmsearch --tblout pfam_results.tbl "$PFAM_DB" transdecoderout.fasta

### 📁 STEP 6: Organize Output ###
mkdir -p AMP_output
cp transdecoderout.fasta AMP_output/
cp blast_output_filtered.txt AMP_output/
cp pfam_results.tbl AMP_output/
# Merge BLAST + HMMER results
echo "🔗 Merging BLAST and HMMER results..."
python3 merge_results.py
echo "✅ Done! All results are in the 'AMP_output' folder."
