// SegmentApicalHeadThoraxBoundary
// Ask the user to drax apical head-thorax boundary as a spatial landmark
// Define head and thorax ROIs based on the apical head-thorax boundary

/* Required architecture of the data
Folder1
	Image.tif (with Apical and Basal concatenated)
Folder2
	Image.tif (with Apical and Basal concatenated)
...
 */

/////////////////////////////////////////////////////////////////////////////////////
// Paramaters ///////////////////////////////////////////////////////////////////////
Drift=124; // Corresponds to the height of the analyzed regions (in pixels)
// This height is the same for all the analyzed animals/conditions
/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
// Code /////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

// Folder selection
pathmaster=getDirectory("Choose directory containing all pupa folders");
Folderlist=getFileList(pathmaster);

// Making sure everything is closed
run("Clear Results"); 
roiManager("Reset");
run("Close All");
print("Hello!");
selectWindow("Log");
run("Close");

// For each subfolder
for (i=0; i<Folderlist.length; i++) { // for each pupa
	path=pathmaster+Folderlist[i];
	if (File.exists(path+"Image.tif")) {
		// Opening the image
		open(path+"Image.tif");
		ID=getImageID();
		selectImage(ID);
		setSlice(1);

		// Ask user to select apical head-thorax boundary
		waitForUser("Segment head-thorax boundary using a segmented line");
		nROIs=roiManager("count");
		if(nROIs==0){
			roiManager("Add");
		}

		// Determining the ROI of interest on the head and thorax sides
		roiManager("Select",0);
		run("Line to Area");
		run("Enlarge...", "enlarge="+Drift);
		roiManager("Add");
		roiManager("Select",1);
		DriftNeg=-Drift;
		roiManager("translate",0,DriftNeg);
		roiManager("Select",0);
		run("Line to Area");
		run("Enlarge...", "enlarge="+Drift);
		roiManager("Add");
		roiManager("Select",2);
		roiManager("translate",0,Drift);
		
		// Save ROI
		roiManager("Save",path+"HeadThoraxROIs.zip");

		// Close everything
		selectImage(ID);
		close();
		roiManager("Reset");
	}
}