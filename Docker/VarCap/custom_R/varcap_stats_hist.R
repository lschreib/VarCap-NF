#!/usr/bin/env Rscript
# pct_hist.R
# Usage: pct_hist.R --sample_id <id> --input_file <pct_hist_file>
# Generates a per-chromosome SNP frequency histogram and writes Rplots.pdf

suppressPackageStartupMessages(library(optparse))

option_list <- list(
    make_option("--sample_id",  type = "character", help = "Sample identifier"),
    make_option("--input_file", type = "character", help = "Path to <sample_id>_pct_hist.txt")
)

opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$sample_id) || is.null(opt$input_file)) {
    stop("Both --sample_id and --input_file are required.", call. = FALSE)
}

sample_id <- opt$sample_id
pct_file  <- opt$input_file

snp <- read.table(pct_file, sep = "\t", header = TRUE, dec = ".")

mysum  <- unique(snp$chrom)
sumlen <- length(mysum)
fname  <- sample_id

xs <- 1
ys <- 2
if (sumlen > 2) { xs <- 2 }

par(mfrow = c(ys, xs))

for (val in mysum) {
    sub1 <- subset(snp, chrom == val)
    sub2 <- aggregate(
        cbind(cov, freq) ~ chrom + pos,
        data    = sub1,
        FUN     = mean,
        na.rm   = TRUE
    )
    main_name <- paste(fname, val, sep = ":")
    breakmod  <- seq(0, 100, by = 2)
    hist(
        sub2$freq[sub2$freq < 101],
        breaks = breakmod,
        main   = main_name,
        col    = "lightgreen",
        xlab   = "Variant frequency",
        ylab   = "Counts",
        xlim   = c(0, 100)
    )
}
