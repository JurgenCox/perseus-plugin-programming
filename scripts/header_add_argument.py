import argparse
from perseuspy import pd

parser = argparse.ArgumentParser("Head processing")
parser.add_argument("input", help="path of the input file")
parser.add_argument("output", help="path of the output file")
parser.add_argument("--nrow", type=int, help="the number of row")

arg = parser.parse_args()

df = pd.read_perseus(arg.input)
df_head = df.head(arg.nrow)
df_head.to_perseus(arg.output)