args = commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
	stop("Do not provide additional arguments!", call.=FALSE)
}
inFile <- args[1]
outFile <- args[2]
library(PerseusR)
mdata <- read.perseus(inFile)
counts <- main(mdata)
mdata2 <- head(counts, n=15)
aCols <- head(annotCols(mdata), n=15)
mdata2 <- matrixData(main=mdata2, annotCols=aCols, annotRows=annotRows(mdata))
print(paste('writing to', outFile))
write.perseus(mdata2, outFile)