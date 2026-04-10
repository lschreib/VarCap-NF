process VARCAP_UNIFY_CHROM_NAMES {
    publishDir "$params.DEFAULT.outdir/varcap/unify", mode: 'copy'
    debug true
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(vcf_file)

    output:
        tuple val(sample_id), path("${sample_id}_1.vcf"), emit: vcf_unified

    script:
        """
        BAM_NAME_BASE="${sample_id}"
        INFILE="${vcf_file}"
        OUTFILE="\${BAM_NAME_BASE}_1.vcf"

        >"\${OUTFILE}.mod"

        CHROMS=\$( cat "\$INFILE" | grep -Ev '^#|cortex' | cut -f1 | sort -u )
        cat "\$INFILE" | while read -r line; do
            if [[ \$line == *cortex* ]]; then
              CCHR=\$( echo -e "\$line" | cut -f1 )
              CREST=\$( echo -e "\$line" | cut -f2- )
              NCHR=\$( echo -e "\$CHROMS" | grep -e "\$CCHR" )
              echo -e "\$NCHR\\t\$CREST" >>"\${OUTFILE}.mod"
            else
              echo -e "\$line" >>"\${OUTFILE}.mod"
            fi
          done

          # sort according to chrom and pos
          >HEAD.txt
          >BODY.txt
          cat "\${OUTFILE}.mod" | while read -r line; do
            if [[ \$line ==  \\#* ]]; then
              echo -e "\$line" >>HEAD.txt
            else
              echo -e "\$line" >>BODY.txt
            fi
          done
          cat BODY.txt | sort -k1,1 -k2,2n >BODY.sort.txt
          cat HEAD.txt BODY.sort.txt > "\${OUTFILE}.mod"
          mv "\${OUTFILE}.mod" "\${OUTFILE}"
          rm HEAD.txt BODY.sort.txt BODY.txt
        """
}
