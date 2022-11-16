// Collect rotation angle on top projections

/////////////////////////////////////////////////////////////////////////////////////////////
// To fill in ///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
// Name of top projection tif file
Name="MAX_s";
// Extension of reslice tif file
Extension=".tif";
/////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////
// CODE /////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

// Closing everything
roiManager("Reset");
run("Clear Results"); 
roiManager("Reset");
run("Close All");
print("Hello =)");
selectWindow("Log");
run("Close");

// Batch mode
setBatchMode(true);

// Defining path
path = getDirectory("Directory where tracking and reslices are stored");

// Detecting .zip file in each subfolder
FolderList=getFileList(path);
for (folder=0;folder<FolderList.length;folder++) {

	// Detecting whether there is a top projection file and opening it
	FileList=getFileList(path+FolderList[folder]);
	for (file=0;file<FileList.length;file++){
		if (startsWith(FileList[file],Name)) {
			// Open top projection
			open(path+FolderList[folder]+FileList[file]);
			ID=getImageID();
			selectImage(ID);
			
			// Detect number of the top projection
			ResliceNumber=substring(FileList[file],indexOf(FileList[file],"MAX_s")+5,indexOf(FileList[file],".tif"));
			if (lengthOf(ResliceNumber)>2){
				ResliceNumber=substring(FileList[file],indexOf(FileList[file],"MAX_s")+5,indexOf(FileList[file],"MAX_s")+6);
			}

			// Open midline detection roi
			roiManager("Open",path+FolderList[folder]+"Reslice_s"+ResliceNumber+".roi");
			selectImage(ID);
			roiManager("Select",0);

			// Measure angle
			run("Measure");
			Angle=getResult("Angle",0);

			// Close image
			selectImage(ID);
			close();

			// Reset results and ROIManager
			roiManager("Reset");
			run("Clear Results"); 

			// Print results
			print(Angle);
			selectWindow("Log");
			run("Text...", "save="+path+FolderList[folder]+"AngleRotation.csv");
			selectWindow("Log");
			run("Close");
		}
	}
}