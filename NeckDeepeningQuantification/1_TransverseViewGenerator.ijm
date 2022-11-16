// Generating transverse (and sagittal) views of the neck leading edge

// Pre-requisite /////////////////////////////////////////////////////////////
// Assemble top projections as ["Max_s” + i + “.tif”]
// Track and save successive leading edge positions and save them as [“Leading-edge_s” + i + “.zip”] for each stage
// Place midline position and save it as [“Reslice_s” + i + “.roi”] for each stage
///////////////////////////////////////////////////////////////////////////


// To fill in ////////////////////////////////////////////////////////////////////////// 
// Name of the projection (should end with "_s"). Ex : DfdMbsRNAisqhRNAi_w2CSU-488_s
Name="DfdMbsRNAisqhRNAi_w2CSU-488_s";

// IDs of stages that have to be considered
stages=newArray(1,3,7,9,11,13,15,17,19,21);
////////////////////////////////////////////////////////////////////////////////////////

// Parameters (do not touch) ///////////////////////////////////////////////////////////
// Enlargement parameter (in pixels) for generating the transverse view
ParamEnlarge=30;
// Enlargement parameter (in pixels) for generating the sagittal view
ParamEnlarge2=10
///////////////////////////////////////////////////////////////////////////////////////



// CODE ///////////////////////////////////////////////////////////////
// Making everything is reset
run("Clear Results"); 
roiManager("Reset");
run("Close All");

// Input/ouput folders
path = getDirectory("Directory where raw data is stored");
newDir = getDirectory("Directory containing tracking .zip files");
setBatchMode(true);


