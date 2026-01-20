process RN_step2_7a7b_CombineStrand01 {
  //errorStrategy 'ignore' // Ignore errors
  tag "RN_step2_7a7b_CombineStrand01 : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'

input:
  tuple val(sample_id), path(split1), path(split2), path(split3), path(split4), path(split5), path(split6), path(normal)


output:
  tuple val(sample_id), path(split1), path(split2), path(split3), path(split4), path(split5), path(split6), path(normal), path("${sample_id}_Combined") , emit: all_outputs ,  optional: true

script:

  """
  module load singularity

  # -------- VARIABLES ----------------

  # Default if there is no splitting of tumor bams) - Updated later in the script
  readgroup=1
  ver=3
  hg=hg38
  gpu_partition="N"
  
  # Changed on 200126 from cutoff=0.99 ; in retroNet paper it was 0.95 but again optimal was suggested to be at 0.8 -Check and confirm
  cutoff=0.80
 
  subject=${sample_id}


  outpath=\$(pwd)

  ###########################################
  ### Step7: Pairing the supporting reads ###
  ###########################################

  # Creating folders #

# As there are 6 subsetted tumor bams 
readgroup=6
sub=${sample_id}_Combined
mkdir \${outpath}/\${sub}
mkdir \${outpath}/\${sub}/reads
mkdir \${outpath}/\${sub}/align
mkdir \${outpath}/\${sub}/QC
mkdir \${outpath}/\${sub}/temp
mkdir \${outpath}/\${sub}/retro_v
mkdir \${outpath}/\${sub}/retro_v\${ver}
mkdir \${outpath}/\${sub}/script


### updating the location of the reference sequences ###
echo -e "Alu\t${params.masterpath}/refTE/sequence/ALU.fa" > ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "L1\t${params.masterpath}/refTE/sequence/L1HS.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "HERVK\t${params.masterpath}/refTE/sequence/HERVK.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "HERVH\t${params.masterpath}/refTE/sequence/HERVH.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "SVA\t${params.masterpath}/refTE/sequence/SVA.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed



cp ${params.masterpath}/RetroNet/pipeline/* \${outpath}/\${sub}/script

export TMPDIR=\${outpath}/\${sub}/script
mkdir -p \${outpath}/\${sub}/temp

#CHECK IF THIS IS REQUIRED
tmppath=\${outpath}/\${sub}/temp
tmppath=\$(realpath "\${tmppath}")


#7a 7b
singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/7_CombineLib.sh \\
	-o \${outpath} -j \${subject} -m ${params.masterpath} -v \${ver} -s 0 -l \${readgroup} -g \${hg}

singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
        \${outpath}/\${sub}/script/7_CombineLib.sh \\
        -o \${outpath} -j \${subject} -m ${params.masterpath} -v \${ver} -s 1 -l \${readgroup} -g \${hg}

singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/7a_Merge_Anchor.sh \\
	-o \${outpath} -j \${subject} -m ${params.masterpath} -v \${ver} -l \${readgroup}


cont=normal
partition_name=tiny
gpu_partition=N


#8_VisCoding LINE
singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
        \${outpath}/\${sub}/script/8_VisEncoding.sh \\
        -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -p \${partition_name} -g \${hg} -z \${gpu_partition} -c \${cont} -x \${cutoff} -t LINE -f L1HS

#8_VisCoding ALU
singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
        \${outpath}/\${sub}/script/8_VisEncoding.sh \\
        -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -p \${partition_name} -g \${hg} -z \${gpu_partition} -c \${cont} -x \${cutoff} -t ALU -f AluY

#8_VisCoding SVA
singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
        \${outpath}/\${sub}/script/8_VisEncoding.sh \\
        -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -p \${partition_name} -g \${hg} -z \${gpu_partition} -c \${cont} -x \${cutoff} -t SVA -f SVA


cd \${outpath}/\${sub}/script/


# 8csubmit9_Vis_L1
###########################################
### Step9: Draw PNG image of Supporting ###
###########################################
TEclass=LINE
TEfamily=L1HS


## Create PNG plot Job ##
split_row=1000
# Strand 1 #
split -l \${split_row} \${outpath}/\${sub}/calls_\${ver}/\${sub}.\${TEclass}.1.calls \${sub}.\${TEclass}.calls_\${ver}.1

for file in \${sub}.\${TEclass}.calls_\${ver}.1*; do

        singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
		\${outpath}/\${sub}/script/9_DrawPNG.sh -o \${outpath} -j \${sub} -m ${params.masterpath} -g \${hg} -i \${file} -t \${TEclass} -f \${TEfamily} -v \${ver} -s 1 -l candidate

done


# Strand 0 #
split -l \${split_row} \${outpath}/\${sub}/calls_\${ver}/\${sub}.\${TEclass}.0.calls \${sub}.\${TEclass}.calls_\${ver}.0

#Changed on 200126 from - for file in \${sub}.\${TEclass}.calls_\${ver}.1*; do
for file in \${sub}.\${TEclass}.calls_\${ver}.0*; do
	singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
                \${outpath}/\${sub}/script/9_DrawPNG.sh -o \${outpath} -j \${sub} -m ${params.masterpath} -g \${hg} -i \${file} -t \${TEclass} -f \${TEfamily} -v \${ver} -s 0 -l candidate


done





  """



}
