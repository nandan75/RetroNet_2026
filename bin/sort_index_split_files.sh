#!/bin/bash
  
module load samtools/1.19

TMPDIR="/scratch/ew19/nandan/datasets/sam_long_reads/TMPDIR"

module load samtools/1.19

subject_id="$1"
shift
bam_files=("$@")  # All remaining arguments are BAM files

i=1
for bam in "${bam_files[@]}"; do
    output_bam="${subject_id}-${i}.bam"
    samtools sort -o "$output_bam" -@ 16 "$bam"
    samtools index -@ 16 "$output_bam" "$output_bam.bai"
    ((i++))
done


