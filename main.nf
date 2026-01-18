#!/usr/bin/env nextflow

// To use DSL-2 will need to include this
nextflow.enable.dsl=2

// Default command to launch is:
//                              nextflow run main.nf -profile [load_profile],[dataset_profile]
//                              where [load_profile] is the profile for your machine and [dataset_profile] the one for your datasets paths and variables!



//params.fqpattern = "*.bam"

// Import processes or subworkflows to be run in the workflow

// RetroNet

// =======NORMAL bam  Steps from Singularity_PBS_RetroNet_step1.sh

include { RetroNet_step1_CleanBAM_QCBAM_normal } from './modules/RetroNet_step1_CleanBAM_QCBAM_normal'
include { RetroNet_step1_RetroDiscover_normal } from './modules/RetroNet_step1_RetroDiscover_normal'

include { RetroNet_step1_afterRetroDSteps3T6_normal } from './modules/RetroNet_step1_afterRetroDSteps3T6_normal' 
include { RetroNet_generate_control } from './modules/RetroNet_generate_control'

// ======TUMOR 

include { collate_and_split_tumor_files } from './modules/collate_and_split_tumor_files'
include { sort_index_split_files } from './modules/sort_index_split_files'

// STEP1
include { RetroNet_step1_CleanBAM_QCBAM_tumor } from './modules/RetroNet_step1_CleanBAM_QCBAM_tumor'
include { RetroNet_step1_RetroDiscover_tumor } from './modules/RetroNet_step1_RetroDiscover_tumor'
include { RetroNet_step1_afterRetroDSteps3T6_tumor } from './modules/RetroNet_step1_afterRetroDSteps3T6_tumor'

// STEP2


include { RN_step2_7a7b_CombineStrand01 } from './modules/RN_step2_7a7b_CombineStrand01'

include { RN_step2_last_GPU_step } from './modules/RN_step2_last_GPU_step'


// Print a header for your pipeline
log.info """\

=======================================================================================
O N T - B A C P A C K - nf
=======================================================================================

Created by TODO NAME
Find documentation @ TODO INSERT LINK
Cite this pipeline @ TODO INSERT DOI

=======================================================================================
Workflow run parameters
=======================================================================================
input       : ${params.input}
results     : ${params.outdir}
workDir     : ${workflow.workDir}
=======================================================================================

"""


/// Help function
// This is an example of how to set out the help function that
// will be run if run command is incorrect or missing.

def helpMessage() {
    log.info"""
  Usage:  nextflow run main.nf --input_directory <path to directory>

  Required Arguments:

  --input_directory   Specify full path and name of directory.
//  --samplesheet       Spectify full path and name of samplesheet csv.

  Optional Arguments:

  --outdir              Specify path to output directory.
  --multiqc_config      Configure multiqc reports
  --sequencing_summary  Sequencing summary log from sequencer

""".stripIndent()
}



