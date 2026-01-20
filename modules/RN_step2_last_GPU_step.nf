process RN_step2_last_GPU_step {
  //errorStrategy 'ignore' // Ignore errors
  tag "RN_step2_last_GPU_step : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'
  publishDir "${params.outdir}/", mode: 'copy'


input:
  tuple val(sample_id), path(split1), path(split2), path(split3), path(split4), path(split5), path(split6), path(normal), path(sampleid_combined) 

output:
  tuple val(sample_id), path("*_Combined/retro_v3/*_Combined.LINE.bed"), emit: L1_bed ,  optional: true 

script:
  """
  module load singularity

  ###############################
  ### Step10: RetroNet Predict ##
  ###############################
  
  ver=3
  hg=hg38
  
  # Changed on 200126 from cutoff=0.99
  cutoff=0.80
  
  sub=${sample_id}_Combined

  outpath=\$(pwd)

  export TMPDIR=\${outpath}/\${sub}/script
  mkdir -p \${outpath}/\${sub}/temp
  tmppath=\${outpath}/\${sub}/temp
  tmppath=\$(realpath "\${tmppath}") 	

  cd \${outpath}/\${sub}/script/  

  TEclass=LINE
  TEfamily=L1HS

  singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/10_RunRetroNet.sh \\
	-o \${outpath} -j \${sub} -t \${TEclass} -v \${ver} -m ${params.masterpath} -x \${cutoff} -g \${hg}


  """
 
}

 
