#!/usr/bin/env Rscript
# varcap_stats_cov.R
# Usage:
#   varcap_stats_cov.R --sample_id <id> --cov_total <file> \
#       --cov_snp <file> --cov_indel <file> --cov_sv <file> --cov_bp <file>
# Generates Rplots.pdf

suppressPackageStartupMessages(library(optparse))

option_list <- list(
    make_option("--sample_id", type = "character", help = "Sample identifier"),
    make_option("--cov_total", type = "character", help = "Path to total coverage table"),
    make_option("--cov_snp", type = "character", help = "Path to SNP coverage table"),
    make_option("--cov_indel", type = "character", help = "Path to small InDel coverage table"),
    make_option("--cov_sv", type = "character", help = "Path to structural variant coverage table"),
    make_option("--cov_bp", type = "character", help = "Path to breakpoint coverage table")
)

opt <- parse_args(OptionParser(option_list = option_list))

required_args <- c("sample_id", "cov_total", "cov_snp", "cov_indel", "cov_sv", "cov_bp")
missing_args <- required_args[vapply(required_args, function(arg) is.null(opt[[arg]]), logical(1))]
if (length(missing_args) > 0) {
    stop(
        sprintf("Missing required arguments: %s", paste(sprintf("--%s", missing_args), collapse = ", ")),
        call. = FALSE
    )
}

read_or_default <- function(file_path) {
    if (file.exists(file_path) && file.info(file_path)$size > 0) {
        read.table(file_path, sep = "\t", header = FALSE, dec = ".")
    } else {
        matrix(c(0, 0, 0, 0, 0), ncol = 5, byrow = TRUE)
    }
}

fname <- opt$sample_id
totcov <- read.table(opt$cov_total, sep = "\t", header = FALSE, dec = ".")
snp <- read_or_default(opt$cov_snp)
indel <- read_or_default(opt$cov_indel)
sv <- read_or_default(opt$cov_sv)
bp <- read_or_default(opt$cov_bp)

mysum <- unique(snp[[1]])
indelsum <- unique(indel[[1]])
totsum <- unique(totcov[[1]])
svsum <- unique(sv[[1]])
bpsum <- unique(bp[[1]])

par(mfrow = c(3, 2))

for (val in totsum) {
    subtot <- subset(totcov, totcov[[1]] == val)
    sub1 <- subset(snp, snp[[1]] == val)
    subindel <- subset(indel, indel[[1]] == val)
    subsv <- subset(sv, sv[[1]] == val)
    subbp <- subset(bp, bp[[1]] == val)

    plot(subtot[c(2, 3)], col = "lightblue", main = val, xlab = "position", ylab = "coverage", cex = .3)
    if (val %in% mysum) {
        points(sub1[c(2, 4)], col = "red", main = val, xlab = "position", ylab = "coverage", cex = .6)
        mtext(fname, side = 1, line = 4, cex = .6)
    }
    if (val %in% indelsum) {
        points(subindel[c(2, 4)], col = "blue", main = val, xlab = "position", ylab = "frequency", cex = .6, ylim = c(0, 100))
        mtext(fname, side = 1, line = 4, cex = .6)
    }
    if (val %in% svsum) {
        points(subsv[c(2, 4)], col = "orange", cex = .6, ylim = c(0, 100))
    }
    if (val %in% bpsum) {
        points(subbp[c(2, 4)], col = "black", cex = .6, ylim = c(0, 100))
    }

    par(xpd = TRUE)
    legend(
        "bottomleft",
        inset = c(-0.18, -0.6),
        c("SNP", "InDel", "SV", "BP"),
        lty = c(NA, NA, NA, NA),
        lwd = c(2.5, 2.5, 2.5, 2.5),
        col = c("red", "blue", "orange", "black"),
        pch = c(1, 1, 1, 1),
        cex = .6
    )
    par(xpd = FALSE)

    if (val %in% mysum) {
        plot(sub1[c(2, 5)], col = "red", main = val, xlab = "position", ylab = "frequency", cex = .6, ylim = c(0, 100))
        mtext(fname, side = 1, line = 4, cex = .6)
    }
    if (val %in% indelsum) {
        points(subindel[c(2, 5)], col = "blue", main = val, xlab = "position", ylab = "frequency", cex = .6, ylim = c(0, 100))
    }
    if (val %in% svsum) {
        points(subsv[c(2, 5)], col = "orange", cex = .6, ylim = c(0, 100))
    }
    if (val %in% bpsum) {
        points(subbp[c(2, 5)], col = "black", cex = .6, ylim = c(0, 100))
    }
}
