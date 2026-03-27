process PICARD_INSERT_SIZE {
    publishDir "$params.DEFAULT.outdir/read_mapping/insert_size", mode: 'copy'
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.picard_ins.cluster_cpus
    memory params.picard_ins.cluster_memory
    time params.picard_ins.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.IS.pdf"), emit:insert_pdf
        tuple val(sample_id), path("${sample_id}.IS.txt"), emit:insert_txt

    script:
        """
        java -jar /usr/picard/picard.jar \\
            CollectInsertSizeMetrics \\
            I=${bam_file} \\
            H=${sample_id}.IS.pdf \\
            O=${sample_id}.IS.txt
        """
}
