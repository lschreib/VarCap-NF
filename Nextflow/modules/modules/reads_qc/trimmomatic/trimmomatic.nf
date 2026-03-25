process TRIMMOMATIC {
    publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_log.txt"
    publishDir "$params.DEFAULT.outdir/qced_reads/logs", mode: 'copy', pattern: "*_trimmomatic_stats.tsv"
    debug true
    //All Java-based steps have problems with parallelization because they will all use the same temporary directory
    //which fills up quickly when many processes are run at the same time, we therefore set these steps to "sequential"
    //mode by using the maxForks command
    //maxForks 1
    scratch false
    errorStrategy 'finish'
    cpus params.trimmomatic.cluster_cpus
    memory params.trimmomatic.cluster_memory
    time params.trimmomatic.cluster_time

    input:
        tuple val(sample_id), path(reads)

    output:
        //This line makes sure that only the paired reads are emitted to the next process, really clever!
        //Also the resulting tupel will have [0] sample_id [1] R1_reads.fastq [2] R2_reads.fastq
        tuple val(sample_id), path("${sample_id}_paired_R1.fastq.gz"), path("${sample_id}_paired_R2.fastq.gz"), emit: paired_reads
        tuple val(sample_id), path("${sample_id}_single_R1.fastq.gz"), path("${sample_id}_single_R2.fastq.gz"), emit: single_reads
        path("${sample_id}_trimmomatic_log.txt"), emit: log
        path("${sample_id}_trimmomatic_stats.tsv"), emit: stats

    script:
        command = """
        java -Djava.io.tmpdir=$TMPDIR -XX:ParallelGCThreads=$params.trimmomatic.threads -XX:-UsePerfData -Xmx2G -jar /trimmomatic/trimmomatic-0.39.jar PE \\
            -threads ${params.trimmomatic.threads} \\
           -phred${params.trimmomatic.quality_offset} \\
            ${reads[0]} ${reads[1]} \\
            ${sample_id}_paired_R1.fastq.gz ${sample_id}_single_R1.fastq.gz ${sample_id}_paired_R2.fastq.gz ${sample_id}_single_R2.fastq.gz \\
            ILLUMINACLIP:${params.trimmomatic.adapter_fasta}${params.trimmomatic.illumina_clip_settings} \\
            TRAILING:${params.trimmomatic.trailing_min_quality} \\
            SLIDINGWINDOW:${params.trimmomatic.sliding_window1}:${params.trimmomatic.sliding_window2} \\
            MINLEN:${params.trimmomatic.min_length} \\
            HEADCROP:${params.trimmomatic.headcrop}"""
        if(params.trimmomatic.crop){
            command += """ CROP:${params.trimmomatic.crop}"""
        }
        command += """ 2> ${sample_id}_trimmomatic_log.txt && \\
        grep ^Input ${sample_id}_trimmomatic_log.txt | \\
        perl -pe 's/^Input Read Pairs: (\\d+).*Both Surviving: (\\d+).*Forward Only Surviving: (\\d+).*\$/Raw Fragments,\\1\\nFragment Surviving,\\2\\nSingle Surviving,\\3/' >  ${sample_id}_trimmomatic_stats.tsv
        """
        return command

}
