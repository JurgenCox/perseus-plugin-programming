args = commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
    stop("Should provide two arguments: paramFile inFile outFile", call. = FALSE)
}
paramFile <- args[1]
inFile <- args[2]
outFile <- args[3]
library(PerseusR)
parameters <- parseParameters(paramFile)
num_row <- intParamValue(parameters, 'Number of rows')
mdata <- read.perseus(inFile)
counts <- main(mdata)
mdata2 <- head(counts, n=num_row)
aCols <- head(annotCols(mdata), n=num_row)
mdata2 <- matrixData(main=mdata2, annotCols=aCols, annotRows=annotRows(mdata))
print(paste('writing to', outFile))
write.perseus(mdata2, outFile)