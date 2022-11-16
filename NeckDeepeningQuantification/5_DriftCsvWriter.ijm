// Drift calculation after manual tracking for neck leading edge analysis

/*
// Prerequisite
Manually track one fixed point and save the data as Drift.zip.

If two succesive points need to be tracked, save the tracks as Drift1.zip and Drift2.zip
If 3 successive points need to be tracked, save the tracks as Drift1.zip, Drift2.zip and Drift3.zip
The last timepoint of Drift1.zip need to be the same as the first timepoint of Drift2.zip
*/

// Code /////////////////////////////////////////////////////////////////////////////////////////////////
// Get paths and subfolder list
Path=getDirectory("Choose a Directory"); 
SubFolderList=getFileList(Path); 
setBatchMode(true); 

// Making sure everything is reset
roiManager("reset");
run("Close All");
print("Hello");
selectWindow("Log");
run("Close");

// Processing each subfolder
for (i=0; i<SubFolderList.length; i++) { 
		// Case of one single tracking named Drift.zip ////////////////////////////////////////////////////////////////////////////////////
        if(File.exists(Path+SubFolderList[i]+"Drift.zip")) {
        	// Opening Proj(left)_s image
        	FileList=getFileList(Path+SubFolderList[i]);
        	for (j=0; j<FileList.length; j++) {
        		if(startsWith(FileList[j],"Proj(left)_s")) { 
					open(Path+SubFolderList[i]+FileList[j]); 
        		}
        	}
			ID=getImageID();
			selectImage(ID);
			getDimensions(width, height, channels, slices, frames);
			run("Properties...", "channels=1 slices=" + slices + " frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1 frame=[0 sec] origin=0,0");

			// Opening Drift tracking
			roiManager("Open",Path+SubFolderList[i]+"Drift.zip");
			nROIs=roiManager("count");

			// Initializing Drift vectors
			DriftX=newArray(nROIs);
			DriftY=newArray(nROIs);
			
			// Measuring positions for each time
			run("Set Measurements...", "stack redirect=None decimal=3");
			roiManager("Select",0);
			run("Measure");
			PosXInit=getResult("X",0);
			PosYInit=getResult("Y",0);
			DriftX[0]=0;
			DriftY[0]=0;
			run("Clear Results");
			for (r=1;r<nROIs;r++){
				roiManager("Select",r);
				run("Measure");
				DriftX[r]=getResult("X",0)-PosXInit;
				DriftY[r]=getResult("Y",0)-PosYInit;
				run("Clear Results");
			}

			// Saving DriftX
			for (r=0;r<nROIs;r++){
				print(DriftX[r]);
			}
			selectWindow("Log");
			run("Text...", "save="+Path+SubFolderList[i]+"DriftX.csv");
			run("Close");
			// Saving DriftY
			for (r=0;r<nROIs;r++){
				print(DriftY[r]);
			}
			selectWindow("Log");
			run("Text...", "save="+Path+SubFolderList[i]+"DriftY.csv");
			run("Close");					

			// Closing image
			selectImage(ID);
			close();
			// Resetting ROIManager
			roiManager("reset");
			
        } else {


			// Case of 3 tracking named Drift1.zip, Drift2 and Drift3.zip //////////////////////////////////////////////////
			if(File.exists(Path+SubFolderList[i]+"Drift3.zip")) {
				// Opening Proj(left)_s image
		        FileList=getFileList(Path+SubFolderList[i]);
		       	for (j=0; j<FileList.length; j++) {
		        if(startsWith(FileList[j],"Proj(left)_s")) { 
							open(Path+SubFolderList[i]+FileList[j]); 
		        	}
		        }
				ID=getImageID();
				selectImage(ID);
				getDimensions(width, height, channels, slices, frames);
				run("Properties...", "channels=1 slices=" + slices + " frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1 frame=[0 sec] origin=0,0");
							
				// Opening Drift1 tracking
				roiManager("Open",Path+SubFolderList[i]+"Drift1.zip");
				nROIs=roiManager("count");
				// Initializing Drift1 vectors
				DriftX1=newArray(nROIs);
				DriftY1=newArray(nROIs);
				// Measuring positions for each time of Drift1
				run("Set Measurements...", "stack redirect=None decimal=3");
				roiManager("Select",0);
				run("Measure");
				PosXInit=getResult("X",0);
				PosYInit=getResult("Y",0);
				DriftX1[0]=0;
				DriftY1[0]=0;
				run("Clear Results");
				for (r=1;r<nROIs;r++){
					roiManager("Select",r);
					run("Measure");
					DriftX1[r]=getResult("X",0)-PosXInit;
					DriftY1[r]=getResult("Y",0)-PosYInit;
					run("Clear Results");
				}
				// Resetting ROIManager
				roiManager("reset");
				// Keeping in memory number of tracks in Drift1.zip
				nROIs1=nROIs;
	
				// Opening Drift2 tracking
				roiManager("Open",Path+SubFolderList[i]+"Drift2.zip");
				nROIs=roiManager("count");
				// Initializing Drift2 vectors
				DriftX2=newArray(nROIs);
				DriftY2=newArray(nROIs);
				// Measuring positions for each time of Drift2
				run("Set Measurements...", "stack redirect=None decimal=3");
				roiManager("Select",0);
				run("Measure");
				PosXInit=getResult("X",0);
				PosYInit=getResult("Y",0);
				DriftX2[0]=0;
				DriftY2[0]=0;
				run("Clear Results");
				for (r=1;r<nROIs;r++){
					roiManager("Select",r);
					run("Measure");
					DriftX2[r]=getResult("X",0)-PosXInit;
					DriftY2[r]=getResult("Y",0)-PosYInit;
					run("Clear Results");
				}
				// Resetting ROIManager
				roiManager("reset");
				// Keeping memory of the length of Drift2
				nROIs2=nROIs;

				// Opening Drift3 tracking
				roiManager("Open",Path+SubFolderList[i]+"Drift3.zip");
				nROIs=roiManager("count");
				// Initializing Drift2 vectors
				DriftX3=newArray(nROIs);
				DriftY3=newArray(nROIs);
				// Measuring positions for each time of Drift3
				run("Set Measurements...", "stack redirect=None decimal=3");
				roiManager("Select",0);
				run("Measure");
				PosXInit=getResult("X",0);
				PosYInit=getResult("Y",0);
				DriftX3[0]=0;
				DriftY3[0]=0;
				run("Clear Results");
				for (r=1;r<nROIs;r++){
					roiManager("Select",r);
					run("Measure");
					DriftX3[r]=getResult("X",0)-PosXInit;
					DriftY3[r]=getResult("Y",0)-PosYInit;
					run("Clear Results");
				}
								
				// Merging tracks
				DriftX=newArray(nROIs1+nROIs2+nROIs-2);
				DriftY=newArray(nROIs1+nROIs2+nROIs-2);
				for (r=0;r<nROIs1;r++) {
					DriftX[r]=DriftX1[r];
					DriftY[r]=DriftY1[r];
				}

				for (r=nROIs1-1;r<nROIs1+nROIs2-1;r++) {
					DriftX[r]=DriftX[nROIs1-1]+DriftX2[r-nROIs1+1];
					DriftY[r]=DriftY[nROIs1-1]+DriftY2[r-nROIs1+1];
				}
				for (r=nROIs1+nROIs2-2;r<nROIs1+nROIs2+nROIs-2;r++) {
					DriftX[r]=DriftX[nROIs1-1]+DriftX2[nROIs2-1]+DriftX3[r-(nROIs1+nROIs2)+2];
					DriftY[r]=DriftY[nROIs1-1]+DriftY2[nROIs2-1]+DriftY3[r-(nROIs1+nROIs2)+2];                                                      
				}
		
				// Saving DriftX
				for (r=0;r<nROIs1+nROIs2+nROIs-2;r++){
					print(DriftX[r]);
				}
				selectWindow("Log");
				run("Text...", "save="+Path+SubFolderList[i]+"DriftX.csv");
				run("Close");
				// Saving DriftY
				for (r=0;r<nROIs1+nROIs2+nROIs-2;r++){
					print(DriftY[r]);
				}
				selectWindow("Log");
				run("Text...", "save="+Path+SubFolderList[i]+"DriftY.csv");
				run("Close");					
		
				// Closing image
				selectImage(ID);
				close();
				// Resetting ROIManager
				roiManager("reset");
					
			} else {
        	
	        	// Case of 2 tracking named Drift1.zip and Drift2.zip ///////////////////////////////////////////////////////////////////////////
	        	if(File.exists(Path+SubFolderList[i]+"Drift2.zip")) {
	        		// Opening Proj(left)_s image
		        	FileList=getFileList(Path+SubFolderList[i]);
		        	for (j=0; j<FileList.length; j++) {
		        		if(startsWith(FileList[j],"Proj(left)_s")) { 
							open(Path+SubFolderList[i]+FileList[j]); 
		        		}
		        	}
					ID=getImageID();
					selectImage(ID);
					getDimensions(width, height, channels, slices, frames);
					run("Properties...", "channels=1 slices=" + slices + " frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1 frame=[0 sec] origin=0,0");
		
					// Opening Drift1 tracking
					roiManager("Open",Path+SubFolderList[i]+"Drift1.zip");
					nROIs=roiManager("count");
					// Initializing Drift1 vectors
					DriftX1=newArray(nROIs);
					DriftY1=newArray(nROIs);
					// Measuring positions for each time of Drift1
					run("Set Measurements...", "stack redirect=None decimal=3");
					roiManager("Select",0);
					run("Measure");
					PosXInit=getResult("X",0);
					PosYInit=getResult("Y",0);
					DriftX1[0]=0;
					DriftY1[0]=0;
					run("Clear Results");
					for (r=1;r<nROIs;r++){
						roiManager("Select",r);
						run("Measure");
						DriftX1[r]=getResult("X",0)-PosXInit;
						DriftY1[r]=getResult("Y",0)-PosYInit;
						run("Clear Results");
					}
					// Resetting ROIManager
					roiManager("reset");
					// Keeping in memory number of tracks in Drift1.zip
					nROIs1=nROIs;
	
					// Opening Drift2 tracking
					roiManager("Open",Path+SubFolderList[i]+"Drift2.zip");
					nROIs=roiManager("count");
					// Initializing Drift2 vectors
					DriftX2=newArray(nROIs);
					DriftY2=newArray(nROIs);
					// Measuring positions for each time of Drift2
					run("Set Measurements...", "stack redirect=None decimal=3");
					roiManager("Select",0);
					run("Measure");
					PosXInit=getResult("X",0);
					PosYInit=getResult("Y",0);
					DriftX2[0]=0;
					DriftY2[0]=0;
					run("Clear Results");
					for (r=1;r<nROIs;r++){
						roiManager("Select",r);
						run("Measure");
						DriftX2[r]=getResult("X",0)-PosXInit;
						DriftY2[r]=getResult("Y",0)-PosYInit;
						run("Clear Results");
					}
					// Merging tracks
					DriftX=newArray(nROIs1+nROIs-1);
					DriftY=newArray(nROIs1+nROIs-1);
					for (r=0;r<nROIs1;r++) {
						DriftX[r]=DriftX1[r];
						DriftY[r]=DriftY1[r];
					}
					for (r=nROIs1-1;r<nROIs1+nROIs-1;r++) {
						DriftX[r]=DriftX[nROIs1-1]+DriftX2[r-nROIs1+1];
						DriftY[r]=DriftY[nROIs1-1]+DriftY2[r-nROIs1+1];
					}
		
					// Saving DriftX
					for (r=0;r<nROIs1+nROIs-1;r++){
						print(DriftX[r]);
					}
					selectWindow("Log");
					run("Text...", "save="+Path+SubFolderList[i]+"DriftX.csv");
					run("Close");
					// Saving DriftY
					for (r=0;r<nROIs1+nROIs-1;r++){
						print(DriftY[r]);
					}
					selectWindow("Log");
					run("Text...", "save="+Path+SubFolderList[i]+"DriftY.csv");
					run("Close");				
		
					// Closing image
					selectImage(ID);
					close();
					// Resetting ROIManager
					roiManager("reset");
		        	} else {
		        		print(SubFolderList[i]+" : no drift tracking found");
		        	}
			}
        }

}