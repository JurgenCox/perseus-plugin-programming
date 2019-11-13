import sys
from perseuspy import pd
from perseuspy.parameters import *
_, infile, outfile = sys.argv # read arguments from the command line
df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
df2 = df.head(15) # keep only the first 15 rows of the table
df2.to_perseus(outfile) # write pandas.DataFrame in Perseus txt format