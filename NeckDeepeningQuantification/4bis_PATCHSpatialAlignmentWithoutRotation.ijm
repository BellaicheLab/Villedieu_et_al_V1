// Spatial alignment in case rotation to realign midline was not applied before reslicing

// CODE ///////////////////////////////////////////////////////////////
// Making sure everything is closed
run("Clear Results"); 
roiManager("Reset");
run("Close All");

// Input folder selection
pathmaster = getDirectory("Directory where raw data is stored");
pathList=getFileList(pathmaster);

// Treating each animal at a time
for (i=0; i<pathList.length; i++) {
	// Not recalculating if already calculated
	if (File.exists(pathmaster + pathList[i] + "alignementWithoutRotation.csv")) {
	} else {
		
		// Detecting top projection
		IsthereaMaxFile=0;
		fileList=getFileList(pathmaster+ pathList[i]);
		for (j=0; j<fileList.length;j++){
			if (startsWith(fileList[j], "MAX_s")) {
				open(pathmaster+pathList[i]+fileList[j]);
				IDimage=getImageID();
				IsthereaMaxFile=1;
			}
		}

		// Only consider the folder if it contains a Max projection
		if (IsthereaMaxFile==1) {
		// Opening top projection
		selectImage(IDimage);
		getDimensions(width, height, channels, slices, frames);
		run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");

		// Enhancing contrast and select frame1
		selectImage(IDimage);
		setSlice(1);
		run("Enhance Contrast", "saturated=0.35");
		run("Enhance Contrast", "saturated=0.35");

		// Is the head on the right or on the left?
		Dialog.create("Head on the right or on the left?");
		Dialog.addString("Head on the left: press 1 // Head on the right: press 2.", "1");
		Dialog.show();
		LeftRight=Dialog.getString();

		// Do we see 1 or 2 macrochaetes?
		Dialog.create("1 or 2 landmark macrochaetes ?");
		Dialog.addString("1 or 2 ?", "2");
		Dialog.addString("if heminotum, press 1 for left and 2 for right ?", "1");
		Dialog.show();
		macronumber=Dialog.getString();
		macroleftright=Dialog.getString();

		// Manual clicking on macrochaetes (and midline if only 1 visible macrochaete)
		// Case of 1 visible macrochaete ///////////////////////////////////////////////////////////////
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
			// Resetting ROIManager and Results window
			roiManager("Reset");
			run("Clear Results");

			// Midline clicking
			waitForUser("Click on the midline");
			roiManager("Select", 0);
			run("Measure");
			Xmidline=getResult("X",0);
			Ymidline=getResult("Y",0);
			// Resetting ROIManager and Results window
			roiManager("Reset");
			run("Clear Results");			
		}
	
		// Case of 2 visible macrochaetes //////////////////////////////////////////////////////////////
		if (macronumber==2) {
			Xmidline=0;
			Ymidline=0;
			waitForUser("Click on 1) left macrochaete and 2) right macrochaete");
			roiManager("Select", 0);
			run("Measure");
			macroleftX=getResult("X",0);
			macroleftY=getResult("Y",0);
			roiManager("Select", 1);
			run("Measure");
			macrorightX=getResult("X",1);
			macrorightY=getResult("Y",1);
			// Resetting ROIManager and Results window
			roiManager("Reset");
			run("Clear Results");
		}

		// Output /////////////////////////////////////////////////////
		/* Output structure
		 Xmidline (0 if 2 visible macrochaetes)
		 Ymidline (0 if 2 visible macrochaetes)
		 macroleftX
		 macroleftY
		 macrorightX
		 macrorightY
		 LeftRight (1 head on the left // 2 head on the right)
		 */
		 
		// If head is on the right, substract field height to get reversed coordinates
		if (LeftRight==2){
			Ymidline=height-Ymidline;
			macroleftY=height-macroleftY;
			macrorightY=height-macrorightY;
		}

		// Saving
		print(Xmidline);
		print(Ymidline);
		print(macroleftX);
		print(macroleftY);
		print(macrorightX);
		print(macrorightY);
		print(LeftRight);
		selectWindow("Log");
		run("Text...", "save=" + pathmaster + pathList[i] + "alignementWithoutRotation.csv");

		// Reset everything
		selectWindow("Log");
		run("Close");
		selectImage(IDimage);
		close();
		roiManager("Reset");
		run("Clear Results");
		
		}
	}
}