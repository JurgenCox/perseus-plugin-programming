# Parsing of arguments
argv <- commandArgs(trailingOnly=TRUE)

library(argparser)

p <- arg_parser(description = 'Parse arguments from Perseus')
p <- add_argument(p, '-name1', default='Ratio.H.L.count.(.*)', help='Name pattern for first quality column')
p <- add_argument(p, '-name2', default='Ratio.H.L.variability.....(.*)', help='Name pattern for second quality column')
p <- add_argument(p, '-value1', default=2, help='Minimum value for first quality column')
p <- add_argument(p, '-value2', default=30, help='Minimum value for second quality column')
p <- add_argument(p, '-mode', default='border', help='Mode of combining the the two cutoffs')
p <- add_argument(p, 'infile', help='Provided by Perseus')
p <- add_argument(p, 'outfile', help='Provided by Perseus')

argp <- parse_args(p, argv)

# Get Input from Perseus
library(PerseusR)
data_perseus <- read.perseus(argp$infile)

data <- main(data_perseus)

qual <- annotCols(data_perseus)

cols1 <- grep(argp$name1, names(qual), value=TRUE)
namevals1 <- gsub(argp$name1, '\\1', cols1)
cols2 <- grep(argp$name2, names(qual), value=TRUE)
namevals2 <- gsub(argp$name2, '\\1', cols2)
if (length(namevals1) != sum(namevals1 == namevals2)) stop('Names of quality columns do not match')
for (i in 1:length(namevals1)) {
  if (grep(namevals1[i], names(data)) != i) stop('No matching main column found')
}

data_f <- data
if (argp$mode == 'border') {
  data_f[qual[,cols1] < argp$value1] <- NA
  data_f[qual[,cols1] == argp$value1 & qual[,cols2] > argp$value2] <- NA
} else if (argp$mode == 'or') {
  data_f[qual[,cols1] < argp$value1 | qual[,cols2] > argp$value2] <- NA
}

main(data_perseus) <- data_f

write.perseus(data_perseus, argp$outfile)