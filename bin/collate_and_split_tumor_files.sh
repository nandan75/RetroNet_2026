#!/bin/bash
 
subjectID="$1"
bam_file="$2"
bai_file="$3"

module load samtools/1.19

TMPDIR="/scratch/ew19/nandan/datasets/sam_long_reads/TMPDIR"
num_chunks=6

# Step 1: Specify a Custom Temporary Directory and Collate
export TMPDIR


# OMIT collate step - Checking on 031125
#echo "Collating BAM file..."
#samtools collate ${bam_file} -o ${subjectID}_collated.bam
# It is observed that the output file created is temp_collated.bam and an empty ${subjectID}_collated.bam, So ...
#mv temp_collated.bam ${subjectID}_collated.bam


module load singularity
module load gatk/4.2.5.0


singularity_path=/scratch/ew19/nandan/tools/singularity_containers

#singularity exec ${singularity_path}/gatk4-spark_picard_samtools_d529ac6bdae54281.sif picard SplitSamByNumberOfReads \
#    -I ${bam_file} \
#    -O ./ \
#    --SPLIT_TO_N_FILES 6


gatk SplitSamByNumberOfReads \
    -I ${bam_file} \
    -O ./ \
    --SPLIT_TO_N_FILES 6



