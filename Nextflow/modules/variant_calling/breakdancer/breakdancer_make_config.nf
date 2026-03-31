process BREAKDANCER_MAKE_CONFIG {
    publishDir "$params.DEFAULT.outdir/variant_calling/breakdancer/config", mode: 'copy', pattern: "*breakdancer.cfg"
    publishDir "$params.DEFAULT.outdir/variant_calling/breakdancer/histogram", mode: 'copy', pattern: "*insertsize_histogram*"
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.breakdancer_config.cluster_cpus
    memory params.breakdancer_config.cluster_memory
    time params.breakdancer_config.cluster_time

    input:
        tuple val(sample_id), path(bam_file), path(bam_index_file)

    output:
        tuple val(sample_id), path("${sample_id}.breakdancer.cfg"), emit: breakdancer_config
        tuple val(sample_id), path("*insertsize_histogram"), emit: histogram_text
        tuple val(sample_id), path("*insertsize_histogram.png"), emit: histogram_png

    script:
        """
        perl /opt/conda/envs/Breakdancer/bin/bam2cfg.pl \\
            -n 500000 \\
            -h \\
            -t ${params.breakdancer_config.fraction_trim} \\
            ${bam_file} > ${sample_id}.breakdancer.cfg && \
        sed -i "s/lower\\:[0-9]*\\.*[0-9]*/lower\\:${params.DEFAULT.read_length}/" ${sample_id}.breakdancer.cfg
        """
}
