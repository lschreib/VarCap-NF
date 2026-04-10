process VARCAP_STAGE_AND_COLLECT {
    publishDir "$params.DEFAULT.outdir/varcap/stage", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        path(reference_fna)
        tuple val(sample_id),
              path(breakd_ctx),
              path(cortex_raw_vcf),
              path(delly_del_vcf),
              path(delly_dup_vcf),
              path(delly_ins_vcf),
              path(delly_bnd_vcf),
              path(delly_inv_vcf),
              path(lofreq_vcf),
              path(pindel_d_vcf),
              path(pindel_si_vcf),
              path(pindel_inv_vcf),
              path(pindel_td_vcf),
              path(varscan_snp),
              path(varscan_indel)

    output:
        tuple val(sample_id), path("${sample_id}_*.vcf"), emit: varcap_vcf

    script:
        """
        mkdir -p caller_collect

        # ---- stage files to legacy names expected by collect_variants_varcap_2vcf_02.pl ----
        cp ${breakd_ctx}       caller_collect/breakd_v1.ctx

        cp ${cortex_raw_vcf}   caller_collect/cortex_v1_wk_flow_I_RefCC_FINALcombined_BC_calls_at_all_k.raw.vcf

        cp ${delly_del_vcf}    caller_collect/delly_072_v1.del.vcf
        cp ${delly_dup_vcf}    caller_collect/delly_072_v1.dup.vcf
        cp ${delly_ins_vcf}    caller_collect/delly_072_v1.ins.vcf
        cp ${delly_bnd_vcf}    caller_collect/delly_072_v1.tra.vcf
        cp ${delly_inv_vcf}    caller_collect/delly_072_v1.inv.vcf

        cp ${lofreq_vcf}      caller_collect/lofreq2_v1_lofreq2_filter.vcf

        cp ${pindel_d_vcf}     caller_collect/pindel_v1_D.vcf
        cp ${pindel_si_vcf}    caller_collect/pindel_v1_SI.vcf
        cp ${pindel_inv_vcf}   caller_collect/pindel_v1_INV.vcf
        cp ${pindel_td_vcf}    caller_collect/pindel_v1_TD.vcf

        cp ${varscan_snp}      caller_collect/varscan_v1.filter.snp
        cp ${varscan_indel}    caller_collect/varscan_v1.filter.indel

        # ---- env expected by legacy collector ----
        export PATH_CALLER_COLLECT="\$PWD/caller_collect"
        export REF_FA="${reference_fna}"
        export BAM_NAME_BASE="${sample_id}"
        export REPEATS="1"
        export MIN_CPC="1"
        export MIN_CPV="${params.varcap.min_cpv}"

        # ---- run collector (needs helper scripts in same folder / @INC) ----
        perl -I /app_home/VarCap/scripts/vcffilter \\
            /app_home/VarCap/scripts/vcffilter/collect_variants_varcap_2vcf_02.pl
        """
}
