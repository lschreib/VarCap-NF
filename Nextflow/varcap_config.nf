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

    withName:INDEX_REFERENCE {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
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

    withName:BBDUK {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
    }

    withName:BBDUK_COMBINED {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Samtools and Picard
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    // Picard
    // Picard AddReadGroup
    withName:PICARD_ADD_READ_GROUP {
        container = "file:///$INSTALL_HOME/software/imagefiles/picard/picard_v3.4.0.sif"
    }

    withName:PICARD_INSERT_SIZE {
        container = "file:///$INSTALL_HOME/software/imagefiles/picard/picard_v3.4.0.sif"
    }

    withName:PICARD_MARK_DUP {
        container = "file:///$INSTALL_HOME/software/imagefiles/picard/picard_v3.4.0.sif"
    }

    // Samtools
    withName:SAMTOOLS_COVERAGE {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_INDEX {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_MERGE {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_MPILEUP {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_SORT {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_TO_BAM_PE {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_TO_BAM_SE {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    withName:SAMTOOLS_TO_SAM {
        container = "file:///$INSTALL_HOME/software/imagefiles/samtools/Samtools_1.23.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Read mapping
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    //withName:COMBINE_READS {
    //    container = "file:///$INSTALL_HOME/software/imagefiles/seqtk/seqtk_v1.5.sif"
    //}

    withName:BWA_BUILD_INDEX {
        container = "file:///$INSTALL_HOME/software/imagefiles/bwa/bwamem2_v2.3.sif"
    }

    withName:BWA_MAPPING_PE {
        container = "file:///$INSTALL_HOME/software/imagefiles/bwa/bwamem2_v2.3.sif"
    }

    withName:BWA_MAPPING_SE {
        container = "file:///$INSTALL_HOME/software/imagefiles/bwa/bwamem2_v2.3.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Variant calling
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    //
    // LoFreq
    withName:LOFREQ_QUALITY {
        container = "file:///$INSTALL_HOME/software/imagefiles/lofreq/lofreq_v2.1.5.sif"
    }

    withName:LOFREQ_CALL {
        container = "file:///$INSTALL_HOME/software/imagefiles/lofreq/lofreq_v2.1.5.sif"
    }

    // VarScan2
    withName:VARSCAN_PILEUP2SNP {
        container = "file:///$INSTALL_HOME/software/imagefiles/varscan/varscan_v2.3.9.sif"
    }

    withName:VARSCAN_FILTER_SNP {
        container = "file:///$INSTALL_HOME/software/imagefiles/varscan/varscan_v2.3.9.sif"
    }

    withName:VARSCAN_PILEUP2INDEL {
        container = "file:///$INSTALL_HOME/software/imagefiles/varscan/varscan_v2.3.9.sif"
    }

    withName:VARSCAN_FILTER_INDEL {
        container = "file:///$INSTALL_HOME/software/imagefiles/varscan/varscan_v2.3.9.sif"
    }

    // Pindel
    withName:SAM2PINDEL {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    withName:PINDEL_CALL {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    withName:PINDEL2VCF_D {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    withName:PINDEL2VCF_INV {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    withName:PINDEL2VCF_SI {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    withName:PINDEL2VCF_TD {
        container = "file:///$INSTALL_HOME/software/imagefiles/pindel/pindel_v0.2.5.sif"
    }

    // BCF to VCF conversion
    withName:BCF_TO_VCF {
        container = "file:///$INSTALL_HOME/software/imagefiles/bcftools/bcftools_v1.23.1.sif"
    }

    // Delly
    withName:DELLY_DEL {
        container = "file:///$INSTALL_HOME/software/imagefiles/delly/delly_v1.7.3.sif"
    }

    withName:DELLY_INS {
        container = "file:///$INSTALL_HOME/software/imagefiles/delly/delly_v1.7.3.sif"
    }

    withName:DELLY_DUP {
        container = "file:///$INSTALL_HOME/software/imagefiles/delly/delly_v1.7.3.sif"
    }

    withName:DELLY_INV {
        container = "file:///$INSTALL_HOME/software/imagefiles/delly/delly_v1.7.3.sif"
    }

    withName:DELLY_BND {
        container = "file:///$INSTALL_HOME/software/imagefiles/delly/delly_v1.7.3.sif"
    }

    // Breakdancer
    withName:BREAKDANCER_MAKE_CONFIG {
        container = "file:///$INSTALL_HOME/software/imagefiles/breakdancer/breakdancer_v1.4.5.sif" 
    }

    withName:BREAKDANCER_MAX {
        container = "file:///$INSTALL_HOME/software/imagefiles/breakdancer/breakdancer_v1.4.5.sif" 
    }

    withName:BREAKDANCER_FILTER {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v0.1.sif" 
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

        // Also use orphaned reads for variant calling
        // (useful for low quality data sets that features a lot of orphaned single
        // end reads after qc filtering and trimming)
        recycle_single = true

        // will be used for variant calling with Breakdancer
        read_length = 150
        insert_size = 250
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
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "28g"
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
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    samtools_bam {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_sam {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_cov {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_merge {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_index {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    picard_ins {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: Variant calling
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    //
    // LoFreq*
    lofreq_quality {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    lofreq_call {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        min_coverage = 6
    }
    //
    // VarScan2
    samtools_sort {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    samtools_mpileup {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        adjust_mq = 50
        max_depth = 1000
    }

    varscan_pileup2snp {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
        min_var_freq = 0.001
    }

    varscan_filter_snp {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
        min_avg_qual = 25
        min_var_freq = 0.001
        min_strands2 = 2
    }

    varscan_pileup2indel {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
        min_var_freq = 0.001
    }

    varscan_filter_indel {
       cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
        min_avg_qual = 25
        min_var_freq = 0.001
    }
    //
    // Pindel
    sam2pindel {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    pindel_call {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    pindel2vcf {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }
    //
    // Picard AddReadGroup
    picard_add {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }
    //
    // Breakdancer
    breakdancer_config {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        fraction_trim = 0.05
    }

    breakdancer_max {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        // Default parameters for breakdancer-max copied from original VarCap pipeline
        min_length_region = 15
        min_alternative_mapping_quality = 35
        min_supporting_pairs = 8
    }

    breakdancer_filter {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4.GB
        cutoff_score = 1
    }

    //
    // Delly
    picard_dup {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }

    delly {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        // the following parameters represent Delly's default values
        mapping_quality = 1
        translocation_quality = 20
        insert_size_cutoff = 9
        min_clip_length = 25
        min_clique_size = 2
        min_ref_separation = 25
        max_read_separation = 40
        max_reads_for_consensus = 20
    }

    bcf_to_vcf {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
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
    version         = "0.2.0"
    doi             = "https://doi.org/10.7717/peerj.2997"
}