// For each stage
for (j=0; j<stages.length; j++) {
	i=stages[j];

	// Open the ROI list containing neck leading edge trackings on top projections
	roiManager("Open",newDir+"s"+i+".zip");
	nROIs=roiManager("count");
	// Open the ROI corresponding to the midline position
	roiManager("Open",newDir+"Reslice_s"+i+".roi");
	
	// For each timepoint
	for (r=0;r<nROIs;r++){
		
		// Open the hyperstack 4 times (one for each output reslice)
		t=r+1;
		open(path+Name+i+"_t"+t+".TIF");
		ID=getImageID();
		selectImage(ID);
		getDimensions(width, height, channels, slices, frames);
		run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=0.322 pixel_height=0.322 voxel_depth=1");
		run("Select All");
		run("Duplicate...", "duplicate");
		ID2=getImageID();
		selectImage(ID);
		run("Select All");
		run("Duplicate...", "duplicate");
		ID3=getImageID();
		selectImage(ID);
		run("Select All");
		run("Duplicate...", "duplicate");
		ID4=getImageID();		

		// Calculate the rotation angle to apply to align data according to the midline 
		selectImage(ID);
		roiManager("Select",nROIs);
		run("Measure");
		anglerotation=getResult("Angle",0);
		run("Clear Results");
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Make reslice 1: sagittal midline reslice
		selectImage(ID);
		roiManager("Select",nROIs);
		run("Line to Area");
		run("Enlarge...", "enlarge="+ParamEnlarge2);
		run("Clear Outside", "stack");
		run("Select All");
		run("Rotate... ", "angle=" + anglerotation + " grid=1 interpolation=Bilinear enlarge stack");
		run("Select All");
		run("Reslice [/]...", "output=1.000 start=Top");
		IDsagittal=getImageID();
		selectImage(IDsagittal);
		run("Z Project...", "projection=[Max Intensity]");
		IDsagittalnew=getImageID();
		selectImage(IDsagittalnew);
		rename("Newsagittal");
		selectImage(IDsagittal);
		close();	
		selectImage(ID);
		close();
		
		// Concatenation
		if (r==0){
			IDConcatenatedSagittal=IDsagittalnew;
			selectImage(IDConcatenatedSagittal);
			rename("Sagittal");
		}
		if (r>0){
			run("Concatenate...", "  title=Sagittal2 image1=Sagittal image2=Newsagittal image3=[-- None --]");
			IDConcatenatedSagittal=getImageID();
			selectImage(IDConcatenatedSagittal);
			rename("Sagittal");
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Make reslice 2: transverse view of neck leading edge
		selectImage(ID2);
		roiManager("Select",r);
		run("Line to Area");
		run("Enlarge...", "enlarge="+ParamEnlarge);
		run("Clear Outside", "stack");
		run("Rotate 90 Degrees Right");
		run("Select All");
		run("Rotate... ", "angle=" + anglerotation + " grid=1 interpolation=Bilinear enlarge stack");
		run("Select All");
		run("Reslice [/]...", "output=1.000 start=Top");
		IDslice=getImageID();
		selectImage(IDslice);
		run("Z Project...", "projection=[Max Intensity]");
		IDsliceNew=getImageID();
		selectImage(IDsliceNew);
		rename("New");
		selectImage(IDslice);
		close();
		selectImage(ID2);
		close();
		// Concatenation
		if (r==0){
			IDConcatenatedSlice=IDsliceNew;
			selectImage(IDConcatenatedSlice);
			rename("Front");
		}
		if (r>0){
			run("Concatenate...", "  title=Front2 image1=Front image2=New image3=[-- None --]");
			IDConcatenatedSlice=getImageID();
			selectImage(IDConcatenatedSlice);
			rename("Front");
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Make reslice 3: transverse view of the whole head side
		// Head mask calculation
		selectImage(ID3);
		run("Duplicate...", " ");
		IDMask=getImageID();
		selectImage(IDMask);
		run("Select All");
		run("Clear", "slice");
		roiManager("Select",r);
		run("Fill", "slice");
		Roi.getCoordinates(xpoints, ypoints);
		makeLine(xpoints[0], 0, xpoints[0], ypoints[0]);
		run("Fill", "slice");
		roiIndex=lengthOf(xpoints)-1;
		makeLine(xpoints[roiIndex], ypoints[roiIndex], xpoints[roiIndex], height);
		run("Fill", "slice");
		setOption("BlackBackground", true);
		run("Select All");
		run("Make Binary");
		run("Dilate");
		run("Invert");
		doWand(1, height-1);
		roiManager("Add");
		doWand(width-1,height-1);
		roiManager("Add");

		selectImage(ID3);
		roiManager("Select",nROIs+1);
		run("Clear Outside", "stack");
		run("Rotate 90 Degrees Right");
		run("Select All");
		run("Rotate... ", "angle=" + anglerotation + " grid=1 interpolation=Bilinear enlarge stack");
		run("Select All");
		run("Reslice [/]...", "output=1.000 start=Top");
		IDproj=getImageID();
		selectImage(IDproj);
		run("Z Project...", "projection=[Max Intensity]");
		IDprojNew=getImageID();
		selectImage(IDprojNew);
		rename("New");
		selectImage(IDproj);
		close();
		selectImage(ID3);
		close();

		// Closing head mask
		selectImage(IDMask);
		close();
		
		// Concatenation
		if (r==0){
			IDConcatenatedProj=IDprojNew;
			selectImage(IDConcatenatedProj);
			rename("Proj");
		}
		if (r>0){
			run("Concatenate...", "  title=Proj2 image1=Proj image2=New image3=[-- None --]");
			IDConcatenatedProj=getImageID();
			selectImage(IDConcatenatedProj);
			rename("Proj");
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Make reslice 4: transverse view of the whole thorax side
		// Thorax mask calculation
		selectImage(ID4);
		roiManager("Select",nROIs+2);
		run("Clear Outside", "stack");
		run("Rotate 90 Degrees Right");
		run("Select All");
		run("Rotate... ", "angle=" + anglerotation + " grid=1 interpolation=Bilinear enlarge stack");
		run("Select All");
		run("Reslice [/]...", "output=1.000 start=Top");
		IDproj2=getImageID();
		selectImage(IDproj2);
		run("Z Project...", "projection=[Max Intensity]");
		IDproj2New=getImageID();
		selectImage(IDproj2New);
		rename("New");
		selectImage(IDproj2);
		close();
		selectImage(ID4);
		close();
		// Concatenation
		if (r==0){
			IDConcatenatedProj2=IDproj2New;
			selectImage(IDConcatenatedProj2);
			rename("ProjSecond");
		}
		if (r>0){
			run("Concatenate...", "  title=ProjSecond2 image1=ProjSecond image2=New image3=[-- None --]");
			IDConcatenatedProj2=getImageID();
			selectImage(IDConcatenatedProj2);
			rename("ProjSecond");
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		// Erase ROIs corresponding to projections
		roiManager("Select",nROIs+1);
		roiManager("Delete");
		roiManager("Select",nROIs+1);
		roiManager("Delete");
	}


	// Saving all reslices
	selectImage(IDConcatenatedSlice);
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	saveAs("tiff",newDir+"SideView_s"+i);
	selectImage(IDConcatenatedSlice);
	close();
	
	selectImage(IDConcatenatedSagittal);
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	saveAs("tiff",newDir+"Midline_s"+i);
	selectImage(IDConcatenatedSagittal);
	close();

	selectImage(IDConcatenatedProj);
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	saveAs("tiff",newDir+"Proj(left)_s"+i);
	selectImage(IDConcatenatedProj);
	close();	

	selectImage(IDConcatenatedProj2);
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	saveAs("tiff",newDir+"Proj(right)_s"+i);
	selectImage(IDConcatenatedProj2);
	close();		
	
	// Closing ROIManager
	roiManager("Reset");
}