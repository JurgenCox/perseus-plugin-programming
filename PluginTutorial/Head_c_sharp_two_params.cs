using System.Linq;
using BaseLibS.Graph;
using BaseLibS.Param;
using PerseusApi.Document;
using PerseusApi.Generic;
using PerseusApi.Matrix;

namespace PluginTutorial
{
	public class PluginHeadTwoParams : IMatrixProcessing
	{
        public bool HasButton => false;
		public string Description => "extract the header and columns of the matrix.";
		public string HelpOutput => "extract the header and columns of the matrix.";
		public string[] HelpSupplTables => new string[0];
		public int NumSupplTables => 0;
		public string Name => "Head CS with two parameters";
		public string Heading => "Tutorial";
		public float DisplayRank => 6;
		public string[] HelpDocuments => new string[0];
		public int NumDocuments => 0;
		public string Url => null;
		public Bitmap2 DisplayImage => null;
		public bool IsActive => true;

		public int GetMaxThreads(Parameters parameters)
		{
			return 1;
		}

		public void ProcessData(IMatrixData mdata, Parameters param, ref IMatrixData[] supplTables,
			ref IDocumentData[] documents, ProcessInfo processInfo)
		{
			int lines = param.GetParam<int>("Number of rows").Value;
			int[] remains = Enumerable.Range(0, lines).ToArray();
			mdata.ExtractRows(remains);
			int col = param.GetParam<int>("Number of columns").Value;
			int[] remainCols = Enumerable.Range(0, col).ToArray();
			mdata.ExtractColumns(remainCols);

		}

		public Parameters GetParameters(IMatrixData mdata, ref string errorString)
		{
			return new Parameters(
				new IntParam("Number of rows", 15)
			    {
				    Help = "The number of rows for the header needs to be kept."
			    }, new IntParam("Number of columns", 2)
				{
					Help = "The number of columns will be kept."
				});
		}
	}
}