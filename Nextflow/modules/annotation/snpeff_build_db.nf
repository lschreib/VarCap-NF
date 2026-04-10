process SNPEFF_BUILD_DB {
    // Publish the built snpEff DB so it can be reused without rebuilding.
    publishDir "$params.DEFAULT.outdir/annotation", mode: 'copy'
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        path(reference_genbank)

    output:
        // Complete snpEff workspace including compiled DB; passed to SNPEFF_ANNOTATE.
        path("snpeff_db"), emit: db_dir
        // Config file needed by snpEff eff -c <config>.
        path("snpeff_db/snpEff.config"), emit: snpeff_config
        // Genome ID string used as the snpEff genome argument in annotation.
        path("snpeff_db/genome_id.txt"), emit: genome_id

    script:
        """
        set -euo pipefail
        echo "SNPEFF_BUILD_DB_SCRIPT_VERSION=2026-04-10b" >&2

        gbk_name=\$( basename "${reference_genbank}" )
        genome_id=\${gbk_name%.*}
        genome_id=\$( echo "\${genome_id}" | tr -cs '[:alnum:]' '_' | sed -E 's/^_+//' | rev | sed -E 's/^_+//' | rev )

        if [ -z "\${genome_id}" ]; then
            echo "ERROR: Could not derive genome_id from ${reference_genbank}" >&2
            exit 1
        fi

        awk '/^LOCUS[[:space:]]+/ { print \$2 }' "${reference_genbank}" \
            | awk '!seen[\$0]++' > snpeff_chrom_ids.txt

        if [ ! -s snpeff_chrom_ids.txt ]; then
            printf "%s\n" "\${genome_id}" > snpeff_chrom_ids.txt
        fi

        chrom_list=\$(paste -sd ',' snpeff_chrom_ids.txt | sed 's/,/, /g')

        mkdir -p snpeff_db/data/\${genome_id}
        cp "${reference_genbank}" snpeff_db/data/\${genome_id}/genes.gbk

        template_config="/app_home/templates/snpeff.config"
        if [ -n "\$template_config" ] && [ -f "\$template_config" ]; then
            cp "\$template_config" snpeff_db/snpEff.config
        else
            printf "data.dir = snpeff_db/data\n" > snpeff_db/snpEff.config
        fi

        if ! grep -q "data.dir" snpeff_db/snpEff.config; then
            printf "\ndata.dir = data\n" >> snpeff_db/snpEff.config
        fi

        printf "\n%s.genome : %s\n" "\${genome_id}" "${params.snpeff_prepare_db.genome_name}" >> snpeff_db/snpEff.config
        printf "\t%s.chromosome : %s\n" "\${genome_id}" "\${chrom_list}" >> snpeff_db/snpEff.config

        while read -r chrom_id; do
            printf "\t%s.%s.codonTable : %s\n" \
                "\${genome_id}" "\${chrom_id}" "${params.snpeff_prepare_db.codon_table}" >> snpeff_db/snpEff.config
        done < snpeff_chrom_ids.txt

        printf "%s\n" "\${genome_id}" > snpeff_db/genome_id.txt

        java -Xmx${params.snpeff_prepare_db.java_xmx} \
            -jar /app_home/snpEff/snpEff.jar build \
            -genbank \
            -c snpeff_db/snpEff.config \
            -v \
            "\${genome_id}" \
            2>&1 | tee snpeff_db/snpEff_build.log
        """
}
