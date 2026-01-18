process RetroNet_step1_afterRetroDSteps3T6_tumor {
  //errorStrategy 'ignore' // Ignore errors
  tag "S1afterRetroDSteps3T6_tumor : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'

input:
  tuple val(sample_id), val(count), path(tumor), path(tumor_bai), path(outpath)

output:
  tuple val(sample_id), val(count), path(tumor), path(tumor_bai), path("${outpath}/${sample_id}-${count}") , emit: all_outputs ,  optional: true

script:

  """
  module load singularity

  # -------- VARIABLES ----------------
  BAM_file=${tumor}

  outpath=\$(realpath "${outpath}")

  sample_id=${sample_id}-${count}
  
  sub=\${sample_id}

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

 #1. Analyze the tumor tissue

 export TMPDIR=\${outpath}/\${sub}/script
 mkdir -p \${outpath}/\${sub}/temp
  
 tmppath=${outpath}/\${sub}/temp
 tmppath=\$(realpath "\${tmppath}")


 echo "outpath: \${outpath}"
 echo "tmppath: \${tmppath}"
 echo "masterpath: ${params.masterpath}"


# jid3
########################################################
### Step3: > Putative MEIs                           ###
###        > Remapping L1HS or AluY specific Alleles ###
###        > Matricies for L1/Alu supporting reads   ###
###        > Level1 prediction with RF, NB and LR    ###
########################################################

# ND 
cd \${outpath}/\${sub}/script

singularity exec -B \${outpath},\${tmppath},${params.masterpath} \\
	${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/3_step3to6.sh -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -g \${hg}

  """

} 
