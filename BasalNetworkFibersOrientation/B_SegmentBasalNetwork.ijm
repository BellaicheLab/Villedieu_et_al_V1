// SegmentBasalNetwork

/* Required architecture of the data
Folder1
	Image.tif (with Apical and Basal concatenated)
Folder2
	Image.tif (with Apical and Basal concatenated)
...

********* Run A_CorrectAverageIntensity.ijm before ***********
 */

//////////////////////////////////////////////////////////////////////////////////////
// Parameters ////////////////////////////////////////////////////////////////////////
// Parameters of the preprocessing filters
RollingBallRadius=3;
MedianRadius=3;
// Value for thresholding: the same for all conditions
ThresholdValue=27;
// Minimum area for filtering out too small particles
ParticleAreaMin=40;
// Maximum tolerated circularity for filtering out too roundish particles
ParticleCircularityMin=0.7;
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

// Batch mode
setBatchMode(true);


// For each subfolder
for (i=0; i<Folderlist.length; i++) { // for each pupa
	path=pathmaster+Folderlist[i];
	if (File.exists(path+"Basal.tif")) {
		// Opening the image of the basal network
		open(path+"Basal.tif");
		ID=getImageID();
		selectImage(ID);

		// Run filters to segment
		run("Subtract Background...", "rolling="+RollingBallRadius);
		run("Median...", "radius="+MedianRadius);

		// Threshold (the same threshold is applied to all the images)
		setThreshold(0,ThresholdValue);
 		run("Convert to Mask");
 		run("Select All");
		run("Invert");

		// Filter particles
		// Remove too small particles
		run("Analyze Particles...", "size=0-"+ParticleAreaMin+" add");
		nROIs=roiManager("count");
		roiManager("Select",Array.getSequence(nROIs));
		roiManager("Combine");
		roiManager("Add");
		roiManager("Select",nROIs);
		setBackgroundColor(0, 0, 0);
		run("Clear", "slice");
		roiManager("Reset");
		// Remove roundish remaining particles
		run("Analyze Particles...", "size=0-Infinity circularity="+ParticleCircularityMin+"-1.00 add");
		nROIs=roiManager("count");
		roiManager("Select",Array.getSequence(nROIs));
		roiManager("Combine");
		roiManager("Add");
		roiManager("Select",nROIs);
		setBackgroundColor(0, 0, 0);
		run("Clear", "slice");
		roiManager("Reset");

		// Skeletonization
		run("Select All");
		run("Skeletonize");

		// Saving skeletonized pic
		selectImage(ID);
		saveAs("tiff",path+"Skeleton");
		close();
		
	}
}