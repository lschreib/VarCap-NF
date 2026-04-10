process CORTEX_CALL {
    publishDir "$params.DEFAULT.outdir/variant_calling/cortex", mode: 'copy'
    debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.cortex_call.cluster_cpus
    memory params.cortex_call.cluster_memory
    time params.cortex_call.cluster_time

    input:
        path(reference_fna)
        path(reference_index)
        tuple val(sample_id), path(reads1), path(reads2)
        path(ref_k31_ctx)
        path(ref_k61_ctx)


    output:
        tuple val(sample_id), path("${sample_id}_wk_flow_I_RefCC_FINALcombined_BC_calls_at_all_k.raw.vcf"), emit: cortex_raw_out
        tuple val(sample_id), path("${sample_id}_wk_flow_I_RefCC_FINALcombined_BC_calls_at_all_k.decomp.vcf"), emit: cortex_decomp_out

    script:
        """
        export PERL5LIB=/cortex//scripts/analyse_variants/bioinf-perl/lib:/cortex/scripts/calling
        export PATH=/cortex/scripts/analyse_variants/needleman_wunsch:$PATH

        GENOME_SIZE=\$(awk '{sum += \$2} END {print sum}' ${reference_index})
        echo "Genome size: \$GENOME_SIZE"

        echo "${reads1}" > "${sample_id}.pe1.list"
        echo "${reads2}" > "${sample_id}.pe2.list"
        printf "%s\t.\t%s\t%s\n" "${sample_id}" "${sample_id}.pe1.list" "${sample_id}.pe2.list" > INDEX

        echo ${reference_fna} > file_listing_fasta

        mkdir -p ref
        mv ref.k31.ctx ref/ref.k31.ctx
        mv ref.k61.ctx ref/ref.k61.ctx

        perl  /cortex/scripts/calling/run_calls.pl \\
            --first_kmer 31 \\
            --last_kmer 61 \\
            --kmer_step 30 \\
            --fastaq_index INDEX \\
            --minimap2_bin /app_home/minimap2/minimap2 \\
            --auto_cleaning ${params.cortex_call.auto_cleaning} \\
            --bc ${params.cortex_call.make_buble_calls} \\
            --pd ${params.cortex_call.make_pd_calls} \\
            --outdir ${sample_id} \\
            --outvcf ${sample_id} \\
            --ploidy ${params.cortex_call.ploidy} \\
            --list_ref_fasta file_listing_fasta \\
            --refbindir ref/ \\
            --genome_size \$GENOME_SIZE \\
            --qthresh ${params.cortex_call.qthresh} \\
            --mem_height ${params.cortex_call.mem_height} \\
            --mem_width ${params.cortex_call.mem_width} \\
            --vcftools_dir /vcftools/src \\
            --do_union ${params.cortex_call.do_union} \\
            --ref ${params.cortex_call.ref} \\
            --workflow ${params.cortex_call.workflow} \\
            --logfile ${sample_id}.log.txt

        src="${sample_id}/vcfs/${sample_id}_wk_flow_I_RefCC_FINALcombined_BC_calls_at_all_k.raw.vcf"
        cp "\$src" . 2>/dev/null || : > "\$(basename "\$src")"

        src="${sample_id}/vcfs/${sample_id}_wk_flow_I_RefCC_FINALcombined_BC_calls_at_all_k.decomp.vcf"
        cp "\$src" . 2>/dev/null || : > "\$(basename "\$src")"
        """
}
