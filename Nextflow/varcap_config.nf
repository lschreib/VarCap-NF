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
    clusterOptions = "--account=xxx --export=ALL"

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: DEFAULT
    (This is the standard singularity container to be used unless 
    the process requires a specific one)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    //
    //Now follow singularity containers for pipeline steps that require specific containers

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Prepare project
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:PREPARE_REFERENCE {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
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

    withName:PICARD_BAM_TO_FASTQ {
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
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif" 
    }

    // Cortex_var
    withName:BBTOOLS_REPAIR_READS {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
    }

    withName:CORTEX_K31 {
        container = "file:///$INSTALL_HOME/software/imagefiles/cortex/cortex_v1.0.5.sif"
    }

    withName:CORTEX_K61 {
        container = "file:///$INSTALL_HOME/software/imagefiles/cortex/cortex_v1.0.5.sif"
    }

    withName:CORTEX_CALL {
        container = "file:///$INSTALL_HOME/software/imagefiles/cortex/cortex_v1.0.5.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Varcap - variant filtering and integration
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */

    withName:VARCAP_STAGE_AND_COLLECT {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_UNIFY_CHROM_NAMES {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_CALCULATE_COVERAGE {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_BUILD_REPEAT_VCF {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_TAG_REPEATS {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_TAG_HOMOPOLYMERS {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_TAG_SAR {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_TAG_CALLER_POS {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_APPLY_MRA_FILTER {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_UNIFY_GI_CHROM_NAMES {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_STATS_COVERAGE {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    withName:VARCAP_STATS_VARIANT_FREQUENCY {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Annotation
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:SNPEFF_BUILD_DB {
        container = "file:///$INSTALL_HOME/software/imagefiles/snpeff/snpeff_v4.3.sif"
    }

    withName:SNPEFF_ANNOTATE {
        container = "file:///$INSTALL_HOME/software/imagefiles/snpeff/snpeff_v4.3.sif"
    }

    // Doesn't really need a special container since it's just an awk script
    withName:SNPEFF_TABULATE {
        container = "file:///$INSTALL_HOME/software/imagefiles/varcap/varcap_v3.0.sif"
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

    clusterOptions = "--account=xxx --export=ALL"

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
    CONFIG: Picard and Samtools
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    //
    // Picard
    picard_add {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }

    picard_bam_to_fastq {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }

    picard_dup {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }

    picard_ins {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }
    //
    // Samtools
    samtools_bam {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_cov {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_index {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_merge {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_mpileup {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        adjust_mq = 50
        max_depth = 1000
    }

    samtools_sam {
        cluster_time = 4.h
        cluster_cpus = 6
        cluster_memory = 32.GB
    }

    samtools_sort {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
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
    bbtools_repair {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
    }

    cortex_binary {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        mem_height = 21
        mem_width = 100
        first_kmer = 31
        last_kmer = 61
    }

    cortex_call {
        cluster_time = 12.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        auto_cleaning = "yes"
        make_buble_calls = "yes"
        make_pd_calls = "no"
        ploidy = 1
        qthresh = 5
        mem_height = 21
        mem_width = 100
        do_union = "yes"
        ref = "CoordinatesAndInCalling"
        workflow = "independent"
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: VarCap variant filtering
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    // VarCap parameters shared by multiple processes
    varcap {
        min_cpv = 2  // minimum callers per variant; default is 2; setable from 1 (=single caller is enough) to 6 (=has to be detected by all callers).
        cpv = 2  // caller per variant
        insert_size = 250
        snpcountmax = 4
        maa=8  // MAA minimum absolute abundance (in number of reads)
        mra=2  // MRA minimum relative abundance (in percent)
    }


    varcap_stage {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB

    }

    varcap_unify_chrom_names {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

    varcap_calculate_coverage {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    varcap_build_repeat_vcf {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    varcap_apply_mra_filter {
        cluster_time = 4.h
        cluster_cpus = 8
        cluster_memory = 32.GB
    }

    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG: Annotation
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    snpeff_prepare_db {
        cluster_time = 12.h
        cluster_cpus = 8
        cluster_memory = 32.GB
        java_xmx = "16g"
        genome_name = "Reference"
        codon_table = "Bacterial_and_Plant_Plastid"
    }

    snpeff_annotate {
        cluster_time = 4.h
        cluster_cpus = 4
        cluster_memory = 16.GB
        java_xmx = "12g"
        // Upstream/downstream window in bp for effect reporting.
        // 0 = strict: only report variants inside annotated features.
        // Increase (e.g. 300, regulatory regions of genes; 1000, whole promoter regions) to also capture proximal regulatory effects.
        // NOTE: values greater than 0 could causse errors during the annotation,
        // due to then overlapping features and the resulting ambiguity in effect assignment.
        // The original VarCap pipeline used a value of 0.
        upstream_downstream = 0
    }

    snpeff_tabulate {
        cluster_time = 1.h
        cluster_cpus = 1
        cluster_memory = 4000.MB
    }

}

manifest {
    name            = "VarCap-NF"
    author          = """Lars Schreiber"""
    homePage        = "https://github.com/lschreib/VarCap-NF"
    description     = """Nextflow reimplementation of the VarCap pipeline for variant profiling of evolving microbial populations."""
    mainScript      = "varcap_workflow.nf"
    nextflowVersion = "!>=23.04.3"
    version         = "1.0.0"
    doi             = "https://doi.org/10.7717/peerj.2997"
}

