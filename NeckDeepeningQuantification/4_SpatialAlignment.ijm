// Spatial alignment using top projection

// CODE ///////////////////////////////////////////////////////////////
// Making sure everything is reset
run("Clear Results"); 
roiManager("Reset");
run("Close All");

// Input master folder selection
pathmaster = getDirectory("Directory where raw data is stored");
pathList=getFileList(pathmaster);

// For each animal
for (i=0; i<pathList.length; i++) {
	// Don't recalculate if already calculated
	if (File.exists(pathmaster + pathList[i] + "alignement.csv")) {
	} else {
		
		// Detection of the name of the leading edge transverse view
		fileList=getFileList(pathmaster+ pathList[i]);
		for (j=0; j<fileList.length;j++){
			if (startsWith(fileList[j], "MAX_s")) {
				ID=substring( fileList[j] , indexOf(fileList[j], "Sideview_s")+6 , lengthOf(fileList[j])-4 );
			}
		}

		// Opening top projection
		open(pathmaster+pathList[i]+"MAX_s"+ID+".tif");
		IDimage=getImageID();
		selectImage(IDimage);
		getDimensions(width, height, channels, slices, frames);
		run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");

		// Calculation of midline angle
		roiManager("open",pathmaster+pathList[i]+"Reslice_s"+ID+".roi");
		run("Set Measurements...", "  redirect=None decimal=3");
		roiManager("Select",0);
		run("Measure");
		angle=getResult("Angle",0);
		run("Clear Results");

		// Identifying the intersection between midline and Leadingedge(t0)
		roiManager("open",pathmaster+pathList[i]+"s"+ID+".zip");
		selectImage(IDimage);
		run("Select All");
		run("Duplicate...", "use");
		IDMask=getImageID();
		run("Select All");
		setBackgroundColor(0, 0, 0);
		run("Clear", "slice");
		roiManager("Select", 0);
		run("Line to Area");
		run("Enlarge...", "enlarge=1");
		roiManager("Add");
		roiManager("Select", 1);
		run("Line to Area");
		run("Enlarge...", "enlarge=1");
		roiManager("Add");
		nROIs=roiManager("count");
		a=nROIs-2;
		b=nROIs-1;
		roiManager("Select",newArray(a,b));
		roiManager("AND");
		roiManager("Add");
		roiManager("Select",nROIs);
		roiManager("Fill");
		selectImage(IDMask);
		run("Select All");
		run("Rotate... ", "angle=" + angle + " grid=1 interpolation=Bilinear enlarge stack");
		run("Make Binary");
		run("Analyze Particles...", "add");
		roiManager("Select",nROIs+1);
		run("Set Measurements...", "centroid redirect=None decimal=3");
		run("Measure");
		Xmidline=getResult("X",0);
		Ymidline=getResult("Y",0);
		run("Clear Results");
		selectImage(IDMask);
		close();
		roiManager("Reset");
				
		// Image rotation
		selectImage(IDimage);
		run("Select All");
		run("Rotate... ", "angle=" + angle + " grid=1 interpolation=Bilinear enlarge stack");

		// Landmark macrochaetes detection
		selectImage(IDimage);
		setSlice(1);
		run("Enhance Contrast", "saturated=0.35");
		run("Enhance Contrast", "saturated=0.35");
		
		Dialog.create("1 or 2 landmark macrocheates ?");
		Dialog.addString("1 or 2 ?", "2");
		Dialog.addString("if heminotum, press 1 for left and 2 for right ?", "1");
		Dialog.show();
		macronumber=Dialog.getString();
		macroleftright=Dialog.getString();

		// If only 1 landmark macrochaete is visible
		if (macronumber==1) {
			waitForUser("Click the landmark macrochaete");
			if (macroleftright==1){
				roiManager("Select", 0);
				run("Measure");
				macroleftX=getResult("X",0);
				macroleftY=getResult("Y",0);
				macrorightX=0;
				macrorightY=0;
			}
			if (macroleftright==2){
				macroleftX=0;
				macroleftY=0;
				roiManager("Select", 0);
				run("Measure");
				macrorightX=getResult("X",0);
				macrorightY=getResult("Y",0);						
			}
			
			// Resetting ROIManager and Results
			roiManager("Reset");
			run("Clear Results");
		}
	
		// If only the 2 landmark macrochaetes are visible
		if (macronumber==2) {
			waitForUser("Click on 1) left macrochaete and 2) right macrochaete");
			roiManager("Select", 0);
			run("Measure");
			macroleftX=getResult("X",0);
			macroleftY=getResult("Y",0);
			roiManager("Select", 1);
			run("Measure");
			macrorightX=getResult("X",1);
			macrorightY=getResult("Y",1);
			// On efface le ROIManager et la fenêtre Results
			roiManager("Reset");
			run("Clear Results");
		}

		// Saving
		print(Xmidline);
		print(Ymidline);
		print(macroleftX);
		print(macroleftY);
		print(macrorightX);
		print(macrorightY);
		selectWindow("Log");
		run("Text...", "save=" + pathmaster + pathList[i] + "alignement.csv");

		// Reset
		selectWindow("Log");
		run("Close");
		selectImage(IDimage);
		close();
		roiManager("Reset");
		run("Clear Results");
	}
}