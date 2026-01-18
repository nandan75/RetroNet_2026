process collate_and_split_tumor_files {
  //errorStrategy 'ignore' // Ignore errors
  tag "collate_and_split_tumor_files : ${sample_id}"
  //container 'oras://community.wave.seqera.io/library/diamond_humann_metaphlan:48aa97aac98f2538'
  //container diamond_humann_metaphlan_sif
  //publishDir "${params.outdir}/${sample_id}/tumour_normal/", mode: 'symlink'


input:
  tuple val(sample_id), path(tumor), path(normal), path(tumor_bai), path(normal_bai), val(purity)

output:
  tuple val(sample_id), path("shard_*.bam") , emit: bam_shards


script:

"""

collate_and_split_tumor_files.sh ${sample_id} ${tumor} ${tumor_bai}


"""

}
