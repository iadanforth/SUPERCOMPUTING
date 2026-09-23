#!/bin/bash
FASTA_FILE=$1

NUM_SEQ=$("$SEQTK_BIN" size "$FASTA_FILE" | cut -f1)

NUM_BP=$("$SEQTK_BIN" size "$FASTA_FILE" | cut -f2)

TABLE=$("$SEQTK_BIN" comp "$FASTA_FILE" | cut -f1,2)

# OUTPUT
echo "here are the number of sequences contained within the file $FASTA_FILE"
echo "$NUM_SEQ"

echo "here are the number of base pairs across all sequences in the file $FASTA_FILE"
echo "$NUM_BP"

echo "lastly, here are the names for all sequences in as well as the number of nucleotides in each sequence for the file $FASTA_FILE"
echo "$TABLE"
