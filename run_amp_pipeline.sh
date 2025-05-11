#!/bin/bash

# =============================
# 🧪 AMP Prediction Pipeline
# Author: YOU 🧬
# Description: Predicts antimicrobial peptide-like ORFs using BLASTp and HMMER
# =============================

# 🔒 Safety: Exit if any command fails
set -e

# 🛑 Usage check
if [ "$#" -ne 3 ]; then
  echo "Usage: bash run_amp_pipeline.sh <transcriptome.fasta> <AMP_db.fasta> <tools/pfam_db/Pfam-A.hmm>"
  echo "Make sure tools (TransDecoder, HMMER) are in ./tools/"
  exit 1
fi

# 🎯 Inputs
TRANSCRIPTOME=$1
AMP_DB=$2
PFAM_DB=$3

# 📁 Output folder
mkdir -p AMP

# 🔧 Tool paths (change if your setup differs)
TD_LONGORFS=./tools/TransDecoder/TransDecoder.LongOrfs
TD_PREDICT=./tools/TransDecoder/TransDecoder.Predict
HMMSEARCH=hmmsearch
SEQKIT=seqkit  # Or use ./tools/seqkit/seqkit if local
MAKEBLASTDB=makeblastdb
BLASTP=blastp
PYTHON=python3
PFAM_DB=Pfam-A.hmm

# 📝 Logging output
exec > >(tee -i AMP/pipeline.log)
exec 2>&1

# Step 1: ORF prediction (min AA length = 10)
echo "🚀 Running TransDecoder.LongOrfs..."
$TD_LONGORFS -t $TRANSCRIPTOME --m 10

echo "🎯 Predicting best ORFs with TransDecoder.Predict..."
$TD_PREDICT -t $TRANSCRIPTOME --single_best_only

# Step 2: Filter ORFs between 10–100 AA
echo "🔎 Filtering peptides between 10 and 100 amino acids..."
PEP_FILE="$(basename ${TRANSCRIPTOME}).transdecoder.pep"
$SEQKIT seq -m 10 -M 100 $PEP_FILE > AMP/ORF.fasta

# Step 3: Make custom AMP BLAST database
echo "💾 Creating BLAST database from AMP sequences..."
$MAKEBLASTDB -in $AMP_DB -dbtype prot -out AMP/AMP_DB

# Step 4: Run BLASTp (Optimized for short peptides)
echo "⚔️ Running BLASTp search (short peptide mode)..."
$BLASTP -task blastp-short \
        -query AMP/ORF.fasta \
        -db AMP/AMP_DB \
        -evalue 0.001 \
        -outfmt "6 qseqid sseqid pident length evalue bitscore qstart qend sstart send" \
        -out AMP/output_blastp.txt

# 🧠 BLASTp hit check
if [ ! -s AMP/output_blastp.txt ]; then
  echo "⚠️ No hits found in BLASTp! Check your sequences or AMP DB."
else
  echo "✅ BLASTp hits found: $(wc -l < AMP/output_blastp.txt)"
fi

# Step 5: Run HMMER against Pfam
echo "🔬 Running HMMER search..."
$HMMSEARCH --tblout AMP/hmmer_output.tbl $PFAM_DB AMP/ORF.fasta > AMP/hmmer_raw.txt

# Step 6: Merge results using Python script
echo "📊 Merging BLAST and HMMER results..."
$PYTHON merge_results.py AMP/output_blastp.txt AMP/hmmer_output.tbl AMP/merged_output.txt

echo "✅ All steps completed. Output files are in AMP/ folder."
