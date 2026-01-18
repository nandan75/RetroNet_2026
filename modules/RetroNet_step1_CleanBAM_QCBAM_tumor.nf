process RetroNet_step1_CleanBAM_QCBAM_tumor {
  //errorStrategy 'ignore' // Ignore errors
  tag "CleanQCBAMTumor : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), val(count), path(tumor), path(tumor_bai)

output:
  tuple val(sample_id),val(count), path(tumor), path(tumor_bai), path ("${sample_id}"), emit: all_outputs ,  optional: true

script:

  """
  module load singularity

  # -------- VARIABLES ----------------
  BAM_file=${tumor}
  mkdir -p ${sample_id}
  outpath=\$(realpath ${sample_id})

  sample_id=${sample_id}-${count}
  sub=\${sample_id}

  #BAM_file=${tumor}
  #sample_id=${sample_id}-${count}  
  #mkdir -p \${sample_id}

  #outpath=\$(realpath \${sample_id})
  #sub=normal
  
  #outpath=\$(pwd)
  #sub=\$(realpath \${sample_id})

  slurm_cpu_partition=tiny
  input_type=1
  num_control_BAM=1

  ver=3
  hg=hg38
  maxread=100

  # Need to Set masterpath in nextflow.config	
  #masterpath=/scratch/ew19/nandan/tools/RetroNet_optimiseCode_collateAndSplit/RetroNet
   
 # -----------------------------------

  # Enable error handling but continue the script on failure
  #set +e

  #1. Analyze the normal tissue
  
######################################
### Step0: Creating output folders ###
######################################
mkdir -p \${outpath}/\${sub}
mkdir -p \${outpath}/\${sub}/reads
mkdir -p \${outpath}/\${sub}/align
mkdir -p \${outpath}/\${sub}/QC
mkdir -p \${outpath}/\${sub}/temp
mkdir -p \${outpath}/\${sub}/retro_v
mkdir -p \${outpath}/\${sub}/retro_v\${ver}
mkdir -p \${outpath}/\${sub}/script
echo "DUMMY" > dummy.txt 


# HASHED ND
#cd \${outpath}/\${sub}/script

cp ${params.masterpath}/pipeline/*sh \${outpath}/\${sub}/script
#cp ${params.masterpath}/pipeline/*sh ./

#cd \${outpath}/\${sub}/script

### updating the location of the reference sequences ###
echo -e "Alu\t${params.masterpath}/refTE/sequence/ALU.fa" > ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "L1\t${params.masterpath}/refTE/sequence/L1HS.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "HERVK\t${params.masterpath}/refTE/sequence/HERVK.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "HERVH\t${params.masterpath}/refTE/sequence/HERVH.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
echo -e "SVA\t${params.masterpath}/refTE/sequence/SVA.fa" >> ${params.masterpath}/refTE/TE_ALHS.bed
 

tmppath=\${outpath}/\${sub}/temp


##################################
### Step1: CleanBAM and QC_BAM ###
##################################

# jid1

\${outpath}/\${sub}/script/1_CleanBAM_QCBAM.sh -o \${outpath} -j \${sub} -b \${BAM_file}

  """

} 
