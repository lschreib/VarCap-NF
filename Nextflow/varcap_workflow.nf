/*
    parameters are defined in the shotgunmg_config.nf file
*/
log.info """
#########################################################################################

  __     __          ____                  _   _ _____
 \\ \\   / /_ _ _ __ / ___|__ _ _ __       | \\ | |  ___|
  \\ \\ / / _` | '__| |   / _` | '_ \ _____|  \\| | |_
   \\ V / (_| | |  | |__| (_| | |_) |_____| |\\  |  _|
    \\_/ \\__,_|_|   \\____\\__,_| .__/      |_| \\_|_|
                             |_|

               Support: lars.schreiber@nrc-cnrc.gc.ca
             Home page: https://github.com/lschreib/VarCap-NF
               Version: 0.1.0
                  Note: Nextflow reimplementation of the VarCap pipeline for variant profiling
                        of evolving microbial populations.
#########################################################################################

 reads   : ${params.DEFAULT.reads_workdir}
 outdir  : ${params.DEFAULT.outdir}
    """.stripIndent()


/*
  Import processes from external files
  It is common to name processes with UPPERCASE strings, to make
  the program more readable
*/
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Import of modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Read QC and trimming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
//
//FastQC
include { FASTQC as FASTQC_RAW                  } from './modules/reads_qc/fastqc/fastqc.nf'
include { FASTQC as FASTQC_TRIM_PAIRED          } from './modules/reads_qc/fastqc/fastqc.nf'
include { FASTQC as FASTQC_TRIM_SINGLES         } from './modules/reads_qc/fastqc/fastqc.nf'
//
//MultiQC
include { MULTIQC as MULTIQC_RAW                } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM               } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM_PAIRED        } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM_SINGLES       } from './modules/reads_qc/multiqc/multiqc.nf'
//
//Trimmomatic
include { TRIMMOMATIC                           } from './modules/reads_qc/trimmomatic/trimmomatic.nf'
//
//BBDUK
include { BBDUK_PAIRED                          } from './modules/bbtools/bbduk/bbduk_paired.nf'
include { BBDUK_SINGLES                         } from './modules/bbtools/bbduk/bbduk_singles.nf'

//
// BBMap
//
// Breakdancer
//
// BWA
//
// Cortex
//
// Delly
//
// Lofreq
//
// Pindel
//
// Samtools
//
// SnpEff
//
// Trimmomatic
//
// VarCap
//
// Varscan2
//
workflow {
    //Populate input channels
    if (!params.DEFAULT?.raw_reads) {
        error "Parameter 'params.DEFAULT.reads_workdir' is not defined. Please check your configuration."
    }
    raw_reads_channel = Channel.fromFilePairs(params.DEFAULT.raw_reads, checkIfExists:true)

    main:
        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Read QC and trimming
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // Initial QC of reads with FASTQC
        FASTQC_RAW(raw_reads_channel, 'raw')
        // Summarize FastQc results of raw reads
        MULTIQC_RAW(FASTQC_RAW.out.fastqc_out_zip.collect(), 'raw')

        // Initial quality trimming and adapter removal
        TRIMMOMATIC(raw_reads_channel)

        BBDUK_COMBINED(TRIMMOMATIC.out.paired_reads, TRIMMOMATIC.out.single_reads)


        // Processing of paired reads:
            // A final QC with FASTQC
            FASTQC_TRIM_PAIRED(BBDUK_COMBINED.out.paired_reads.map {it -> [it[0],[it[1],it[2]]]}, 'trimmed_paired')
            // Summarize FastQc results post-trimming
            MULTIQC_TRIM_PAIRED(FASTQC_TRIM_PAIRED.out.fastqc_out_zip.collect(), 'trimmed_paired')

        // Processing of single reads:
            // A final QC with FASTQC
            FASTQC_TRIM_SINGLES(BBDUK_COMBINED.out.single_reads.map {it -> [it[0],[it[1]]]}, 'trimmed_singles')
            // Summarize FastQc results post-trimming
            MULTIQC_TRIM_SINGLES(FASTQC_TRIM_SINGLES.out.fastqc_out_zip.collect(), 'trimmed_singles')

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Read mapping
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // Combine trimmed paired and single reads for mapping
            // SEQTK (for interleaving paired reads) + zcat (for combining with single reads) + pigz (for compression)

        // BWA-MEM
            // "bwa-mem2 mem -p -threads ...  $reference_genome $reads > ${sample_id}.sam"
        // SAMtools (BAM conversion, sorting, indexing)
        // MPileup (for VarScan2 and Lofreq)

    // SNP Calling
        // VarScan2
        // Lofreq

    // Indel Calling
        // Small indels
            // VarScan2
            // Lofreq
        // Large indels
            // Pindel
            // Breakdancer
            // Delly
            // Cortex

    // Duplication calling
        // Pindel
        // Breakdancer
        // Delly

    // Translocation calling
        // Breakdancer
        // Delly

    // Inversion calling
        // Pindel
        // Cortex

    // Variant filtering and reporting
        // VarCap (integrates results from all variant callers, applies filters, and annotates variants)

    // Variant annotation
        // SnpEff (for SNPs and small indels)
}
