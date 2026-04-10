process VARCAP_TAG_REPEATS {
    publishDir "$params.DEFAULT.outdir/varcap/repeats", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time


    input:
        path(ref_repeat_vcf)
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${vcf_file.baseName}_rep.vcf"), emit: rep_vcf

    script:
        """
        grep -e '^#' ${vcf_file} > ${vcf_file.baseName}_rep.vcf
        perl /app_home/VarCap/scripts/vcffilter/vcf_contains_pos2.pl ${vcf_file} ${ref_repeat_vcf} >> ${vcf_file.baseName}_rep.vcf
        """
}