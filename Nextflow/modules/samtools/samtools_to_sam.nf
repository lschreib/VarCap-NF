process SAMTOOLS_TO_SAM {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_sam.cluster_cpus
    memory params.samtools_sam.cluster_memory
    time params.samtools_sam.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.sam"), emit: sam_output
    
    script:
        """
        samtools view -O SAM -o ${sample_id}.sam ${bam_file}
        """
}
