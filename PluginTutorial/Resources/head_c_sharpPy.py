import sys
from perseuspy import pd
from perseuspy.parameters import *
from perseuspy.io.perseus.matrix import *
_, paramfile, infile, outfile = sys.argv # read arguments from the command line
parameters = parse_parameters(paramfile) # parse the parameters file
df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
head = intParam(parameters, "Number of rows")
df_head = df.head(head)
df_head.to_perseus(outfile)# write pandas.DataFrame in Perseus txt format