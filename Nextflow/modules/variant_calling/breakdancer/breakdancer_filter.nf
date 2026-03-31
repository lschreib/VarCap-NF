process BREAKDANCER_FILTER {
    publishDir "$params.DEFAULT.outdir/variant_calling/breakdancer", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.breakdancer_config.cluster_cpus
    memory params.breakdancer_config.cluster_memory
    time params.breakdancer_config.cluster_time

    input:
        tuple val(sample_id), path(ctx_file)

    output:
        tuple val(sample_id), path("${sample_id}.breakdancer.filter"), emit: breakdancer_ctx_filtered

    script:
        """
        awk -v cutoff=${params.breakdancer_filter.cutoff_score} '
            /^#/ {
                print
                next
            }
            {
                score = \$12
                if (score != "NA" && score > cutoff) {
                    print
                }
            }
        ' ${ctx_file} > ${sample_id}.breakdancer.filter
        """
}
