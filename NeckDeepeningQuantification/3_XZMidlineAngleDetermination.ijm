// Calculate midline angle in (x,z) plane and save in CenterCalculation.csv

// CODE ///////////////////////////////////////////////////////////////
// Making sure everything is closed
print("Hello!");
selectWindow("Log");
run("Close");
run("Clear Results"); 
roiManager("Reset");
run("Close All");

// Chosing master folder
pathmaster = getDirectory("Directory where subfolders are stored");
pathList=getFileList(pathmaster);

// For each subfolder
for (i=0; i<pathList.length; i++) {
	// Do not recalculate if CenterCalculation.csv is already determined
	if (File.exists(pathmaster + pathList[i] + "CenterCalculation.csv")) {
	} else {
			
		// ID detection
		fileList=getFileList(pathmaster+ pathList[i]);
		for (j=0; j<fileList.length;j++){
			if (startsWith(fileList[j], "MAX_s")) {
				StageID=substring( fileList[j] , indexOf(fileList[j], "Proj(left)_s")+6 , lengthOf(fileList[j])-4);
			}
		}

		// Estimating invagination angle *************************************************************************************
		// Opening en-face projection
		open(pathmaster+pathList[i]+"Proj(left)_s"+StageID+".tif");
		ID=getImageID();
		selectImage(ID);
		getDimensions(width, height, channels, slices, frames);
		run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");

		// Estimating angle alpha
		waitForUser("Draw angle from top to bottom");
		roiManager("Add");
		roiManager("Select",0);
		run("Measure");
		alpha=getResult("Angle",0);
		Correctedalpha=90+alpha;
		run("Clear Results");
		roiManager("Reset");

		// Resetting everything
		selectImage(ID);
		close();
		run("Clear Results");
		roiManager("Reset");

		// Saving values used for center calculation
		print("0");
		print("0");
		print(Correctedalpha);
		print("0");
		selectWindow("Log");
		run("Text...", "save=" + pathmaster + pathList[i] + "CenterCalculation.csv");
		run("Close");
	}
}
