#!/usr/bin/env python3

import pandas as pd

# Load filtered BLASTp results
blast_cols = [
    "QueryID", "TargetID", "Identity", "AlignLength", "Evalue", "BitScore",
    "Qstart", "Qend", "Sstart", "Send" 
]
blast_df = pd.read_csv("output_blastp.txt", sep="\t", names=blast_cols)

# Load HMMER results (skip comment lines)
hmmer_rows = []
with open("hmmer_output.tbl") as f:
    for line in f:
        if line.startswith("#"):
            continue
        parts = line.strip().split()
        hmmer_rows.append({
            "QueryID": parts[0],
            "Pfam_Acc": parts[3],
            "Pfam_Name": parts[2],
            "HMM_Evalue": parts[4]
        })
hmmer_df = pd.DataFrame(hmmer_rows)

# Merge on QueryID
merged_df = pd.merge(blast_df, hmmer_df, on="QueryID", how="left")

# Output final table
merged_df.to_csv("AMP/Final_AMP_Results.tsv", sep="\t", index=False)
print("✅ Merged results saved as AMP/Final_AMP_Results.tsv")
