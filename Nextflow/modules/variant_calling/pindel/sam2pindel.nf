process SAM2PINDEL {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_mpileup.cluster_cpus
    memory params.samtools_mpileup.cluster_memory
    time params.samtools_mpileup.cluster_time

    input:
        tuple val(sample_id), path(sam_file), path(insert_size_file)

    output:
        tuple val(sample_id), path("${sample_id}.pindel.txt"), emit: pindel_output

    script:
        """
        INSERT_SIZE=\$(grep -v "^#" ${insert_size_file} | grep -v "^\$" | head -2 | tail -1 | awk '{print \$1}') && \\
        echo "Using insert size: \$INSERT_SIZE" && \\
        sam2pindel ${sam_file} ${sample_id}.pindel.txt \$INSERT_SIZE varcap_nf 0 Illumina-PairEnd
        """
}
