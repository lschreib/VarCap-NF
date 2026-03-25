/*
These following sections (env & executor) are so that the nextflow master
process itself does not run out of memory
*/

executor {
   name = 'slurm'
   cpus = 2
   memory = '8 GB'
   //salloc --time=72:00:00 --account=nrc_eme --mem=8GB --cpus-per-task=1 --ntasks=2
}

process {
    // executor can be either 'local' or 'slurm' 
    executor = "slurm"
    clusterOptions = "--account=nrc_eme --export=ALL"

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: DEFAULT
    (This is the standard singularity container to be used unless 
    the process requires a specific one)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v0.1.sif"
    //
    //Now follow singularity containers for pipeline steps that require specific containers

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Prepare project
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:PREPARE_REFERENCE {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v0.1.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Read QC and trimming
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:FASTQC_RAW {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:FASTQC_TRIM_PAIRED {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:FASTQC_TRIM_SINGLES {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:MULTIQC_RAW {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:MULTIQC_TRIM_PAIRED {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:MULTIQC_TRIM_SINGLES {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:TRIMMOMATIC {
        container = "file:///$INSTALL_HOME/software/imagefiles/trimmomatic/Trimmomatic_0.39.sif"
    }

    withName:BBDUK_COMBINED {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Read mapping
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:COMBINE_READS {
        container = "file:///$INSTALL_HOME/software/imagefiles/seqtk/seqtk_v1.5.sif"
    }

    withName:BWA_BUILD_INDEX {
        container = "file:///$INSTALL_HOME/software/imagefiles/bwa/bwamem2_v2.3.sif"
    }

    withName:BWA_MAPPING {
        container = "file:///$INSTALL_HOME/software/imagefiles/bwa/bwamem2_v2.3.sif"
    }

}

singularity {
    enabled = true
    autoMounts = true
    runOptions = '-B $TMPDIR -B $SINGULARITY_TMPDIR:/tmp -B $SINGULARITY_TMPDIR:/scratch -B $DATABASES --cleanenv'
    //Used to allow Singularity to access bashrc variables
    envWhitelist = ['TMPDIR','SINGULARITY_TMPDIR','DATABASES']
}


params {

    clusterOptions = "--account=nrc_eme --export=ALL"

    DEFAULT {
        /* 
            IMPORTANT PARAMETERS - will determine the workflow configuration.
        */
        cluster_time = 6.h
        cluster_cpus = 1
        cluster_memory = 12.GB

        raw_reads = "$projectDir/reads_workdir/*_R{1,2}.fastq.gz"
        reference_genome_gbk = "$projectDir/reference_genome/Pseud_AE27_CP146966.gbk"
        outdir = "$projectDir/output/"
    }


    /*
        Customized parameters for individual processes
    */

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: Read QC and trimming
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    fastqc {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    multiqc {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 8000.MB
    }

    trimmomatic {
        threads = 4
        trailing_min_quality = 20
        average_quality = 30
        quality_offset = 33
        min_length = 40
        sliding_window1 = 5
        sliding_window2 = 20
        // Have a look at the fastqc profiles to make sure you are cropping enough bases at the beginning of the reads.
        headcrop = 20
        // crop is optional. If for some reason you are still stuck with overrepresented kmers at the end, use crop=<int> to force them off.
        // just comment the parameter if no tail crop is needed.
        //crop = 235 //adjust spades_rrna kmer values if <134!
        adapter_fasta = "$INSTALL_HOME/databases/contaminants/bbduk/adapters.fa"
        illumina_clip_settings = ":2:10:10"
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    bbduk {
        k = 31  // kmer size for trimming; recommend values for contaminant removal range from 21 to 31
        c = 1
        min_len = 40
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        contaminants = "$INSTALL_HOME/databases/contaminants/bbduk/full_collection.fa"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: Read mapping
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */

    bwa_index {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    bwa_mapping {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    samtools_conversion {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    samtools_coverage {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    samtools_indexing {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    picard_stats {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: Variant calling
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    //
    // LoFreq*
    lofreq_quality {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    lofreq_call {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        min_coverage = 6

    }
    //
    // VarScan2
    samtools_sort {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    samtools_mpileup {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        adjust_mq = 50
        max_depth = 1000
    }

    pileup2snp {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
        min_var_freq = 0.001
    }

    filter_snp {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
        min_avg_qual = 25
        min_var_freq = 0.001
        min_strands2 = 2
    }

    pileup2indel {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
        min_var_freq = 0.001
    }

    filter_indel {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
        min_avg_qual = 25
        min_var_freq = 0.001
    }
    //
    // Pindel
    sam2pindel {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        //insert_size = 300         // Better to determine this from the data, e.g. by looking at the insert size distribution in the picard stats output and adjusting accordingly.
    }

    pindel {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    pindel2vcf {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    //
    // Breakdancer
    picard_header {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
    }

    breakdancer_config {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    breakdancer {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        min_length_region = 15
        min_alternative_mapping_quality = 35
        min_supporting_pairs = 8
    }
    //
    // Delly
    delly {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        max_indel_size = 2000
    }
    //
    // Cortex_var
    cortex_var {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    //picard_header -> breakdancer_config -> picard_header

    picard_bam2fastq {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        java_xmx = "8g"
    }

    cortex_build_ref {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        mem_height = 21
        mem_width = 100
        max_read_length = 10000
        first_kmer = 31
        last_kmer = 61
    }

    cortex_stampy {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    cortex_var_call {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        first_kmer = 31
        last_kmer = 61
        kmer_step = 30
        auto_cleaning = "yes"
        make_buble_calls = "yes"
        make_pd_calls = "no"
        ploidy = 1
        //genome_size -> get from data
        max_read_length = 10000
        qthresh = 5
        mem_height = 21
        mem_width = 100
        do_union = "yes"
        workflow = "independent"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: VarCap variant filtering
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    mra_filter {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
        minimum_absolute_abundance_maa = 8
        minimum_relative_abundance_mra = 2
    }

}

manifest {
    name            = "VarCap-NF"
    author          = """Lars Schreiber"""
    homePage        = "https://github.com/lschreib/VarCap-NF"
    description     = """Nextflow reimplementation of the VarCap pipeline for variant profiling of evolving microbial populations."""
    mainScript      = "varcap_workflow.nf"
    nextflowVersion = "!>=23.04.3"
    version         = "0.1.0"
    doi             = "https://doi.org/10.7717/peerj.2997"
}

