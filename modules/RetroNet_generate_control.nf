process RetroNet_generate_control {
  //errorStrategy 'ignore' // Ignore errors
  tag "RetroNet_generate_control : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity), path(outpath)

output:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity), path ("${sample_id}/normal"), emit: all_outputs ,  optional: true


script:

  """
  module load singularity

  # -------- VARIABLES ----------------
  
  readgroup=1
  ver=3
  hg=hg38



  BAM_file=${normal}
  #mkdir -p ${sample_id}
  #outpath=${sample_id}
  sub=normal
  slurm_cpu_partition=tiny
  input_type=1
  num_control_BAM=1

  maxread=100

  # Need to Set masterpath in nextflow.config	
  #masterpath=/scratch/ew19/nandan/tools/RetroNet_optimiseCode_collateAndSplit/RetroNet

 # -----------------------------------

  # Enable error handling but continue the script on failure
  #set +e


outpath=\$(realpath "${outpath}")

tmppath=\${outpath}/\${sub}/temp
tmppath=\$(realpath "\${tmppath}")



export TMPDIR=\${outpath}/\${sub}/script

cp ${params.masterpath}/RetroNet/pipeline/*sh \${outpath}/\${sub}/script

singularity exec -B \${outpath},\${tmppath},${params.masterpath} \\
	${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/7b_generate_control.sh -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -l \${readgroup}






  """

} 
