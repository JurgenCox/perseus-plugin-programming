using BaseLibS.Param;
using PerseusApi.Matrix;
using System.IO;
using PluginInterop;
using System.Text;
using PluginTutorial.Properties; // replace PluginHead3 to your project or solution name

namespace PluginTutorial
{
    public class Head : PluginInterop.Python.MatrixProcessing // if you use R, replace Python to R
    {
        //Sung-Huan
        public override string Heading => "Tutorial";
        public override string Name => "Header_with_resource";
        public override string Description => "extract the header of the matrix";
        public override bool IsActive => true;
        public override string Url => null;

        protected override bool TryGetCodeFile(Parameters param, out string codeFile)
        {
            byte[] code = (byte[])Resources.ResourceManager.GetObject("header_c_sharpPy"); // put the script to resources via edit properies file, and replace header_c_sharpPy to your script name
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
                new IntParam("Number of rows", 15)
                {
                    Help = "The number of rows for the header needs to be kept."
                }
            };
        }
    }
}
