process BCF_TO_VCF {
    publishDir "$params.DEFAULT.outdir/variant_calling/delly", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.bcf_to_vcf.cluster_cpus
    memory params.bcf_to_vcf.cluster_memory
    time params.bcf_to_vcf.cluster_time

    input:
        tuple val(sample_id), path(bcf_file)

    output:
        path("${bcf_file.baseName}.vcf"), emit: vcf_output

    script:
        """
        bcftools view ${bcf_file} -Ov -o ${bcf_file.baseName}.vcf
        """
}
