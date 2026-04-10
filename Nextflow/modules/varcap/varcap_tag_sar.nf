process VARCAP_TAG_SAR {
    publishDir "$params.DEFAULT.outdir/varcap/sar", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${vcf_file.baseName}_sar.vcf"), emit: vcf_sar

    script:
        """
        SNPCOUNTMAX=${params.varcap.snpcountmax}
        SNPREGION=\$(( ${params.varcap.insert_size} * 2 ))

        perl /app_home/VarCap/scripts/vcffilter/filter_multi_snps_2vcf_2.pl \\
            ${vcf_file} \$SNPCOUNTMAX \$SNPREGION > ${vcf_file.baseName}_sar.vcf
        """
}
