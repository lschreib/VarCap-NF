process PICARD_ADD_READ_GROUP {
    //publishDir "$params.DEFAULT.outdir/read_mapping/insert_size", mode: 'copy'
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.picard_add.cluster_cpus
    memory params.picard_add.cluster_memory
    time params.picard_add.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.rg.bam"), emit:read_group_bam

    script:
        """
        java -Xmx${params.picard_add.java_xmx} \\
            -XX:-UsePerfData \\
            -jar /usr/picard/picard.jar \\
            AddOrReplaceReadGroups \\
            I=${bam_file} \\
            O=${sample_id}.rg.bam \\
            LB=D \\
            PL=illumina \\
            PU=S \\
            SM=B \\
            VALIDATION_STRINGENCY=LENIENT \\
            CREATE_INDEX=false
        """
}
