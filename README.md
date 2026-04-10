# VarCap-NF

Modularized Nextflow re-implementation of the [VarCap](https://github.com/ma2o/VarCap) pipeline intended to carry out variant profiling of evolving prokaryotic populations.

An overview of the VarCap pipeline version that was re-implemented can be found in the JSON file.

In detail this pipeline will carry out:

- Read QC and trimming: [Trimmomatic](https://github.com/usadellab/trimmomatic), [BBduk](https://github.com/BioInfoTools/BBMap)

- Read mapping: BWA (_Note: in contrast to original pipeline oprhaned single end reads will not be thrown out, this should make the pipleine more robust when run with low quality data_)

- Variant detection:
    - SNPs: [Varscan2](https://dkoboldt.github.io/varscan/), [LoFreq](https://csb5.github.io/lofreq/)
    - Small indels: Varscan2, [Pindel](https://gmt.genome.wustl.edu/packages/pindel/)
    - Large indels: Pindel, [Breakdancer](https://github.com/genome/breakdancer), [Delly](https://github.com/dellytools/delly), [Cortex_var](https://cortexassembler.sourceforge.net/index_cortex_var.html)
    - Duplications: Pindel, Breakdancer, Delly
    - Translocations: Breakdancer, Delly
    - Inversions: Pindel, Cortex_var

- Variant Consolidation and filtering: VarCap (_This is really the key piece of the VarCap pipeline. Re-implementing this step involved a lot of re-using the original shell commands and Perl scripts. Some of the operations and used default settings here are still not entirely clear to me, so I might re-visit this module later after having played around a bit with the resulting data_.)

- Variant annotation: [SnpEff](https://pcingola.github.io/SnpEff/)

Integrated supporting modules: [Samtools](https://www.htslib.org/), [Picard](https://broadinstitute.github.io/picard/), [BCFTools](https://samtools.github.io/bcftools/), and [SeqTK](https://github.com/lh3/seqtk)

Software dependencies: Docker, Singularity (>=1.4.2), Nextflow (>=23.04.3), Slurm scheduler

# Usage

1) Build the individual Docker containers and convert them to (Singularity) SIF format
2) Set up the Nextflow work directory folder on your compute cluster:
   The directory should contain the following sub-directories:
   - reads_workdir[dir]: put your illumina paired-end files here
   - reference_genome[dir]: put your reference genome in GBK format here
   - modules[dir]: directory containing all individual Nextflow processes; cloned from this repo
   - varcap_workflow.nf[file]: Nextflow master workflow file
   - varcap_config.nf[file]: Nextflow config file
3) Edit the varcap.config file to: (a) have the indidual processes point to the location of the corresponding Singularity container; (b) make sure that the _reference_genome_gbk_ and _raw_reads_ parameters point to the your input files; (c) potentially adjust resource allocation to the size of your dataset.
4) Run the pipeline with

   ```
   nextflow run varcap_workflow.nf -c varcap_config.nf [-bg] [-resume] [-with-trace] [| tee log_pipeline_20260410.txt]
   ```
