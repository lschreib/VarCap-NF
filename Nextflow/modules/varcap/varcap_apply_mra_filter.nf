process VARCAP_APPLY_MRA_FILTER {
    publishDir "$params.DEFAULT.outdir/varcap/mra", mode: 'copy'
    errorStrategy 'finish'
    cpus params.varcap_apply_mra_filter.cluster_cpus
    memory params.varcap_apply_mra_filter.cluster_memory
    time params.varcap_apply_mra_filter.cluster_time

    // Section 5: Apply MRA (Minimum Read Allele frequency) filter
    // Mirrors D02_filter_vcf.sh lines 201-247
    // Single MRA value mode (one mra_cutoff per run):
    //   - filter_vcfs_2vcf.pl with MAA + MRA cutoff  -> _filter_<mra>.vcf
    //   - filter_vcfs_2vcf.pl with MAA + 0           -> _filter_none.vcf
    //   - inline D03_filter_tags.sh logic (awk)      -> _filter_<mra>tags.vcf

    input:
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${vcf_file.baseName}_filter_${params.varcap.mra}.vcf"), emit: vcf_filtered
        tuple val(sample_id), path("${vcf_file.baseName}_filter_none.vcf"), emit: vcf_filter_none
        tuple val(sample_id), path("${vcf_file.baseName}_filter_${params.varcap.mra}tags.vcf"), emit: vcf_tags
    script:
        def tagFilter     = "REP|HOP|CSV1|CV1|CNSV1"   // hardcoded as in D02_filter_vcf.sh
        def exceptFilter  = "BP|LI|COMPLEX"            // hardcoded as in D03_filter_tags.sh
        """
        echo "MAA:${params.varcap.maa} MRA:${params.varcap.mra}"

        perl /app_home/VarCap/scripts/vcffilter/filter_vcfs_2vcf.pl \\
            ${vcf_file} ${params.varcap.maa} ${params.varcap.mra} \\
            >${vcf_file.baseName}_filter_${params.varcap.mra}.vcf

        perl /app_home/VarCap/scripts/vcffilter/filter_vcfs_2vcf.pl \\
            ${vcf_file} ${params.varcap.maa} 0 \\
            >${vcf_file.baseName}_filter_none.vcf

        # filter according to tags — inline logic from D03_filter_tags.sh:
        #   keep lines where FILTER col (\$7) does NOT match tag_filter,
        #   or INFO col (\$8) matches exceptions (BP|LI|COMPLEX)
        awk -v regex="${tagFilter}" -v except="${exceptFilter}" \\
            '{ if ( \$7 !~ regex || \$8 ~ except ) {print} }' \\
            ${vcf_file.baseName}_filter_${params.varcap.mra}.vcf \\
            >${vcf_file.baseName}_filter_${params.varcap.mra}tags.vcf
        """
}
