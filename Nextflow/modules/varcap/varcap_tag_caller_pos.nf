process VARCAP_TAG_CALLER_POS {
    publishDir "$params.DEFAULT.outdir/varcap/caller_position", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${vcf_file.baseName}_cpv.vcf"), emit: vcf_cpv

    script:
        """
        CPV=${params.varcap.cpv}

        perl /app_home/VarCap/scripts/vcffilter/filter_caller2pos.pl \\
            ${vcf_file} \$CPV > ${vcf_file.baseName}_cpv.vcf
        """
}
