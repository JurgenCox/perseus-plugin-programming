args = commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
	stop("Do not provide additional arguments!", call.=FALSE)
}
num <- as.integer(args[1])
inFile <- args[2]
outFile <- args[3]
library(PerseusR)
mdata <- read.perseus(inFile)
counts <- main(mdata)
mdata2 <- head(counts, n=num)
aCols <- head(annotCols(mdata), n=num)
mdata2 <- matrixData(main=mdata2, annotCols=aCols, annotRows=annotRows(mdata))
print(paste('writing to', outFile))
write.perseus(mdata2, outFile)