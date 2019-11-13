args = commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
    stop("Should provide two arguments: paramFile inFile outFile", call. = FALSE)
}
paramFile <- args[1]
inFile <- args[2]
outFile <- args[3]
library(PerseusR)
is.installed <- function(mypkg) is.element(mypkg, installed.packages()[, 1])
if (!is.installed('umap')) {
    BiocManager::install("umap")
}
suppressMessages(library(umap))
parameters <- parseParameters(paramFile)
mdata <- read.perseus(inFile)
if (!length(annotRows(mdata))) {
    stop("The data needs to be grouped", call. = FALSE)
}
counts <- main(mdata)
counts <- as.data.frame(counts)
if (any(is.na(counts))) {
    stop("The matrix contains NAs.", call. = FALSE)
}
n_neighbor <- intParamValue(parameters, "Number of neighbors")
n_component <- intParamValue(parameters, "Number of components")
seed <- intParamValue(parameters, "Random state")
metric <- singleChoiceParamValue(parameters, "Metric")
m_dist <- intParamValue(parameters, "Minimum distance")
t_counts <- t(counts)
custom.config = umap.defaults
custom.config$metric = metric
custom.config$n_neighbors = n_neighbor
custom.config$n_components = n_component
custom.config$random_state = seed
custom.config$min_dist = m_dist
umap_out <- umap(t_counts, config = custom.config)
results <- as.data.frame(umap_out$layout)
layoutNames = c()
for (i in seq(1, n_component)) {
    layoutNames[i] <- paste(c("Component ", i), collapse = " ")
}
colnames(results) <- layoutNames
groupNames = data.frame(x = rownames(results))
groupNames = cbind(groupNames, annotRows(mdata))
colnames(groupNames) = append(colnames(annotRows(mdata)), list(x = 'Column names'), 0)
outdata <- matrixData(main = results, annotCols = groupNames)
print(paste('writing to', outFile))
write.perseus(outdata, outFile)