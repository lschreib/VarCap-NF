process VARCAP_UNIFY_GI_CHROM_NAMES {
    publishDir "$params.DEFAULT.outdir/varcap/unify2", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    // Section 5.1: Unify gi| chrom names
    // Mirrors D02_filter_vcf.sh lines 249-262
    // Converts "gi|xxx|xxx|CHROM|xxx" chromosome names to bare "CHROM"
    // Operates on the _filter_<mra>.vcf output from VARCAP_APPLY_MRA_FILTER

    input:
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${sample_id}.gi_unified.vcf"), emit: vcf_gi_unified

    script:
        """
        while IFS= read -r line; do
            if [[ \$line == \\#* ]]; then
                echo -e "\$line"
            else
                CHROM1=\$( echo -e "\$line" | cut -f1 )
                REST1=\$( echo -e "\$line" | cut -f2- )
                if [[ \$CHROM1 == gi\\|* ]]; then
                    CHROM2=\$( echo -e "\$CHROM1" | cut -d '|' -f 4 )
                    echo -e "\$CHROM2\\t\$REST1"
                else
                    echo -e "\$CHROM1\\t\$REST1"
                fi
            fi
        done < ${vcf_file} > ${sample_id}.gi_unified.vcf
        """
}
