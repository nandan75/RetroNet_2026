process sort_index_split_files {
  //errorStrategy 'ignore' // Ignore errors
  tag "sort_index_split_files : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(bam_list)

output:
  path("*.bam"), emit: bams
  path("*.bam.bai"), emit: bais

script:

"""

sort_index_split_files.sh ${sample_id} ${bam_list.join(' ')}


"""

}
