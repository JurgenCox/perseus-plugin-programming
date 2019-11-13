import sys
import os
import umap
import perseuspy
import numpy
from perseuspy import pd
from perseuspy.parameters import *
from perseuspy.io.perseus.matrix import *
_, paramfile, infile, outfile = sys.argv # read arguments from the command line
parameters = parse_parameters(paramfile) # parse the parameters file
df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
n_neighbor = intParam(parameters, "Number of neighbors")
n_component = intParam(parameters, "Number of components")
seed = intParam(parameters, "Random state")
m_dist = doubleParam(parameters, "Minimum distance")
metric = singleChoiceParam(parameters, "Metric")
annotations = read_annotations(infile)
if len(annotations) < 2:
    sys.exit("The data needs to be grouped")
main_index = []
i = 0
for c_type in annotations['Type']:
    if c_type == 'E':
        main_index.append(i)
    i = i + 1
newDF1 = df.ix[:, main_index[0]:main_index[-1]+1]
newDF1 = newDF1.T
embedding = umap.UMAP(n_neighbors=n_neighbor,n_components=n_component,
                      metric=metric,random_state=seed, min_dist=m_dist).fit_transform(newDF1)
new_annotations = {}
check_c = {}
c_num = 1
for k, v in annotations.items():
    if "C:" in k:
        col_n = k.replace("C:", "")
        new_annotations[col_n] = v
annotation_df = pd.DataFrame.from_dict(new_annotations)
col_names = []
for i in range(0, n_component):
    col_names.append("Component "+ str(i+1))
newDF2 = pd.DataFrame(data=embedding, columns=col_names)
newDF2 = pd.concat([newDF2.reset_index(drop=True), annotation_df], axis=1)
newDF2 .to_perseus(outfile) # write pandas.DataFrame in Perseus txt format