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
include { INDEX_REFERENCE                       } from './modules/misc/index_reference.nf'
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
// Samtools
include { SAMTOOLS_TO_BAM                      } from './modules/read_mapping/samtools_to_bam.nf'
include { SAMTOOLS_INDEX                       } from './modules/read_mapping/samtools_index.nf'
include { SAMTOOLS_COVERAGE                    } from './modules/read_mapping/samtools_coverage.nf'
// Picard
include { PICARD_INSERT_SIZE                   } from './modules/read_mapping/picard_insert_size.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Variant calling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Breakdancer
//
// BWA
//
// Cortex
//
// Delly
//
// Lofreq
include { LOFREQ_QUALITY                       } from './modules/variant_calling/lofreq/lofreq_quality.nf'
include { LOFREQ_CALL                          } from './modules/variant_calling/lofreq/lofreq_call.nf'
//
// Pindel
//
include { SAM2PINDEL                            } from './modules/variant_calling/pindel/sam2pindel.nf'
include { PINDEL_CALL                           } from './modules/variant_calling/pindel/pindel_call.nf'
include { PINDEL2VCF_D                         } from './modules/variant_calling/pindel/pindel2vcf_d.nf'
include { PINDEL2VCF_SI                        } from './modules/variant_calling/pindel/pindel2vcf_si.nf'
include { PINDEL2VCF_INV                       } from './modules/variant_calling/pindel/pindel2vcf_inv.nf'
include { PINDEL2VCF_TD                        } from './modules/variant_calling/pindel/pindel2vcf_td.nf'
// Samtools
//
// SnpEff
//
// Trimmomatic
//
// VarCap
//
// Varscan2
include { SAMTOOLS_SORT                       } from './modules/variant_calling/varscan/samtools_sort.nf'
include { SAMTOOLS_MPILEUP                    } from './modules/variant_calling/varscan/samtools_mpileup.nf'
include { VARSCAN_PILEUP2INDEL                } from './modules/variant_calling/varscan/varscan_pileup2indel.nf'
include { VARSCAN_FILTER_INDEL               } from './modules/variant_calling/varscan/varscan_filter_indel.nf'
include { VARSCAN_PILEUP2SNP                  } from './modules/variant_calling/varscan/varscan_pileup2snp.nf'
include { VARSCAN_FILTER_SNP                 } from './modules/variant_calling/varscan/varscan_filter_snp.nf'
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
        INDEX_REFERENCE(PREPARE_REFERENCE.out.reference_fasta)

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
            BWA_MAPPING(BWA_BUILD_INDEX.out.reference_index, COMBINE_READS.out.merged_reads)
        // Samtools: sam to bam conversion -> sort
            SAMTOOLS_TO_BAM(BWA_MAPPING.out.sam_output)
        // Samtools: bam indexing
            SAMTOOLS_INDEX(SAMTOOLS_TO_BAM.out.bam_output)
        // Samtools: calculate coverage
            SAMTOOLS_COVERAGE(SAMTOOLS_TO_BAM.out.bam_output)
        // Picard: Calculate insert size
            PICARD_INSERT_SIZE(SAMTOOLS_TO_BAM.out.bam_output)

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant calling
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // VarScan2
            SAMTOOLS_SORT(SAMTOOLS_TO_BAM.out.bam_output)
            SAMTOOLS_MPILEUP(PREPARE_REFERENCE.out.reference_fasta, SAMTOOLS_SORT.out.sorted_bam)
            // VarScan2: call Indels
            VARSCAN_PILEUP2INDEL(SAMTOOLS_MPILEUP.out.mpileup_output)
            VARSCAN_FILTER_INDEL(VARSCAN_PILEUP2INDEL.out.varscan_indel_tmp)
            // VarScan2: call SNPs
            VARSCAN_PILEUP2SNP(SAMTOOLS_MPILEUP.out.mpileup_output)
            // Merge VarScan2 indel and SNP results by sample_id for filtering
            ch_varscan_merged = VARSCAN_PILEUP2SNP.out.varscan_snp_tmp
                .join(VARSCAN_FILTER_INDEL.out.varscan_indel_filtered, by: 0)
                .map { sample_id, snp_file, indel_file ->
                tuple(sample_id, snp_file, indel_file)
                }
            // Filter VarScan2 SNPs
            VARSCAN_FILTER_SNP(ch_varscan_merged)

        // Lofreq
            LOFREQ_QUALITY(PREPARE_REFERENCE.out.reference_fasta, SAMTOOLS_TO_BAM.out.bam_output)
            LOFREQ_CALL(PREPARE_REFERENCE.out.reference_fasta, LOFREQ_QUALITY.out.lofreq_bam)
        // Pindel
            // Run sam2pindel to generate Pindel input files (includes insert size extraction from Picard output)
            ch_pindel_input = BWA_MAPPING.out.sam_output
                .join(PICARD_INSERT_SIZE.out.insert_txt, by: 0)
                .map { sample_id, sam_file, insert_size_file  ->
                    tuple(sample_id, sam_file, insert_size_file)
                }
            SAM2PINDEL(ch_pindel_input)

            // Run Pindel for different variant types (inversions, tandem duplications, and small insertions)
            PINDEL_CALL(INDEX_REFERENCE.out.reference_index,
                        PREPARE_REFERENCE.out.reference_fasta,
                        SAM2PINDEL.out.pindel_output)

            PINDEL2VCF_D(INDEX_REFERENCE.out.reference_index, PREPARE_REFERENCE.out.reference_fasta,PINDEL_CALL.out.pindel_deletions)
            PINDEL2VCF_SI(INDEX_REFERENCE.out.reference_index, PREPARE_REFERENCE.out.reference_fasta,PINDEL_CALL.out.pindel_insertions)
            PINDEL2VCF_INV(INDEX_REFERENCE.out.reference_index, PREPARE_REFERENCE.out.reference_fasta,PINDEL_CALL.out.pindel_inversions)
            PINDEL2VCF_TD(INDEX_REFERENCE.out.reference_index, PREPARE_REFERENCE.out.reference_fasta,PINDEL_CALL.out.pindel_tandups)

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
