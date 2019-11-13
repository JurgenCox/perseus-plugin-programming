# PluginTutorial

## Overview

We will develop our own simple plugin by modifying the most simple existing plugin (clone matrix).
In the end the plugin will allow you to extract a number of rows from the top of the matrix as specified
by a parameter.

Reading existing code and modifying it is the fastest way to learning plugin development.
This way we can not only understand how things work but also easily reuse existing functionality for our needs.

## Requirements

Download the latest version of [Visual Studio Community Edition](https://www.visualstudio.com/downloads/).
Select the `.Net Desktop Development` workflow in the installer to install everything required.

## Step by step C\# plugin

1. Go to [perseus-plugins](https://github.com/jurgencox/perseus-plugins) github repository. The code for the plugin API
(`PerseusApi`) and for a number of Perseus plugins (`PerseusPluginLib`) is hosted here.

2. Find the `CloneProcessing.cs` class which we will use as our template. Use the search or navigate to `/PerseusPluginLib/Basic`
and open [`CloneProcessing.cs`](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Basic/CloneProcessing.cs)

3. Open Visual Studio and create a new project of type `Class Library (.Net Framework)`
and name it `PluginTutorial`. Rename the default `Class1.cs` to
`HeadProcessing.cs` remove all existing code in the file and copy the code from
`CloneProcessing.cs` into it.  You will see lots of errors which we will fix
momentarily.  The errors are due to missing dependencies. You can see from the
`using` statements at the top of the file that we require the Perseus plugin
API.

4. To add the dependencies right-click on your `PluginTutorial` solution and 
choose `Manage NuGet Packages for Solution...`. In the `Browse` tab search for
`PerseusApi` and install it for `PluginTutorial`. `PerseusApi` and its
dependency `BaseLibS` will now be added to your project.

5. There are only a few things left to do before we can try our new plugin.
Correct the namespace to `namespace PluginTutorial` and the class to `class
PluginHead`.  Set the `DisplayImage => null` and adjust all other strings
in the class.  Now you can build the solution. Use the Windows File Explorer to
navigate to the `PluginTutorial/bin/Debug` folder and copy the
`PluginTutorial.dll` to the Perseus folder.  Start Perseus, generate some
random data and try your plugin.

6. Now we need to implement the actual functionality in the [`ProcessData(..)`]
method. We can look for inspiration in the [filter random
rows](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Filter/FilterRandomRows.cs)
processing. We can see a call to
[`PerseusPluginUtils.FilterRows(...)`](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Filter/FilterRandomRows.cs#L43)
which is turn uses
[`mdata.ExtractRows(rows)`](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Utils/PerseusPluginUtils.cs#L50).
We can utilize the same function to implement our plugin!

	```csharp
        int lines = 10;
	int[] remains = Enumerable.Range(0, lines).ToArray();
	mdata.ExtractRows(remains);
	```
	Make sure to build your solution and try out your new functional plugin!

7. Manually copying the DLL after each build is very annoying and reduces productivity. We can
use Visual Studio to automatically copy the DLL after each build and launch Perseus in debug
mode. Right click the `PluginTutorial` project in the Solution Explorer and select `Properties`.
In the `Build Event` tab we can edit the post-build event. Let's add a copy statement.

	```batch
	copy $(TargetDir)\PluginTutorial.dll C:\Path\To\Perseus\bin\PluginTutorial.dll
	copy $(TargetDir)\PluginTutorial.pdb C:\Path\To\Perseus\bin\PluginTutorial.pdb
	```

The `$(TargetDir)` macro always points to the output directory of the build.
Now switch to the `Debug` tab and select `Start external Program`. Browse for,
or enter the path to the `Perseus\bin\PerseusGui.exe`. Now hit the green Start
button.

8. As a last step we should add a parameter to let us choose how many rows we would like to keep. Again we take inspiration from the same existing filter random rows plugin.
In its `GetParameters(...)` function it's initializing a [`IntParam`](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Filter/FilterRandomRows.cs#L34).
To obtain its value it is extracting the parameter in the [`ProcessData`](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Filter/FilterRandomRows.cs#L39) function.
We can again utilize this in our plugin by creating our parameter in our `GetParameters` function:
	```csharp
	return new Parameters(new IntParam("Number of rows", 15));
	```
	And using it in the `ProcessData` function:

	```csharp
	int lines = param.GetParam<int>("Number of rows").Value;
	int[] remains = Enumerable.Range(0, lines).ToArray();
	mdata.ExtractRows(remains);
	```
	
	Build your solution another time and check to see that the parameters are handled correctly!

## Step by step for C\# with R or Python

1. We will use [`Head_with_py.cs`](https://github.com/JurgenCox/perseus-plugin-programming/blob/master/PluginTutorial/Head_with_py.cs) 
and [`Head_with_r.cs`](https://github.com/JurgenCox/perseus-plugin-programming/blob/master/PluginTutorial/Head_with_r.cs) as the examples.
All the necessary information and commands are all included in these scripts. You can copy and paste the code and modify it based on your need.

2. Change the project property to your own one:
    
	```csharp
    using PluginTutorial.Properties;
	```
	
	Please replace PluginTutorial to your project name

3. Change the class name and specifiy the type of scripts /- Python or R:
    
	```csharp
    public class HeadPy : PluginInterop.Python.MatrixProcessing
	```
	
	You just need to change `HeadPy` to your class name. Then change `PluginInterop.Python.MatrixProcessing` to `PluginInterop.R.MatrixProcessing` if the script that you want to integrated is written by R.

4. Add the Python or R scripts to the resources. Double click `Properties` which is listed under the Project /- `PluginTutorial` in our case.

5. Select `Resources`, and then click `Add Resource`. Navigate to your R or Python scripts and add them.

6. Connect the scripts in resources to C\# code:
    
	```csharp
        protected override bool TryGetCodeFile(Parameters param, out string codeFile)
        {
            byte[] code = (byte[])Resources.ResourceManager.GetObject("head_c_sharpPy");
            codeFile = Path.GetTempFileName();
            File.WriteAllText(codeFile, Encoding.UTF8.GetString(code));
            return true;
        }
	```
	
	You just need to change `head_c_sharpPy` to your R or Python scripts.

7. Create your parameter in the `SpecificParameters` function:
	
	```csharp
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
	```
    
	The if statement is for checking the required data is available or not. You don't need to change it.
	All of your parameters can be put into the block of `return new Parameter[]`.
	
8. Retrieve the parameters from C\# to Python or R.
    a. Python: the basic commands can be seen in [`perseuspy`](https://github.com/cox-labs/perseuspy). 
	Using [`head_c_sharpPy.py`](https://github.com/JurgenCox/perseus-plugin-programming/blob/master/PluginTutorial/Resources/head_c_sharpPy.py) as an example:
	
	```python
	import sys
    from perseuspy import pd
    from perseuspy.parameters import *
    from perseuspy.io.perseus.matrix import *
    _, paramfile, infile, outfile = sys.argv # read arguments from the command line (paramfile is the additional variable comparing to the basic command) 
    parameters = parse_parameters(paramfile) # parse the parameters file
    df = pd.read_perseus(infile) # read the input matrix into a pandas.DataFrame
    head = intParam(parameters, "Number of rows") # get the parameter from C\# code
    df_head = df.head(head) # main part for the data modification. You can add your own script from here.
    df_head.to_perseus(outfile)# write pandas.DataFrame in Perseus txt format
	```

    b. R: the basic commands can be seen in [`PerseusR`](https://github.com/cox-labs/PerseusR). 
	Using [`head_c_sharpR.R`](https://github.com/JurgenCox/perseus-plugin-programming/blob/master/PluginTutorial/Resources/head_c_sharpR.R) as an example:
	
	```R
	args = commandArgs(trailingOnly = TRUE) # Reading the command line arguments provided by Perseus and parsing the data.
    if (length(args) != 3) {
        stop("Should provide two arguments: paramFile inFile outFile", call. = FALSE)
    }
    paramFile <- args[1] # The varable for storing the argument from C\#
    inFile <- args[2]
    outFile <- args[3]
    library(PerseusR) # import perseusR
    parameters <- parseParameters(paramFile) # parse the parameters
    num_row <- intParamValue(parameters, 'Number of rows') # get the parameter
    mdata <- read.perseus(inFile) # read the input matrix into a pandas.DataFrame
    counts <- main(mdata) # get the main matrix of Perseus
    mdata2 <- head(counts, n=num_row) # main part for the data modification. You can add your own script from here. 
    aCols <- head(annotCols(mdata), n=num_row) # get the annotation columns of main matrix and reduce to the amount to the assigned number of rows
    mdata2 <- matrixData(main=mdata2, annotCols=aCols, annotRows=annotRows(mdata)) # update the matrix
    print(paste('writing to', outFile)) # print to output file
    write.perseus(mdata2, outFile) # Write the results to the expected locations in the Perseus formats.
	```
9. Build your solution another time and check to see that the parameters are handled correctly!
	
## Next steps

### Error handling
Error handling can be implemented via the `ProcessInfo` object passed to both the `GetParameters` and the `ProcessData` functions.
[Here](https://github.com/JurgenCox/perseus-plugins/blob/master/PerseusPluginLib/Basic/DeHyphenateIds.cs#L32-L36) for example it is used to verify
that a parameter was assigned a valid value.
