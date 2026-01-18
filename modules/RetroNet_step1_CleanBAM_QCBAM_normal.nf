process RetroNet_step1_CleanBAM_QCBAM_normal {
  //errorStrategy 'ignore' // Ignore errors
  tag "CleanQCBAMNormal : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity)

output:
	tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity), path ("${sample_id}"), emit: all_outputs ,  optional: true 

script:

  """
  module load singularity

  # -------- VARIABLES ----------------
  BAM_file=${normal}
  mkdir -p ${sample_id}
  outpath=\$(realpath ${sample_id})
  sub=normal
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
mkdir \${outpath}/\${sub}
mkdir \${outpath}/\${sub}/reads
mkdir \${outpath}/\${sub}/align
mkdir \${outpath}/\${sub}/QC
mkdir \${outpath}/\${sub}/temp
mkdir \${outpath}/\${sub}/retro_v
mkdir \${outpath}/\${sub}/retro_v\${ver}
mkdir \${outpath}/\${sub}/script
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
