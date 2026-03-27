process SAMTOOLS_COVERAGE {
    publishDir "$params.DEFAULT.outdir/read_mapping/coverage", mode: 'copy'
    //debug true
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.samtools_cov.cluster_cpus
    memory params.samtools_cov.cluster_memory
    time params.samtools_cov.cluster_time

    input:
        tuple val(sample_id), path(bam_file)

    output:
        tuple val(sample_id), path("${sample_id}.coverage.tsv"), emit: coverage

    script:
        """
        set -euo pipefail
        samtools depth ${bam_file} | awk -v sid="${sample_id}" -v bam="${bam_file}" '{
            sum+=\$3; sumsq+=\$3*\$3
        }
        END {
            if (NR==0) {
                printf "ERROR: No depth records for sample %s (bam: %s)\\n", sid, bam > "/dev/stderr"
                exit 1
            }
            avg = sum/NR
            sd  = sqrt(sumsq/NR - avg*avg)
            printf "map_average_cov\\t%.6f\\n", avg
            printf "map_stdev_cov\\t%.6f\\n", sd
        }' > ${sample_id}.coverage.tsv
        """
}
