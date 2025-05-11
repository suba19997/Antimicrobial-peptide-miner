# 🧪 AMP Prediction Pipeline

Welcome to the **AMP Prediction Pipeline**, a streamlined bash workflow that identifies antimicrobial peptide (AMP)-like open reading frames (ORFs) from transcriptome data using **TransDecoder**, **BLASTp**, and **HMMER**. 🧬

> ⚡ Designed for short peptides (10–100 amino acids). Fast. Flexible. Functional.

---

## 📂 What It Does

1. **Predicts ORFs** using TransDecoder
2. **Filters peptides** by length (10–100 AA)
3. **Searches peptides** against a custom AMP database using `blastp-short`
4. **Validates hits** using domain profiles with HMMER
5. **Merges results** for easy downstream interpretation

---

## 🛠️ Requirements

Ensure these tools are available (either in your `$PATH` or under a `./tools/` directory):

- [TransDecoder](https://github.com/TransDecoder/TransDecoder)
- [HMMER](http://hmmer.org/)
- [BLAST+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download)
- [seqkit](https://bioinf.shenwei.me/seqkit/)
- Python 3+

---

## 🧬 Input Files

| Input | Description |
|-------|-------------|
| `transcriptome.fasta` | Transcriptome assembly in FASTA format |
| `AMP_db.fasta` | Custom AMP protein database |
| `Pfam-A.hmm` | HMM profile database (e.g., Pfam-A) |

---

## 🚀 Usage

```bash
bash run_amp_pipeline.sh <transcriptome.fasta> <AMP_db.fasta> <Pfam-A.hmm>

## Output Files (in AMP/ folder)

ORF.fasta	ORFs between 10–100 AA
output_blastp.txt	BLASTp hits against AMP DB
hmmer_output.tbl	HMMER domain search output
merged_output.txt	Combined results (BLASTp + HMMER)
pipeline.log	Log of the run
