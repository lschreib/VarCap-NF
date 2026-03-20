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
    container = "file:///$INSTALL_HOME/software/imagefiles/nrc_tools/NRC_Tools_1.4.1.sif"
    //
    //Now follow singularity containers for pipeline steps that require specific containers
    
    /*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONTAINER: Read QC and trimming
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    */
    withName:FASTQC_RAW {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }
    
    withName:FASTQC_TRIM {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:FASTQC_TRIM_PAIRED {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:FASTQC_TRIM_SINGLES {
        container = "file:///$INSTALL_HOME/software/imagefiles/fastqc/FastQC_0.11.9.sif"
    }

    withName:MULTIQC_TRIM_PAIRED {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:MULTIQC_TRIM_SINGLES {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:MULTIQC_TRIM {
        container = "file:///$INSTALL_HOME/software/imagefiles/multiqc/MultiQC_v1.30.sif"
    }

    withName:TRIMMOMATIC {
        container = "file:///$INSTALL_HOME/software/imagefiles/trimmomatic/Trimmomatic_0.39.sif"
    }

    withName:BBDUK_PAIRED {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
    }
    
    withName:BBDUK_SINGLES {
        container = "file:///$INSTALL_HOME/software/imagefiles/bbmap/BBMap_39.01.sif"
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
        reference_genome = "$projectDir/reference_genome/ref_genome.fasta"
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
        cluster_time = 1.h
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

