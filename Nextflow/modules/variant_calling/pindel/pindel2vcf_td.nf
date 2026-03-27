process PINDEL2VCF_TD {
    publishDir "$params.DEFAULT.outdir/variant_calling/pindel", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.pindel2vcf.cluster_cpus
    memory params.pindel2vcf.cluster_memory
    time params.pindel2vcf.cluster_time

    input:
        path(reference_index)
        path(reference_fna)
        tuple val(sample_id), path(pindel_tandups_file)

    output:
        path("${sample_id}_TD.vcf"), emit: pindel_vcf_tandups

    script:
        """
        pindel2vcf \\
            -G \\
            -p ${pindel_tandups_file} \\
            -r ${reference_fna} \\
            -R v1 \\
            -d 20260327 \\
            -v ${sample_id}_TD.vcf
        """
}
