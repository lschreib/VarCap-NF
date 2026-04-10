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
               Version: 1.0.0
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
include { PREPARE_REFERENCE                    } from './modules/misc/prepare_reference.nf'
include { INDEX_REFERENCE                      } from './modules/misc/index_reference.nf'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Read QC and trimming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
//
//FastQC
include { FASTQC as FASTQC_RAW                 } from './modules/reads_qc/fastqc/fastqc.nf'
include { FASTQC as FASTQC_TRIM_PAIRED         } from './modules/reads_qc/fastqc/fastqc.nf'
include { FASTQC as FASTQC_TRIM_SINGLES        } from './modules/reads_qc/fastqc/fastqc.nf'
//
//MultiQC
include { MULTIQC as MULTIQC_RAW               } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM_PAIRED       } from './modules/reads_qc/multiqc/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM_SINGLES      } from './modules/reads_qc/multiqc/multiqc.nf'
//
//Trimmomatic
include { TRIMMOMATIC                          } from './modules/reads_qc/trimmomatic/trimmomatic.nf'
//
//BBDUK
include { BBDUK                                } from './modules/bbduk/bbduk.nf'
include { BBDUK_COMBINED                       } from './modules/bbduk/bbduk_combined.nf'
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Read mapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// Combine_reads
//include { COMBINE_READS                        } from './modules/misc/combine_reads.nf'
//
// BWA
include { BWA_BUILD_INDEX                      } from './modules/read_mapping/bwa_build_index.nf'
include { BWA_MAPPING_PE                       } from './modules/read_mapping/bwa_mapping_pe.nf'
include { BWA_MAPPING_SE                       } from './modules/read_mapping/bwa_mapping_se.nf'
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Samtools and Picard helper modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// Picard
include { PICARD_ADD_READ_GROUP                } from './modules/picard/picard_add_read_group.nf'
include { PICARD_INSERT_SIZE                   } from './modules/picard/picard_insert_size.nf'
include { PICARD_MARK_DUP                      } from './modules/picard/picard_mark_dup.nf'
include { PICARD_BAM_TO_FASTQ                  } from './modules/picard/picard_bam_to_fastq.nf'

