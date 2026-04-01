process CORTEX_K61 {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.cortex_binary.cluster_cpus
    memory params.cortex_binary.cluster_memory
    time params.cortex_binary.cluster_time

    input:
        path(reference_fna)

    output:
        path("ref.k61.ctx"), emit: cortex_k61_binary

    script:
        """
        echo ${reference_fna} > file_listing_fasta
        /cortex/bin/cortex_var_63_c1 \\
            --kmer_size 61 \\
            --mem_height ${params.cortex_binary.mem_height} \\
            --mem_width ${params.cortex_binary.mem_width} \\
            --se_list file_listing_fasta \\
            --dump_binary ref.k61.ctx \\
            --sample_id REF
        """
}
