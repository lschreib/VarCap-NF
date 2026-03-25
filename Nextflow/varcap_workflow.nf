/*
    parameters are defined in the shotgunmg_config.nf file
*/
log.info """
#########################################################################################

  __     __          ____                  _   _ _____
 \\ \\   / /_ _ _ __ / ___|__ _ _ __       | \\ | |  ___|
  \\ \\ / / _` | '__| |   / _` | '_ \\ _____|  \\| | |_
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
MODULES: Preparation of project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// Prepare reference genome
include { PREPARE_REFERENCE                     } from './modules/misc/prepare_reference.nf'

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
include { MULTIQC as MULTIQC_TRIM_PAIRED        } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM_SINGLES       } from './modules/reads_qc/multiqc/multiqc.nf'
//
//Trimmomatic
include { TRIMMOMATIC                           } from './modules/reads_qc/trimmomatic/trimmomatic.nf'
//
//BBDUK
include { BBDUK_COMBINED                        } from './modules/bbduk/bbduk_combined.nf'
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Read mapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// Combine_reads
include { COMBINE_READS                         } from './modules/misc/combine_reads.nf'
//
// BWA
include { BWA_BUILD_INDEX                      } from './modules/read_mapping/bwa_build_index.nf'
include { BWA_MAPPING                          } from './modules/read_mapping/bwa_mapping.nf'
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
        Project preparation
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        PREPARE_REFERENCE(params.DEFAULT.reference_genome_gbk)

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
            COMBINE_READS(BBDUK_COMBINED.out.paired_reads, BBDUK_COMBINED.out.single_reads)

        // BWA: Build index
            BWA_BUILD_INDEX(PREPARE_REFERENCE.out.reference_fasta)
        // BWA: Map reads to reference genome
            BWA_MAPPING(BWA_BUILD_INDEX.out.reference_index, COMBINE_READS.out.combined_reads)
        // Samtools: sam to bam conversion -> sort

        // Samtools: bam indexing

        // Samtools: calculate coverage

        // Picard: Calculate insert size


        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant calling
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // VarScan2
        // Lofreq
        // Pindel
        // Breakdancer
        // Delly
        // Cortex

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant filtering
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // VarCap (integrates results from all variant callers, applies filters, and annotates variants)

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant annotation
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // SnpEff (for SNPs and small indels)
}
