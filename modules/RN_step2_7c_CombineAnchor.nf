process RN_step2_7a7b_CombineLib {
  //errorStrategy 'ignore' // Ignore errors
  tag "RN_step2_7a7b_CombineLib : ${sample_id}"
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

  readgroup=1
  ver=3
  hg=hg38
  gpu_partition="N"
  cutoff=0.99
 
  subject=${sample_id}


  outpath=\$(realpath "${outpath}")
  

  ###########################################
  ### Step7: Pairing the supporting reads ###
  ###########################################

  # Creating folders #


readgroup=6
sub=${subject}_Combined

cp ${params.masterpath}/Retronet/pipeline/*sh \${outpath}/\${sub}/script

export TMPDIR=\${outpath}/\${sub}/script
mkdir -p \${outpath}/\${sub}/temp

#CHECK IF THIS IS REQUIRED
tmppath=\${outpath}/\${sub}/temp
tmppath=\$(realpath "\${tmppath}")


#7a
singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif \\
	\${outpath}/\${sub}/script/7_CombineLib.sh \\
	-o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver} -s 0 -l \${readgroup} -g \${hg}

  """



}
