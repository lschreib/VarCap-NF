process PINDEL_CALL {
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.pindel_call.cluster_cpus
    memory params.pindel_call.cluster_memory
    time params.pindel_call.cluster_time

    input:
        path(reference_index)
        path(reference_fna)
        tuple val(sample_id), path(pindel_text_file)

    output:
        tuple val(sample_id), path("${sample_id}_D"),   emit: pindel_deletions
        tuple val(sample_id), path("${sample_id}_SI"),  emit: pindel_insertions
        tuple val(sample_id), path("${sample_id}_INV"), emit: pindel_inversions
        tuple val(sample_id), path("${sample_id}_TD"),  emit: pindel_tandups

    script:
        """
        pindel \\
            -T ${params.pindel_call.cluster_cpus} \\
            -f ${reference_fna} \\
            -p ${pindel_text_file} \\
            -c ALL \\
            -o ${sample_id}
        """
}
