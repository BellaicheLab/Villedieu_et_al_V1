// Collect basal leading edge tracking information for curvature calculation

/////////////////////////////////////////////////////////////////////////////////////////////
// To fill in ///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
// Name of reslice tif file
Name="SideView_";
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
path = getDirectory("Directory where animal subfolders are stored");

// Detecting .zip file in each subfolder
FolderList=getFileList(path);
for (folder=0;folder<FolderList.length;folder++) {

	// Making output folder
	newDir=path+FolderList[folder]+"TrackingBasal"+File.separator;
	File.makeDirectory(newDir);

	// Detecting and opening zip tracking
	FileList=getFileList(path+FolderList[folder]);
	for (file=0;file<FileList.length;file++){
		if (endsWith(FileList[file],'.zip')) {
			if (startsWith(FileList[file],"Basal_")) {
//waitForUser(FolderList[folder]);
				// Open tracking
				roiManager("open",path+FolderList[folder]+FileList[file]);
				nROIs=roiManager("count");
				// Detect name and open reslice
				NameEnd=substring(FileList[file],indexOf(FileList[file],"sal_")+4,lengthOf(FileList[file])-4);
				open(path+FolderList[folder]+Name+NameEnd+Extension);
				ID=getImageID();
				selectImage(ID);
				getDimensions(width, height, channels, slices, frames);
				// Saving number of timepoints
				print(nROIs);
				selectWindow("Log");
				run("Text...", "save=" + newDir + "LengthTracking.csv");
				selectWindow("Log");
				run("Close");
				// Saving image dimensions
				print(width);
				print(height);
				selectWindow("Log");
				run("Text...", "save=" + newDir + "ResliceDimension.csv");
				selectWindow("Log");
				run("Close");
				// For each timepoint, saving tracking X and Y
				for (r=0;r<nROIs;r++){
					t=r+1;
					roiManager("Select",r);
					Roi.getCoordinates(xpoints, ypoints);
					for (i=0;i<xpoints.length;i++){
						print(ypoints[i]);
					}
					selectWindow("Log");
					run("Text...", "save=" + newDir + "Y_t"+t+".csv");
					run("Close");
					for (i=0;i<xpoints.length;i++){
						print(xpoints[i]);
					}
					selectWindow("Log");
					run("Text...", "save=" + newDir + "X_t"+t+".csv");
					run("Close");
				}
	
				// Closing reslice
				selectImage(ID);
				close();
				// Reset roiManager
				roiManager("Reset");
			}
		}
	}
}