// Samtools
include { SAMTOOLS_COVERAGE                    } from './modules/samtools/samtools_coverage.nf'
include { SAMTOOLS_INDEX                       } from './modules/samtools/samtools_index.nf'
include { SAMTOOLS_MERGE                       } from './modules/samtools/samtools_merge.nf'
include { SAMTOOLS_MPILEUP                     } from './modules/samtools/samtools_mpileup.nf'
include { SAMTOOLS_SORT                        } from './modules/samtools/samtools_sort.nf'
include { SAMTOOLS_TO_BAM_PE                   } from './modules/samtools/samtools_to_bam_pe.nf'
include { SAMTOOLS_TO_BAM_SE                   } from './modules/samtools/samtools_to_bam_se.nf'
include { SAMTOOLS_TO_SAM                      } from './modules/samtools/samtools_to_sam.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Variant calling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Breakdancer
include { BREAKDANCER_MAKE_CONFIG              } from './modules/variant_calling/breakdancer/breakdancer_make_config.nf'
include { BREAKDANCER_MAX                      } from './modules/variant_calling/breakdancer/breakdancer_max.nf'
include { BREAKDANCER_FILTER                   } from './modules/variant_calling/breakdancer/breakdancer_filter.nf'
//
// Cortex
//
include { BBTOOLS_REPAIR_READS                 } from './modules/bbduk/bbtools_repair_reads.nf'
include { CORTEX_K31                           } from './modules/variant_calling/cortex/cortex_k31.nf'
include { CORTEX_K61                           } from './modules/variant_calling/cortex/cortex_k61.nf'
include { CORTEX_CALL                          } from './modules/variant_calling/cortex/cortex_call.nf'
// Delly
//
include { DELLY as DELLY_DEL                   } from './modules/variant_calling/delly/delly.nf'
include { DELLY as DELLY_INS                   } from './modules/variant_calling/delly/delly.nf'
include { DELLY as DELLY_DUP                   } from './modules/variant_calling/delly/delly.nf'
include { DELLY as DELLY_INV                   } from './modules/variant_calling/delly/delly.nf'
include { DELLY as DELLY_BND                   } from './modules/variant_calling/delly/delly.nf'
include { BCF_TO_VCF as BCF_TO_VCF_DEL         } from './modules/variant_calling/misc/bcf_to_vcf.nf'
include { BCF_TO_VCF as BCF_TO_VCF_INS         } from './modules/variant_calling/misc/bcf_to_vcf.nf'
include { BCF_TO_VCF as BCF_TO_VCF_DUP         } from './modules/variant_calling/misc/bcf_to_vcf.nf'
include { BCF_TO_VCF as BCF_TO_VCF_INV         } from './modules/variant_calling/misc/bcf_to_vcf.nf'
include { BCF_TO_VCF as BCF_TO_VCF_BND         } from './modules/variant_calling/misc/bcf_to_vcf.nf'
//
// Lofreq
include { LOFREQ_QUALITY                       } from './modules/variant_calling/lofreq/lofreq_quality.nf'
include { LOFREQ_CALL                          } from './modules/variant_calling/lofreq/lofreq_call.nf'
//
// Pindel
//
include { SAM2PINDEL                           } from './modules/variant_calling/pindel/sam2pindel.nf'
include { PINDEL_CALL                          } from './modules/variant_calling/pindel/pindel_call.nf'
include { PINDEL2VCF_D                         } from './modules/variant_calling/pindel/pindel2vcf_d.nf'
include { PINDEL2VCF_SI                        } from './modules/variant_calling/pindel/pindel2vcf_si.nf'
include { PINDEL2VCF_INV                       } from './modules/variant_calling/pindel/pindel2vcf_inv.nf'
include { PINDEL2VCF_TD                        } from './modules/variant_calling/pindel/pindel2vcf_td.nf'
// Varscan2
include { VARSCAN_PILEUP2INDEL                 } from './modules/variant_calling/varscan/varscan_pileup2indel.nf'
include { VARSCAN_FILTER_INDEL                 } from './modules/variant_calling/varscan/varscan_filter_indel.nf'
include { VARSCAN_PILEUP2SNP                   } from './modules/variant_calling/varscan/varscan_pileup2snp.nf'
include { VARSCAN_FILTER_SNP                   } from './modules/variant_calling/varscan/varscan_filter_snp.nf'
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: Varcap - variant filtering and integration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { VARCAP_STAGE_AND_COLLECT             } from './modules/varcap/varcap_stage_and_collect.nf'
include { VARCAP_UNIFY_CHROM_NAMES             } from './modules/varcap/varcap_unify_chrom_names.nf'
include { VARCAP_CALCULATE_COVERAGE            } from './modules/varcap/varcap_calculate_coverage.nf'
include { VARCAP_BUILD_REPEAT_VCF              } from './modules/varcap/varcap_build_repeat_vcf.nf'
include { VARCAP_TAG_REPEATS                   } from './modules/varcap/varcap_tag_repeats.nf'
include { VARCAP_TAG_HOMOPOLYMERS              } from './modules/varcap/varcap_tag_homopolymers.nf'
include { VARCAP_TAG_SAR                       } from './modules/varcap/varcap_tag_sar.nf'
include { VARCAP_TAG_CALLER_POS                } from './modules/varcap/varcap_tag_caller_pos.nf'
include { VARCAP_APPLY_MRA_FILTER              } from './modules/varcap/varcap_apply_mra_filter.nf'
include { VARCAP_UNIFY_GI_CHROM_NAMES          } from './modules/varcap/varcap_unify_gi_chrom_names.nf'
include { VARCAP_STATS_COVERAGE                } from './modules/varcap/varcap_stats_coverage.nf'
include { VARCAP_STATS_VARIANT_FREQUENCY       } from './modules/varcap/varcap_stats_variant_frequency.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MODULES: variant annotation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// SnpEff
include { SNPEFF_BUILD_DB                      } from './modules/annotation/snpeff_build_db.nf'
include { SNPEFF_ANNOTATE                      } from './modules/annotation/snpeff_annotate.nf'
include { SNPEFF_TABULATE                      } from './modules/annotation/snpeff_tabulate.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
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
        // BWA: Build index for downstream mapping
        BWA_BUILD_INDEX(PREPARE_REFERENCE.out.reference_fasta)

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

        if (params.DEFAULT.recycle_single) {
            // Combine trimmed paired and single reads for mapping
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
        } else {
            BBDUK(TRIMMOMATIC.out.paired_reads)

            // A final QC with FASTQC
            FASTQC_TRIM_PAIRED(BBDUK.out.paired_reads.map {it -> [it[0],[it[1],it[2]]]}, 'trimmed_paired')
            // Summarize FastQc results post-trimming
            MULTIQC_TRIM_PAIRED(FASTQC_TRIM_PAIRED.out.fastqc_out_zip.collect(), 'trimmed_paired')
        }

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Read mapping
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // Combine trimmed paired and single reads for mapping
            //COMBINE_READS(BBDUK_COMBINED.out.paired_reads, BBDUK_COMBINED.out.single_reads)

        if (params.DEFAULT.recycle_single) {
            // BWA: Map reads to paired reads to reference genome (including single reads)
            BWA_MAPPING_PE(BWA_BUILD_INDEX.out.reference_index, BBDUK_COMBINED.out.paired_reads)
            // BWA_MAPPING_SE(BWA_BUILD_INDEX.out.reference_index, BBDUK_COMBINED.out.single_reads)
            BWA_MAPPING_SE(BWA_BUILD_INDEX.out.reference_index, BBDUK_COMBINED.out.single_reads)
            // Create BAM files
            SAMTOOLS_TO_BAM_PE(BWA_MAPPING_PE.out.sam_output_pe)
            SAMTOOLS_TO_BAM_SE(BWA_MAPPING_SE.out.sam_output_se)

            // join channels for PE and SE samtools merge
            ch_samtools_merge_input = SAMTOOLS_TO_BAM_PE.out.bam_output
                .join(SAMTOOLS_TO_BAM_SE.out.bam_output, by: 0)
                .map { sample_id, pe_bam, se_bam ->
                    tuple(sample_id, pe_bam, se_bam)
                }

            // merge reads BAM files
            SAMTOOLS_MERGE(ch_samtools_merge_input)

            ch_final_bam = SAMTOOLS_MERGE.out.merged_bam
            // -> channel out for samtools 
        } else {
        // BWA: Map reads to reference genome
            BWA_MAPPING_PE(BWA_BUILD_INDEX.out.reference_index, BBDUK.out.paired_reads)
            // Create BAM file
            SAMTOOLS_TO_BAM_PE(BWA_MAPPING_PE.out.sam_output_pe)

            ch_final_bam = SAMTOOLS_TO_BAM_PE.out.bam_output
        }

        // Picard: add read group information (for Dell, Breakdancer, and Cortex)
            PICARD_ADD_READ_GROUP(ch_final_bam)

        // Samtools: sort
            SAMTOOLS_SORT(PICARD_ADD_READ_GROUP.out.read_group_bam)

        // Samtools: bam to sam (for Pindel)
            SAMTOOLS_TO_SAM(SAMTOOLS_SORT.out.sorted_bam)

        // Samtools: index
            SAMTOOLS_INDEX(SAMTOOLS_SORT.out.sorted_bam)



        // *** Calculate stats ***
        // Samtools: calculate coverage
            SAMTOOLS_COVERAGE(SAMTOOLS_SORT.out.sorted_bam)
        // Picard: Calculate insert size
            PICARD_INSERT_SIZE(SAMTOOLS_SORT.out.sorted_bam)

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant calling
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // VarScan2
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
            LOFREQ_QUALITY(PREPARE_REFERENCE.out.reference_fasta, SAMTOOLS_SORT.out.sorted_bam)
            LOFREQ_CALL(PREPARE_REFERENCE.out.reference_fasta, LOFREQ_QUALITY.out.lofreq_bam)
        // Pindel
            // Run sam2pindel to generate Pindel input files (includes insert size extraction from Picard output)
            ch_pindel_input = BWA_MAPPING_PE.out.sam_output_pe
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


        // Delly
            // Picard mark duplicates (for Delly)
            PICARD_MARK_DUP(SAMTOOLS_SORT.out.sorted_bam)

            //Duplicates-marked and indexed BAM -> Delly DEL, INS, DUP, INV, BND
            DELLY_DEL(PREPARE_REFERENCE.out.reference_fasta,
                      PICARD_MARK_DUP.out.dupmarked_bam,
                      'DEL')
            BCF_TO_VCF_DEL(DELLY_DEL.out.delly_bcf_output)
            //
            DELLY_INS(PREPARE_REFERENCE.out.reference_fasta,
                      PICARD_MARK_DUP.out.dupmarked_bam,
                      'INS')
            BCF_TO_VCF_INS(DELLY_INS.out.delly_bcf_output)
            //
            DELLY_DUP(PREPARE_REFERENCE.out.reference_fasta,
                      PICARD_MARK_DUP.out.dupmarked_bam,
                      'DUP')
            BCF_TO_VCF_DUP(DELLY_DUP.out.delly_bcf_output)
            //
            DELLY_INV(PREPARE_REFERENCE.out.reference_fasta,
                      PICARD_MARK_DUP.out.dupmarked_bam,
                      'INV')
            BCF_TO_VCF_INV(DELLY_INV.out.delly_bcf_output)
            //
            DELLY_BND(PREPARE_REFERENCE.out.reference_fasta,
                      PICARD_MARK_DUP.out.dupmarked_bam,
                      'BND')
            BCF_TO_VCF_BND(DELLY_BND.out.delly_bcf_output)
        //
        // Breakdancer
            // Create Breakdancer config file from BAM header
            BREAKDANCER_MAKE_CONFIG(PICARD_MARK_DUP.out.dupmarked_bam)

            // Merge config files with bam files
            ch_breakdancer_input = BREAKDANCER_MAKE_CONFIG.out.breakdancer_config
                .join(PICARD_MARK_DUP.out.dupmarked_bam, by: 0)
                .map { sample_id, breakdancer_config, bam_file, bam_index ->
                    tuple(sample_id, breakdancer_config, bam_file)
                }

            // Run Breakdancer
            BREAKDANCER_MAX(ch_breakdancer_input)
            // Carry out post-processing of Breakdancer output (e.g., filtering, formatting)
            BREAKDANCER_FILTER(BREAKDANCER_MAX.out.breakdancer_ctx)

        // Cortex
            // Prepare Cortex input files
                // BAM to FASTQ
                PICARD_BAM_TO_FASTQ(SAMTOOLS_SORT.out.sorted_bam)
                BBTOOLS_REPAIR_READS(PICARD_BAM_TO_FASTQ.out.fastq_output)
                // Build reference genome binaries
                CORTEX_K31(PREPARE_REFERENCE.out.reference_fasta)
                CORTEX_K61(PREPARE_REFERENCE.out.reference_fasta)

            // Run Cortex for different k-mer sizes
                CORTEX_CALL(PREPARE_REFERENCE.out.reference_fasta,
                            INDEX_REFERENCE.out.reference_index,
                            BBTOOLS_REPAIR_READS.out.repaired_reads,
                            CORTEX_K31.out.cortex_k31_binary,
                            CORTEX_K61.out.cortex_k61_binary)

        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant filtering
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // VarCap (integrates results from all variant callers, applies filters, and annotates variants)

        // 1. Combine all variant caller outputs
        // Match different channels by sample id
        // ---------- normalize channels to tuple(sample_id, file) ----------

        // Varscan2
        ch_varscan_snp   = VARSCAN_FILTER_SNP.out.varscan_snp_filtered
        ch_varscan_indel = VARSCAN_FILTER_INDEL.out.varscan_indel_filtered

        // Breakdancer
        ch_breakd        = BREAKDANCER_FILTER.out.breakdancer_ctx_filtered

        // Delly
        ch_delly_del = BCF_TO_VCF_DEL.out.vcf_output
        ch_delly_dup = BCF_TO_VCF_DUP.out.vcf_output
        ch_delly_ins = BCF_TO_VCF_INS.out.vcf_output
        ch_delly_inv = BCF_TO_VCF_INV.out.vcf_output
        // legacy collector expects TRA; workflow uses BND (rename later in stage process).
        ch_delly_bnd = BCF_TO_VCF_BND.out.vcf_output

        // Pindel
        ch_pindel_d   = PINDEL2VCF_D.out.pindel_vcf_deletions
        ch_pindel_si  = PINDEL2VCF_SI.out.pindel_vcf_insertions
        ch_pindel_inv = PINDEL2VCF_INV.out.pindel_vcf_inversions
        ch_pindel_td  = PINDEL2VCF_TD.out.pindel_vcf_tandups

        // Lofreq2
        ch_lofreq = LOFREQ_CALL.out.lofreq_vcf

        // cortex currently emits only path -> recover sample_id from known suffix
        ch_cortex_raw = CORTEX_CALL.out.cortex_raw_out

        // ---------- group per tool ----------
        ch_delly = ch_delly_del
            .join(ch_delly_dup, by: 0)
            .join(ch_delly_ins, by: 0)
            .join(ch_delly_bnd, by: 0)   // mapped to your stage input slot "delly_tra_vcf"
            .join(ch_delly_inv, by: 0)
            .map { sample_id, del, dup, ins, bnd, inv ->
                tuple(sample_id, del, dup, ins, bnd, inv)
            }

        ch_pindel = ch_pindel_d
            .join(ch_pindel_si, by: 0)
            .join(ch_pindel_inv, by: 0)
            .join(ch_pindel_td, by: 0)
            .map { sample_id, d, si, inv, td ->
                tuple(sample_id, d, si, inv, td)
            }

        ch_varscan = ch_varscan_snp
            .join(ch_varscan_indel, by: 0)
            .map { sample_id, snp, indel -> tuple(sample_id, snp, indel) }

        // ---------- final stage input ----------
        ch_stage_collect_input = ch_breakd
            .join(ch_cortex_raw, by: 0)
            .join(ch_delly,  by: 0)
            .join(ch_lofreq, by: 0)
            .join(ch_pindel, by: 0)
            .join(ch_varscan, by: 0)
            .map { sample_id, breakd, cortex_raw, del, dup, ins, bnd, inv, lofreq, pin_d, pin_si, pin_inv, pin_td, snp, indel ->
                tuple(sample_id, breakd, cortex_raw, del, dup, ins, bnd, inv, lofreq, pin_d, pin_si, pin_inv, pin_td, snp, indel)
            }

        VARCAP_STAGE_AND_COLLECT(PREPARE_REFERENCE.out.reference_fasta, ch_stage_collect_input)

        // 2. Unify chromosome names as callers handle them differently
        VARCAP_UNIFY_CHROM_NAMES(VARCAP_STAGE_AND_COLLECT.out.varcap_vcf)

        // 3. Calculate coverage for chromosomes and positions
        ch_sam_to_vcf = VARCAP_UNIFY_CHROM_NAMES.out.vcf_unified
                            .join(SAMTOOLS_SORT.out.sorted_bam, by: 0)
                            .map { sample_id, vcf_file, bam_file ->
                                tuple(sample_id, vcf_file, bam_file)
                            }

        VARCAP_CALCULATE_COVERAGE(ch_sam_to_vcf)

        // 4. Search for repetitive elements within the reference genome that are longer than insert size and tag homopolymers
        VARCAP_BUILD_REPEAT_VCF(PREPARE_REFERENCE.out.reference_fasta)

        VARCAP_TAG_REPEATS(
            VARCAP_BUILD_REPEAT_VCF.out.ref_repeat_vcf,
            VARCAP_CALCULATE_COVERAGE.out.vcf_with_cov
        )

        VARCAP_TAG_HOMOPOLYMERS(
            PREPARE_REFERENCE.out.reference_fasta,
            VARCAP_TAG_REPEATS.out.rep_vcf
        )
        VARCAP_TAG_SAR(VARCAP_TAG_HOMOPOLYMERS.out.hopo_vcf)
        VARCAP_TAG_CALLER_POS(VARCAP_TAG_SAR.out.vcf_sar)

        // 5. Apply MRA filter
        VARCAP_APPLY_MRA_FILTER(VARCAP_TAG_CALLER_POS.out.vcf_cpv)
        VARCAP_UNIFY_GI_CHROM_NAMES(VARCAP_APPLY_MRA_FILTER.out.vcf_filtered)

        // 6. Generate statistics
        ch_stats_cov_input = VARCAP_UNIFY_GI_CHROM_NAMES.out.vcf_gi_unified
            .join(VARCAP_CALCULATE_COVERAGE.out.cov_total, by: 0)
            .map { sample_id, vcf, total_cov ->
                tuple(sample_id, vcf, total_cov)
            }

        VARCAP_STATS_COVERAGE(ch_stats_cov_input)
        VARCAP_STATS_VARIANT_FREQUENCY(VARCAP_UNIFY_GI_CHROM_NAMES.out.vcf_gi_unified)


        /*
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Variant annotation
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        */
        // SnpEff: annotate filtered variants with functional consequences.
        // Input VCF: per-sample output from VARCAP_UNIFY_GI_CHROM_NAMES.
        // DB inputs: shared across all samples (combine with .combine() not .join()).
        SNPEFF_BUILD_DB(params.DEFAULT.reference_genome_gbk)
        SNPEFF_ANNOTATE(
            VARCAP_UNIFY_GI_CHROM_NAMES.out.vcf_gi_unified,
            SNPEFF_BUILD_DB.out.db_dir,
            SNPEFF_BUILD_DB.out.snpeff_config,
            SNPEFF_BUILD_DB.out.genome_id
        )

        // Export a flat, R-friendly TSV from the snpEff-annotated VCF.
        SNPEFF_TABULATE(SNPEFF_ANNOTATE.out.annotated_vcf)
}
