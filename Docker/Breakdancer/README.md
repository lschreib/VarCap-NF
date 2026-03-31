I modified the Breakdancer "bam2cfg.pl" script to better be able to deal with extreme values in the insert size distribution.

The script now includes a "-t" option that performs fractional tail trimming of the distribution. A t=0.01 should be sufficient for most datasets, however some datasets might require values of up to t=0.05. The original script used a filter that was more subsceptible to extreme values, i.e. it excluded any insert sizes that were greater than:

  mean + ( 5 * standard_deviation )

_Note: this change will affect the sensitivity of the variant detection._
