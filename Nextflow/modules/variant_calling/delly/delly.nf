process DELLY {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.delly.cluster_cpus
    memory params.delly.cluster_memory
    time params.delly.cluster_time

    input:
        path(reference_fna)
        tuple val(sample_id), path(bam_file), path(bam_index_file)
        val(delly_mode)

    output:
        tuple val(sample_id), path("${sample_id}.${delly_mode}.bcf"), emit: delly_bcf_output

    script:
        """
        delly call \\
            -t ${delly_mode} \\
            -h ${params.delly.cluster_cpus} \\
            -o ${sample_id}.${delly_mode}.bcf \\
            -q ${params.delly.mapping_quality} \\
            -s ${params.delly.insert_size_cutoff} \\
            -r ${params.delly.translocation_quality} \\
            -c ${params.delly.min_clip_length} \\
            -z ${params.delly.min_clique_size} \\
            -m ${params.delly.min_ref_separation} \\
            -n ${params.delly.max_read_separation} \\
            -p ${params.delly.max_reads_for_consensus} \\
            -g ${reference_fna} \\
            ${bam_file}
        """
}
