process VARCAP_TAG_HOMOPOLYMERS {
    publishDir "$params.DEFAULT.outdir/varcap/homopolymers", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time



    input:
        path(reference_fa)
        tuple val(sample_id), path(rep_vcf)

    output:
        tuple val(sample_id), path("${rep_vcf.baseName}_hopo.vcf"), emit: hopo_vcf

    script:
        """
        perl /app_home/VarCap/scripts/vcffilter/filter_homopolymers.pl ${rep_vcf} ${reference_fa} > ${rep_vcf.baseName}_hopo.vcf
        """
}