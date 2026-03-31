process BREAKDANCER_MAX {
    publishDir "$params.DEFAULT.outdir/variant_calling/breakdancer/ctx", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.breakdancer_config.cluster_cpus
    memory params.breakdancer_config.cluster_memory
    time params.breakdancer_config.cluster_time

    input:
        tuple val(sample_id), path(breakdancer_config), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.breakdancer.ctx"), emit: breakdancer_ctx

    script:
        """
        breakdancer-max \\
            -s ${params.breakdancer_max.min_length_region} \\
            -q ${params.breakdancer_max.min_alternative_mapping_quality} \\
            -r ${params.breakdancer_max.min_supporting_pairs} \\
            ${breakdancer_config} > ${sample_id}.breakdancer.ctx
        """
}