// Define workflow structure. Include some input/runtime tests here.
// See https://www.nextflow.io/docs/latest/dsl2.html?highlight=workflow#workflow
workflow {
    if (!params.samples) {
        error "Missing required parameter: --samples"
    }


    bamFilesChannel = Channel
    .fromPath(params.samples)
    .splitCsv(header: true)
    .map { row -> 
        def sample_id = row.sample_id
        def tumor = file(row.tumor_path)
        def normal = file(row.normal_path)
 
        def tumor_bai = file(row.tumor_bai_path)
        def normal_bai = file(row.normal_bai_path)

	def purity = row.purity.toDouble() 
    
        tuple(sample_id, tumor, normal, tumor_bai, normal_bai, purity)
    }
    

    // RUN RetroNet


    // Sample Normal
    // STEP1
    //Including steps from Singularity_PBS_RetroNet_step1.sh

    RetroNet_step1_CleanBAM_QCBAM_normal(bamFilesChannel)

    input_to_RetroDiscover = RetroNet_step1_CleanBAM_QCBAM_normal.out.all_outputs
   
    RetroNet_step1_RetroDiscover_normal(input_to_RetroDiscover)

    input_to_afterRetroDSteps3T6 = RetroNet_step1_RetroDiscover_normal.out.all_outputs
    RetroNet_step1_afterRetroDSteps3T6_normal(input_to_afterRetroDSteps3T6) 


    // Step from Singularity_PBS_RetroNet_generate_control.sh
    input_to_RetroNet_generate_control = RetroNet_step1_afterRetroDSteps3T6_normal.out.all_outputs
    RetroNet_generate_control(input_to_RetroNet_generate_control)
     

    // SPLIT TUMOR bam   
    collate_and_split_tumor_files(bamFilesChannel)

    collate_and_split_tumor_files.out.bam_shards.set { bam_list_channel }
    //bam_list_channel.view()


    sort_index_split_files(bam_list_channel) 

    // ============= Mapping the bams to bam.bai across subsets samples

    // 1. Assume these channels come from your previous process
    bam_channel = sort_index_split_files.out.bams
    bai_channel = sort_index_split_files.out.bais


    // =============

    // 1. This splits the list into individual paths
  bam_channel
    .flatten()
    .map { bam_path ->
        // Convert to Path object (if needed)
        def bam = file(bam_path)

        // Get filename without extension
        def bam_name = bam.getBaseName()  // e.g. subset10_LKCGP-P002501-1

        // Extract sample ID and shard number
        def sample_id = bam_name.replaceFirst(/-\d+$/, '')  // remove -1, -2, etc.
        def shard_num = (bam_name =~ /-(\d+)$/)[0][1].toInteger()

        // Construct corresponding BAI path
        def bai = file(bam.toString() + '.bai')

        // Emit tuple
        tuple(sample_id, shard_num, bam, bai)
    }
    .set { bam_bai_tuples }

    //input_to_RetroNet_generate_control.view()
    //bam_bai_tuples.view()


    // STEP1
    // TO BE RUN for each split

    //Step in Singularity_PBS_RetroNet_step1.sh

    RetroNet_step1_CleanBAM_QCBAM_tumor(bam_bai_tuples)
    
    //RetroNet_step1_CleanBAM_QCBAM_tumor.out.all_outputs.view()

    input_to_RetroDiscover_tumor = RetroNet_step1_CleanBAM_QCBAM_tumor.out.all_outputs
    RetroNet_step1_RetroDiscover_tumor(input_to_RetroDiscover_tumor)

    input_to_afterRetroDSteps3T6_tumor = RetroNet_step1_RetroDiscover_tumor.out.all_outputs
    all_outputs = RetroNet_step1_afterRetroDSteps3T6_tumor(input_to_afterRetroDSteps3T6_tumor)
    
    //all_outputs_normal = RetroNet_step1_afterRetroDSteps3T6_normal.out.all_outputs
    all_outputs_normal = RetroNet_generate_control.out.all_outputs


    //all_outputs.view()
    //all_outputs_normal.view()

    grouped_all_outputs = all_outputs
    .groupTuple()
    //.view() // Check the structure of the grouped output

    //grouped_all_outputs.view() 
 
    simplified_tuple = grouped_all_outputs.map { full_tuple ->
    def subset_id = full_tuple[0]
    def base_paths = full_tuple[4]
    return [subset_id, base_paths]
}
    //bam_bai_tuples.view()

    //simplified_tuple.view()
    //all_outputs_normal.view()



    joined_ch = simplified_tuple.join(all_outputs_normal) 
    //joined_ch.view()

    input_tuple_7a7b_CombineStrand = joined_ch.map { tuple ->
    def sample_id = tuple[0]
    def list_paths = tuple[1]  // this is a List
    def last_element = tuple[-1]
    return [sample_id] + list_paths + [last_element]
}

    //input_tuple_7a7b_CombineStrand.view()


    // STEP 2
    //Singularity_PBS_RetroNet_step2.sh 
    
    RN_step2_7a7b_CombineStrand01(input_tuple_7a7b_CombineStrand)

    input_tuple_last_GPU_step = RN_step2_7a7b_CombineStrand01.out.all_outputs
    RN_step2_last_GPU_step(input_tuple_last_GPU_step)



	}


    


