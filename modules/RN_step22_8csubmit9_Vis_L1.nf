process RN_step22_8csubmit9_Vis_L1 {
  //errorStrategy 'ignore' // Ignore errors
  tag "RN_step22_8csubmit9_Vis_L1 : ${sample_id}"
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
  
cont=normal
readgroup=6
sub=${subject}_Combined
partition_name=tiny
gpu_partition=N
cutoff=0.99


//cp ${params.masterpath}/Retronet/pipeline/*sh \${outpath}/\${sub}/script

export TMPDIR=\${outpath}/\${sub}/script
mkdir -p \${outpath}/\${sub}/temp

#CHECK IF THIS IS REQUIRED
tmppath=\${outpath}/\${sub}/temp
tmppath=\$(realpath "\${tmppath}")


# 8csubmit9_Vis_L1
###########################################
### Step9: Draw PNG image of Supporting ###
###########################################
TEclass=LINE
TEfamily=L1HS


## Create PNG plot Job ##
split_row=1000
# Strand 1 #
split -l \${split_row} \${outpath}/\${sub}/calls_\${ver}/\${sub}.\${TEclass}.1.calls \${sub}.\${TEclass}.calls_\${ver}.1

for file in \${sub}.\${TEclass}.calls_\${ver}.1*; do

	singularity\n'"singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif ./9_DrawPNG.sh -o $outpath -j \${sub} -m ${params.masterpath} -g \${hg} -i ${file} -t \${TEclass} -f \${TEfamily} -v \${ver} -s 1 -l candidate

done

# Strand 0 #
split -l \${split_row} \${outpath}/\${sub}/calls_\${ver}/\${sub}.\${TEclass}.0.calls \${sub}.\${TEclass}.calls_\${ver}.0

for file in \${sub}.\${TEclass}.calls_\${ver}.1*; do

        singularity\n'"singularity exec -B \${outpath},\${tmppath},${params.masterpath} ${params.masterpath}/pipeline/RetroNet.sif ./9_DrawPNG.sh -o $outpath -j \${sub} -m ${params.masterpath} -g \${hg} -i ${file} -t \${TEclass} -f \${TEfamily} -v \${ver} -s 0 -l candidate

done







  """



}
