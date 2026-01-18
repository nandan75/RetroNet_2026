process RetroNet_step1_normal_DCSR {
  //errorStrategy 'ignore' // Ignore errors
  tag "RetroNet_step1_normal : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity)
  path (

script:

  """
  module load singularity


##################################################
### Step2: Discover candidate supporting reads (DSCR) ###
##################################################


# jid2
singularity exec -B \${outpath},${tmppath},${params.masterpath},\${BAM_file} \\
        ${params.masterpath}/pipeline/RetroNet.sif \\
        \${outpath}/\${sub}/script/2_RetroDiscover.sh -o \${outpath} -j \${sub} -m ${params.masterpath} -v \${ver}


