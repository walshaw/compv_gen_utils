#!/bin/bash

# This uses the 2018 version of the ATCC 29149 genome as the fixed reference,
# and reorders the contigs of each of the other 17 genomes against it. Uses
# Mauve contig-reordering in batch mode - see:
# http://darlinglab.org/mauve/user-guide/reordering.html
# (don't go off on a wild goose-chase with directly invoking progressiveMauve
# like I first did).

MAUVE_TOP_DIR=../mauve_snapshot_2015-02-13
MAUVE_BIN_DIR=$MAUVE_TOP_DIR/linux-x64

if [[ ! -d $MAUVE_TOP_DIR ]]; then
    echo "Mauve directory $MAUVE_TOP_DIR does not exist"
    exit 1
fi

if [[ ! -d $MAUVE_BIN_DIR ]]; then
    echo "Mauve bin directory $MAUVE_BIN_DIR does not exist"
    exit 1
fi

if [[ ! -f $MAUVE_BIN_DIR/progressiveMauve ]]; then
    echo "progressiveMauve executable $MAUVE_BIN_DIR/progressiveMauve does not exist"
    exit 1
fi


GENOMES_DIR=../../all_genomes

GENOME_SUFFIX=_genomic.fna

# this is ATCC 29149, 2018 version (Mount Sinai Hospital)
REFERENCE_GENOME=GCF_002959615.1_ASM295961v1

REFERENCE_FASTA="$GENOMES_DIR/${REFERENCE_GENOME}$GENOME_SUFFIX"

if [[ -f $REFERENCE_FASTA ]]; then
    echo "reference genome sequence file ($REFERENCE_FASTA):"
    ls $REFERENCE_FASTA
else
    echo "can't find reference genome sequence file $REFERENCE_FASTA"
    exit 1
fi

for QUERY_GENOME in $( ls $GENOMES_DIR/*$GENOME_SUFFIX ); do

    QUERY_GENOME_NOPATH=`basename $QUERY_GENOME`
    if [[ $QUERY_GENOME_NOPATH == "${REFERENCE_GENOME}$GENOME_SUFFIX" ]]; then
        echo "skipping $REFERENCE_GENOME (reference genome)"
        continue
    fi

    QUERY_GENOME_NAME=`basename $QUERY_GENOME $GENOME_SUFFIX`
    OUTPUT_DIR=${QUERY_GENOME_NAME}__v__$REFERENCE_GENOME
    echo "output dir for genome $QUERY_GENOME_NAME will be: $OUTPUT_DIR"

    MAUVE="java -Xmx500m -cp $MAUVE_TOP_DIR/Mauve.jar \
    org.gel.mauve.contigs.ContigOrderer -output $OUTPUT_DIR \
    -ref $REFERENCE_FASTA \
    -draft $QUERY_GENOME"

    echo $MAUVE
    eval $MAUVE

    echo
    echo

done


