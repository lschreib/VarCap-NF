# Implementation strategy for read tracking across the pipeline:

## 1) Raw reads: parse from FastQC 'fastqc_data.txt'

<pre><code>
##FastQC	0.11.9
>>Basic Statistics	pass
#Measure	Value
Filename	BEASTp4_13dec24_Metag_R1.fastq.gz
File type	Conventional base calls
Encoding	Sanger / Illumina 1.9
<b>Total Sequences	55673680</b>
Sequences flagged as poor quality	0
Sequence length	151
%GC	57
>>END_MODULE
...
</code></pre>

## 2) Trimmed reads (Trimmomatic): parse from Trimmomatic '${sample_id}_trimmomatic_log.txt'

<pre><code>
TrimmomaticPE: Started with arguments:
 -threads 4 -phred33 BMP_FW3_Metg_R1.fastq.gz BMP_FW3_Metg_R2.fastq.gz BMP_FW3_Metg_paired_R1.fastq.gz BMP_FW3_Metg_single_R1.fastq.gz BMP_FW3_Metg_paired_R2.fastq.gz BMP_FW3_Metg_single_R2.fastq.gz ILLUMINACLIP:/gpfs/fs7/grdi/genarcc/grdi_eco/bioinfo-tools/nrc_nf/databases/contaminants/adapters-nextera-xt.fa:2:10:10 TRAILING:30 SLIDINGWINDOW:4:15 MINLEN:45 HEADCROP:15 CROP:110
Using Medium Clipping Sequence: 'CTGTCTCTTATACACATC'
Using Long Clipping Sequence: 'GACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG'
ILLUMINACLIP: Using 0 prefix pairs, 0 forward/reverse sequences, 1 forward only sequences, 1 reverse only sequences
Input Read Pairs: 7351357 <b>Both Surviving: 6694859 (91.07%)</b> Forward Only Surviving: 97966 (1.33%) Reverse Only Surviving: 545627 (7.42%) Dropped: 12905 (0.18%)
TrimmomaticPE: Completed successfully
</code></pre>

## 3) Trimmed reads (BBDUK): parse from BBDUK STDOUT

<pre><code>
java -Djava.io.tmpdir=/gpfs/fs5/nrc/nrc-fs1/eme/las003/scratch/tmp -ea -Xmx1g -Xms1g -cp /bbmap/current/ jgi.BBDuk -Xmx1g in=BMP_FW3_Metg_paired_R1.fastq.gz in2=BMP_FW3_Metg_paired_R2.fastq.gz out=BMP_FW3_Metg_paired_ncontam_R1.fastq.gz out2=BMP_FW3_Metg_paired_ncontam_R2.fastq.gz outm=BMP_FW3_Metg_paired_contam_R1.fastq.gz outm2=BMP_FW3_Metg_paired_contam_R2.fastq.gz stats=BMP_FW3_Metg_bbduk_log.txt k=21 minkmerhits=1 ref=/gpfs/fs7/grdi/genarcc/grdi_eco/bioinfo-tools/nrc_nf/databases/contaminants/Illumina.artifacts_phix.fa overwrite=true threads=1
Executing jgi.BBDuk [-Xmx1g, in=BMP_FW3_Metg_paired_R1.fastq.gz, in2=BMP_FW3_Metg_paired_R2.fastq.gz, out=BMP_FW3_Metg_paired_ncontam_R1.fastq.gz, out2=BMP_FW3_Metg_paired_ncontam_R2.fastq.gz, outm=BMP_FW3_Metg_paired_contam_R1.fastq.gz, outm2=BMP_FW3_Metg_paired_contam_R2.fastq.gz, stats=BMP_FW3_Metg_bbduk_log.txt, k=21, minkmerhits=1, ref=/gpfs/fs7/grdi/genarcc/grdi_eco/bioinfo-tools/nrc_nf/databases/contaminants/Illumina.artifacts_phix.fa, overwrite=true, threads=1]
Version 39.01

Set threads to 1
0.030 seconds.
Initial:
Memory: max=1073m, total=1073m, free=1045m, used=28m

Added 5689 kmers; time: 	0.052 seconds.
Memory: max=1073m, total=1073m, free=1041m, used=32m

Input is being processed as paired
Started output streams:	0.062 seconds.
Processing time:   		70.864 seconds.

Input:                  	13389718 reads 		1335304490 bases.
Contaminants:           	1729302 reads (12.92%) 	132896088 bases (9.95%)
Total Removed:          	1729302 reads (12.92%) 	132896088 bases (9.95%)
<b>Result:                 	11660416 reads (87.08%) 	1202408402 bases (90.05%)</b>

Time:                         	70.993 seconds.
Reads Processed:      13389k 	188.61k reads/sec
Bases Processed:       1335m 	18.81m bases/sec
</code></pre>

## 4) Assembled reads: parse from BBMAP contig coverage file '${sample_id}_bbmapcov_log.txt'

<pre><code>
Reads Used:           	11657166	(1202125854 bases)

Mapping:          	237.774 seconds.
Reads/sec:       	49026.20
kBases/sec:      	5055.75


Pairing data:   	pct pairs	num pairs 	pct bases	   num bases

mated pairs:     	 60.1463% 	  3505679 	 62.9634% 	   756899566
bad pairs:       	  0.7788% 	    45394 	  0.8180% 	     9833144
insert size avg: 	  210.60


Read 1 data:      	pct reads	num reads 	pct bases	   num bases

<b>mapped:          	 85.7339% 	  4997074 	 85.7653% 	   484570278</b>
unambiguous:     	 85.1021% 	  4960246 	 85.2693% 	   481767466
ambiguous:       	  0.6319% 	    36828 	  0.4961% 	     2802812
low-Q discards:  	  0.0001% 	        7 	  0.0001% 	         542

perfect best site:	 52.5792% 	  3064621 	 51.1529% 	   289011578
semiperfect site:	 52.7844% 	  3076580 	 51.3655% 	   290212481
rescued:         	  0.1101% 	     6420

Match Rate:      	      NA 	       NA 	 99.0669% 	   480053317
Error Rate:      	 38.2827% 	  1913015 	  0.8982% 	     4352546
Sub Rate:        	 38.2669% 	  1912223 	  0.8900% 	     4312814
Del Rate:        	  0.0476% 	     2377 	  0.0010% 	        4624
Ins Rate:        	  0.2328% 	    11635 	  0.0072% 	       35108
N Rate:          	  0.6115% 	    30556 	  0.0349% 	      169039


Read 2 data:      	pct reads	num reads 	pct bases	   num bases

<b>mapped:          	 62.0407% 	  3616093 	 62.1101% 	   395722085</b>
unambiguous:     	 61.8256% 	  3603558 	 61.9004% 	   394386302
ambiguous:       	  0.2151% 	    12535 	  0.2097% 	     1335783
low-Q discards:  	  0.0000% 	        0 	  0.0000% 	           0

perfect best site:	 35.0701% 	  2044091 	 35.2360% 	   224499017
semiperfect site:	 35.2634% 	  2055358 	 35.4302% 	   225736648
rescued:         	  0.0949% 	     5529

Match Rate:      	      NA 	       NA 	 98.3724% 	   389316773
Error Rate:      	 43.1735% 	  1561195 	  1.5864% 	     6278146
Sub Rate:        	 43.0075% 	  1555193 	  1.4853% 	     5878060
Del Rate:        	  0.4818% 	    17423 	  0.0091% 	       36016
Ins Rate:        	  2.8283% 	   102273 	  0.0920% 	      364070
N Rate:          	  0.5091% 	    18409 	  0.0412% 	      163182
</code></pre>
