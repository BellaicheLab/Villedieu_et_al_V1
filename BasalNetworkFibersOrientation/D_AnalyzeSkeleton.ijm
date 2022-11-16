// Analyze medio-lateral alignment of segmented basal fibers

/* 
Required architecture of the data
Folder1
	Image.tif (with Apical and Basal concatenated)
Folder2
	Image.tif (with Apical and Basal concatenated)
...

****** Run A_CorrectAverageIntensity.ijm before ********
******* Run B_SegmentBasalNetwork.ijm before *********
******* C_SegmentApicalHeadThoraxBoundary.ijm *******
 
 */

/////////////////////////////////////////////////////////////////////////////////////
// Parameters ///////////////////////////////////////////////////////////////////////
// Fibers that are too small (length<MinJunctionLength, in pixels) are not considered
MinJunctionLength=5;
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

// Batch mode
setBatchMode(true);


// For each subfolder
for (i=0; i<Folderlist.length; i++) { // for each pupa
	path=pathmaster+Folderlist[i];
	if (File.exists(path+"Skeleton.tif")) {
		// Opening the image of the basal network
		open(path+"Skeleton.tif");
		ID=getImageID();
		selectImage(ID);

		// Run skeleton analysis
		run("Analyze Skeleton (2D/3D)", "prune=none display");
		run("Clear Results");
		
		// Isolate junctions
		selectWindow("Tagged skeleton");
		run("RGB Color");
		run("Split Channels");
		selectWindow("Tagged skeleton (green)");
		ID2=getImageID();
		selectImage(ID2);
		setThreshold(12,255);

		// Measure Angles and lenght of each fiber of head and thorax regions
		
		// Head side ******************************************************
		// Duplicate image for head measurement
		selectImage(ID2);
		run("Select All");
		run("Duplicate...", " ");
		IDhead=getImageID();
		// Binarize and remove signal out of the region of interest
		selectImage(IDhead);
		setThreshold(12,255);
		roiManager("Open",path+"HeadThoraxROIs.zip");
		roiManager("Select",1);
		run("Clear Outside");
		roiManager("Reset");
		// Analyze Angle and Length of the remaining junctions
		run("Analyze Particles...", "size="+MinJunctionLength+"-Infinity circularity=0-1.00 add");
		nROIs=roiManager("Count");
		Angles=newArray(nROIs);
		Lengths=newArray(nROIs);
		run("Clear Results");
		run("Set Measurements...", "bounding fit redirect=None decimal=3");
		selectImage(IDhead);
		for(r=0;r<nROIs;r++){
			roiManager("Select",r);
			run("Measure");
			MLWidth=getResult("Width",0);
			Height=getResult("Height",0);
			temp=Height*Height+MLWidth*MLWidth;
			Length=sqrt(temp); // The length of the skeleton is approximated by the length of the chord
			Lengths[r]=Length;
			Angle=getResult("Angle",0);
			Angles[r]=Angle;
			run("Clear Results");
		}
		// Clear roiManager
		roiManager("Reset");
		// Close image
		selectImage(IDhead);
		close();
		
		// Save values
		for(r=0;r<nROIs;r++){
			print(Lengths[r]);
		}
		selectWindow("Log");
		run("Text...", "save="+path+"LengthsHead.csv");
		selectWindow("Log");
		run("Close");
		
		for(r=0;r<nROIs;r++){
			print(Angles[r]);
		}
		selectWindow("Log");
		run("Text...", "save="+path+"AnglesHead.csv");
		selectWindow("Log");
		run("Close");
		
		// Thorax side ******************************************************
		// Duplicate image for head measurement
		selectImage(ID2);
		run("Select All");
		run("Duplicate...", " ");
		IDthorax=getImageID();
		// Binarize and remove signal out of the region of interest
		selectImage(IDthorax);
		setThreshold(12,255);
		roiManager("Open",path+"HeadThoraxROIs.zip");
		roiManager("Select",2);
		run("Clear Outside");
		roiManager("Reset");
		
		// Analyze Angle and Length  of the remaining junctions
		run("Analyze Particles...", "size="+MinJunctionLength+"-Infinity circularity=0-1.00 add");
		nROIs=roiManager("Count");
		Angles=newArray(nROIs);
		Lengths=newArray(nROIs);
		run("Clear Results");
		run("Set Measurements...", "bounding fit redirect=None decimal=3");
		selectImage(IDthorax);
		for(r=0;r<nROIs;r++){
			roiManager("Select",r);
			run("Measure");
			MLWidth=getResult("Width",0);
			Height=getResult("Height",0);
			temp=Height*Height+MLWidth*MLWidth;
			Length=sqrt(temp); // The length of the skeleton is approximated by the length of the chord
			Lengths[r]=Length;
			Angle=getResult("Angle",0);
			Angles[r]=Angle;
			run("Clear Results");
		}
		// Clear roiManager
		roiManager("Reset");
		// Close image
		selectImage(IDthorax);
		close();
		
		// Save values
		for(r=0;r<nROIs;r++){
			print(Lengths[r]);
		}
		selectWindow("Log");
		run("Text...", "save="+path+"LengthsThorax.csv");
		selectWindow("Log");
		run("Close");
		
		for(r=0;r<nROIs;r++){
			print(Angles[r]);
		}
		selectWindow("Log");
		run("Text...", "save="+path+"AnglesThorax.csv");
		selectWindow("Log");
		run("Close");

		
		// Generate a color coded map *****************************************************
		// Generate a black map
		selectImage(ID2);
		run("Select All");
		run("Duplicate...", " ");
		ID3=getImageID();
		run("Select All");
		run("Clear", "slice");
		// Measure medio-lateral alignment of each junction
		selectImage(ID2);
		run("Analyze Particles...", "size="+MinJunctionLength+"-Infinity circularity=0-1.00 add");
		// For each junction measure length and horizontal width, and color code it on the black map
		nROIs=roiManager("Count");
		run("Clear Results");
		run("Set Measurements...", "bounding fit redirect=None decimal=3");
		selectImage(ID3);
		for(r=0;r<nROIs;r++){
			roiManager("Select",r);
			run("Measure");
			Angle=getResult("Angle",0);
			if (Angle>90){
				Angle=180-Angle;
			}
			ScoreML=255-255*Angle/90;
			setForegroundColor(ScoreML, ScoreML, ScoreML);
			roiManager("Select", r);
			run("Enlarge...", "enlarge=3");
			run("Fill", "slice");
			run("Clear Results");
		}
		
		// Saving color coded map
		selectImage(ID3);
		run("Fire");
		saveAs("tiff",path+"AngleMap");

		// Close all images
		run("Close All");
		
		// Clear everything
		roiManager("Reset");
		run("Clear Results");		
		
	}
}