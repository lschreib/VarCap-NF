process SNPEFF_TABULATE {
    publishDir "$params.DEFAULT.outdir/annotation/tabulated", mode: 'copy'
    errorStrategy 'finish'
    cpus params.DEFAULT.cluster_cpus
    memory params.DEFAULT.cluster_memory
    time params.DEFAULT.cluster_time

    input:
        tuple val(sample_id), path(annotated_vcf)

    output:
        tuple val(sample_id), path("${sample_id}.snpeff.tsv"), emit: annotation_table

    script:
        """
        awk -v sample_id='${sample_id}' 'BEGIN {
                FS = OFS = "\t"
                print "sample_id","chrom","pos","ref","alt","qual","filter","type","dp","af","taa","raa","vaa","vra","effect","impact","gene","gene_id","feature_type","feature_id","hgvs_c","hgvs_p","cdna_pos","cds_pos","aa_pos","distance","warnings","all_ann"
            }
            /^#/ { next }
            {
                chrom  = \$1
                pos    = \$2
                ref    = \$4
                alt    = \$5
                qual   = \$6
                filt   = \$7
                info   = \$8
                fmt    = \$9
                samp   = \$10

                type = ""
                dp   = ""
                af   = ""
                ann  = ""

                n = split(info, tags, ";")
                for (i = 1; i <= n; i++) {
                    split(tags[i], kv, "=")
                    key = kv[1]
                    val = ""
                    if (length(tags[i]) > length(key)) {
                        val = substr(tags[i], length(key) + 2)
                    }
                    if (key == "TYPE") {
                        type = val
                    } else if (key == "DP") {
                        dp = val
                    } else if (key == "AF") {
                        af = val
                    } else if (key == "ANN") {
                        ann = val
                    }
                }

                # Parse FORMAT/SAMPLE for TAA:RAA:VAA:VRA
                taa = ""; raa = ""; vaa = ""; vra = ""
                nfmt = split(fmt, fkeys, ":")
                nsamp = split(samp, svals, ":")
                for (i = 1; i <= nfmt; i++) {
                    if (fkeys[i] == "TAA") taa = (i <= nsamp) ? svals[i] : ""
                    if (fkeys[i] == "RAA") raa = (i <= nsamp) ? svals[i] : ""
                    if (fkeys[i] == "VAA") vaa = (i <= nsamp) ? svals[i] : ""
                    if (fkeys[i] == "VRA") vra = (i <= nsamp) ? svals[i] : ""
                }

                # Use first ANN record per variant (comma-separated transcripts/effects).
                ann_first = ann
                sub(/,.*/, "", ann_first)

                effect = impact = gene = gene_id = ""
                feature_type = feature_id = ""
                hgvs_c = hgvs_p = ""
                cdna_pos = cds_pos = aa_pos = ""
                distance = warnings = ""

                if (ann_first != "") {
                    m = split(ann_first, a, "\\|")
                    if (m >= 2)  effect       = a[2]
                    if (m >= 3)  impact       = a[3]
                    if (m >= 4)  gene         = a[4]
                    if (m >= 5)  gene_id      = a[5]
                    if (m >= 6)  feature_type = a[6]
                    if (m >= 7)  feature_id   = a[7]
                    if (m >= 10) hgvs_c       = a[10]
                    if (m >= 11) hgvs_p       = a[11]
                    if (m >= 12) cdna_pos     = a[12]
                    if (m >= 13) cds_pos      = a[13]
                    if (m >= 14) aa_pos       = a[14]
                    if (m >= 15) distance     = a[15]
                    if (m >= 16) warnings     = a[16]
                }

                print sample_id,chrom,pos,ref,alt,qual,filt,type,dp,af,taa,raa,vaa,vra,effect,impact,gene,gene_id,feature_type,feature_id,hgvs_c,hgvs_p,cdna_pos,cds_pos,aa_pos,distance,warnings,ann
            }
        ' ${annotated_vcf} > ${sample_id}.snpeff.tsv
        """
}
