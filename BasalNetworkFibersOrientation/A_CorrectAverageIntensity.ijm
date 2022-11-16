// Estimate exposure based on apical projection and apply it to the basal

/* Required architecture of the data
Folder1
	Image.tif (Concatenation of Frame1: Apical and Frame2: Basal)
Folder2
	Image.tif (Concatenation of Frame1: Apical and Frame2: Basal)
...
 */

//////////////////////////////////////////////////////////////////////////////////////
// Parameters ////////////////////////////////////////////////////////////////////////
// Average intensity value we want to reach in all apical views
ExposureStandard=150;
//////////////////////////////////////////////////////////////////////////////////////


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

		// Ask user to select apical thoracic region for measuring average intensity
		waitForUser("Select apical thoracic region");
		nROIs=roiManager("count");
		if(nROIs==0){
			roiManager("Add");
		}
		
		// Measure apical thoracic region intensity
		run("Set Measurements...", "mean redirect=None decimal=3");
		roiManager("Select",0);
		run("Measure");
		Intensity=getResult("Mean",0);
		run("Clear Results");
		CorrectionFactor=ExposureStandard/Intensity;

		// Duplicate basal and correct exposure
		selectImage(ID);
		setSlice(2);
		run("Select All");
		run("Duplicate...", "use");
		IDBasal=getImageID();
		selectImage(IDBasal);
		run("Select All");
		run("Multiply...", "value="+CorrectionFactor);

		// Save ROI
		roiManager("Save",path+"Apicalthorax.zip");
		
		// Save basal
		selectImage(IDBasal);
		saveAs("tiff",path+"Basal");

		// Close everything
		selectImage(IDBasal);
		close();
		selectImage(ID);
		close();
		roiManager("Reset");
	}
}