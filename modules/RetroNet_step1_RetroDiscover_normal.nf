process RetroNet_step1_RetroDiscover_normal {
  //errorStrategy 'ignore' // Ignore errors
  tag "RetroDiscover_normal : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity), path(outpath) 

output:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity), path ("${sample_id}"), emit: all_outputs ,  optional: true 

script:

  """
  module load singularity

  # -------- VARIABLES ----------------
  BAM_file=${normal}
  #BAM_file_path=\$(dirname \"${normal}\")
  BAM_file_path=\$(realpath "${normal}")


  #mkdir -p ${sample_id}
  #outpath=\$(dirname \"${outpath}\")
  outpath=\$(realpath "${outpath}")

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
  
  export TMPDIR=\${outpath}/\${sub}/script
  mkdir -p \${outpath}/\${sub}/temp

  tmppath=\${outpath}/\${sub}/temp 
  tmppath=\$(realpath "\${tmppath}")

  echo "outpath: \${outpath}"
  echo "tmppath: \${tmppath}"
  echo "BAM_file_path: \${BAM_file_path}"
  echo "ver: \${ver}" 


  singularity exec -B \${outpath},\${tmppath},${params.masterpath},\${BAM_file_path} ${params.masterpath}/pipeline/RetroNet.sif \\
  	\${outpath}/\${sub}/script/2_RetroDiscover.sh \\
  	-o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver}


  """

} 
