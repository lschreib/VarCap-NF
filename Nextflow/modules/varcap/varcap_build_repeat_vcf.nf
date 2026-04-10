process VARCAP_BUILD_REPEAT_VCF {
    publishDir "$params.DEFAULT.outdir/varcap/repeats", mode: 'copy'
    errorStrategy 'finish'
    cpus params.varcap_build_repeat_vcf.cluster_cpus
    memory params.varcap_build_repeat_vcf.cluster_memory
    time params.varcap_build_repeat_vcf.cluster_time


    input:
        path(reference_fa)

    output:
        path("*_vmatch.vcf"), emit: ref_repeat_vcf

    script:
        """
        mkdir -p mkvtree
        REF_IDX_NAME=\$( basename ${reference_fa} )
        OUT_NAME_BASE=\$( echo \$REF_IDX_NAME | sed 's/\\..*\$//' )

        mkvtree -db ${reference_fa} -v -pl -sti1 -bwt -dna -bck -suf -lcp -tis -ois -skp -indexname mkvtree/\$REF_IDX_NAME

        REP_LENGTH=\$(( ${params.varcap.insert_size} - (${params.varcap.insert_size} / 5) ))
        OUT_NAME_BASE_VCF=\${OUT_NAME_BASE}_LEN\${REP_LENGTH}_ED5_vmatch

        vmatch -d -p -l \$REP_LENGTH -e 1 -showdesc 30 mkvtree/\$REF_IDX_NAME > \${OUT_NAME_BASE_VCF}.ed1.txt
        mv \${OUT_NAME_BASE_VCF}.ed1.txt \${OUT_NAME_BASE_VCF}.txt

        grep -v '#' \${OUT_NAME_BASE_VCF}.txt | awk '{print \$2"\\t"\$3"\\t"\$1"\\t.\\t.\\t.\\t.\\tCHROM="\$6";LENGTH="\$1";SVPOS="\$7"\\t."}' > 200_1.txt
        grep -v '#' \${OUT_NAME_BASE_VCF}.txt | awk '{print \$6"\\t"\$7"\\t"\$5"\\t.\\t.\\t.\\t.\\tCHROM="\$2";LENGTH="\$5";SVPOS="\$3"\\t."}' > 200_2.txt
        cat 200_1.txt 200_2.txt | sort -nk 2 > \${OUT_NAME_BASE_VCF}.vcf
        rm 200_1.txt 200_2.txt
        """
}