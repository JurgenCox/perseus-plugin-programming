using BaseLibS.Param;
using PerseusApi.Matrix;
using System.IO;
using PluginInterop;
using System.Text;
using PluginTutorial.Properties; // replace PluginTutorial to your project or solution name

namespace PluginTutorial
{
    public class UmapPy : PluginInterop.Python.MatrixProcessing
    {
        public override string Heading => "Tutorial";
        public override string Name => "Umap analysis with Python";
        public override string Description => "Applying Umap to cluster the data";
        public override bool IsActive => true;
        public override string Url => null;

        protected override bool TryGetCodeFile(Parameters param, out string codeFile)
        {
            byte[] code = (byte[])Resources.ResourceManager.GetObject("Umap_Py");
            codeFile = Path.GetTempFileName();
            File.WriteAllText(codeFile, Encoding.UTF8.GetString(code));
            return true;
        }

        protected override string GetCommandLineArguments(Parameters param)
        {
            var tempFile = Path.GetTempFileName();
            param.ToFile(tempFile);
            return tempFile;
        }

        protected override Parameter[] SpecificParameters(IMatrixData mdata, ref string errString)
        {

            if (mdata.ColumnCount < 3)
            {
                errString = "Please add at least 3 main data columns to the matrix.";
                return null;
            }
            return new Parameter[]
            {
                new IntParam("Number of neighbors", 15)
                {
                    Help = "The number of neighbors."
                },
                new IntParam("Number of components", 2)
                {
                    Help = "The number of components."
                },
                new IntParam("Random state", 1)
                {
                    Help = "Set seed for reproducibility."
                },
                new DoubleParam("Minimum distance", 0.1)
                {
                    Help = "Set minimum distance between the data point."
                },
                new SingleChoiceParam("Metric")
                {
                    Values= new[] { "euclidean", "manhattan", "cosine", "pearson", "pearson2"},
                    Help = "The method of metric for doing clustering."
                }
            };
        }
    }
}
