# VarCap-NF

Modularized Nextflow re-implementation of the [VarCap pipeline](https://github.com/ma2o/VarCap) intended to carry out variant profiling of evolving prokaryotic populations.

An overview of the steps to be implemented can be found in the JSON file. In detail the pipeline will require modules for:

- Read QC and trimming: Trimmomatic, BBduk
- Read mapping: BWA
- Variant detection:
    - SNPs: Varscan2, LoFreq*
    - Small indels: Varscan2, Pindel
    - Large indels: Pindel, Breakdancer, Delly, Cortex_var
    - Duplications: Pindel, Breakdancer, Delly
    - Translocations: Breakdancer, Delly
    - Inversions: Pindel, Cortex_var
- Variant Consolidation and filtering: VarCap
- Variant annotation: SnpEff

Required supporting modules will include: Samtools and Picard
