// Open recoil movies and assist manual calculation of intial recoil velocity

/*
Requires an architecture like that :
RootFolder
	Folder1=Pupa1_24hAPF
		Apical.czi
		Basal.czi
	Folder(n)=Pupa(n)_18hAPF
		Apical.czi
		Basal.czi
	...
 */

//////////////////////////////////////////////////////////////////////////////////////
// Parameters ////////////////////////////////////////////////////////////////////////
FrameCalculation=8; // Frame at which opening is calculated
Timestep=1; // Timestep in sec
FrameAblation=2; // First frame showing ablation
//////////////////////////////////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////////////////////////////////
// Code /////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

// Folder selection
path=getDirectory("Choose directory containing all pupa folders");
folderlist=getFileList(path);

// Making sure everything is closed
run("Clear Results"); 
roiManager("Reset");
run("Close All");
print("Hello!");
selectWindow("Log");
run("Close");

// Counting number of pupae
count=0;
for (f=0;f<folderlist.length;f++){
	if (startsWith(folderlist[f],"Pupa")){
		count=count+1;
	}
}

// Initializing measure vectors
Timings=newArray(count);
RecoilApical=newArray(count);
RecoilBasal=newArray(count);


// Recoil quantifications
count=0; // for each pupa
for (i=0; i<folderlist.length; i++) { // for each pupa
	if (matches(folderlist[i], ".*Pupa.*")) {
		
		// Detection of the timing of the pupa
		FolderName=folderlist[i];
		Timing=substring(FolderName,indexOf(FolderName,"_")+1,indexOf(FolderName,"hAPF"));
		Timings[count]=Timing;


		// Apical recoil *********************************************************************
		if (File.exists(path+folderlist[i]+"Apical.zip")){ // In case recoil are already estimated
			open(folderlist[i]+"Apical.czi");
			roiManager("reset");
			ID=getImageID();
			selectImage(ID);
			roiManager("open",path+folderlist[i]+"Apical.zip");
			// Measuring apical recoil velocity
			run("Set Measurements...", "  redirect=None decimal=3");
			roiManager("Select",0);
			run("Measure");
			roiManager("Select",1);
			run("Measure");
			xO=getResult("Length",0);
			xt=getResult("Length",1);
			RecoilApical[count]=(xt-xO)/(Timestep*(FrameCalculation-FrameAblation));
			run("Clear Results");
			roiManager("reset");
			selectImage(ID);
			close();
			
		} else {
			// Si un film de recoil apical existe
			if (File.exists(path+folderlist[i]+"Apical.czi")){
				// Opening apical recoil film
				open(folderlist[i]+"Apical.czi");
				roiManager("reset");
				ID=getImageID();
				selectImage(ID);
				// Cropping to only keep till frame=FrameCalculation
				getDimensions(width, height, channels, slices, frames);
				if (channels==2){
					selectImage(ID);
					run("Duplicate...", "duplicate channels=2");
					ID2=getImageID();
					selectImage(ID);
					close();
					selectImage(ID2);
					ID=getImageID();
				}
				run("In [+]");
				run("In [+]");
				run("Median...", "radius=1 stack");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
					
				// Manual estimation of initial apical opening
				selectImage(ID);
				setSlice(1);
				wait(500);
				setSlice(2);
				waitForUser("Draw line between the 2 vertices before recoil");
				roiManager("Add");
						
				// Visualisation of the apical recoil dynamics
				for (t=2;t<FrameCalculation+1;t++) {
					selectImage(ID);
					setSlice(t);
					wait(200);
				}
						
				// Manual estimation of apical opening at FrameCalculation
				waitForUser("Draw line between the 2 vertices after recoil");
				roiManager("Add");
				
				// Saving ROIs
				roiManager("Save",path+folderlist[i]+"Apical.zip");
			
				// Measuring apical recoil velocity
				run("Set Measurements...", "  redirect=None decimal=3");
				roiManager("Select",0);
				run("Measure");
				roiManager("Select",1);
				run("Measure");
				xO=getResult("Length",0);
				xt=getResult("Length",1);
				RecoilApical[count]=(xt-xO)/(Timestep*(FrameCalculation-FrameAblation));
				run("Clear Results");
				roiManager("reset");
				selectImage(ID);
				close();
			
			} else { // Cases for which no apical recoil was filmed
				RecoilApical[count]=666; // Attribution of an arbitrary value
			}
		}

		
		// Basal recoil *********************************************************************
		if (File.exists(path+folderlist[i]+"Basal.zip")){ // In case recoil are already estimated
			open(folderlist[i]+"Basal.czi");
			roiManager("reset");
			ID=getImageID();
			selectImage(ID);
			roiManager("open",path+folderlist[i]+"Basal.zip");
			// Measuring basal recoil velocity
			run("Set Measurements...", "  redirect=None decimal=3");
			roiManager("Select",0);
			run("Measure");
			roiManager("Select",1);
			run("Measure");
			xO=getResult("Length",0);
			xt=getResult("Length",1);
			RecoilBasal[count]=(xt-xO)/(Timestep*(FrameCalculation-FrameAblation));
			run("Clear Results");
			roiManager("reset");
			selectImage(ID);
			close();
			
		} else {

			// Si un film de recoil basal existe
			if (File.exists(path+folderlist[i]+"Basal.czi")){
				// Opening basal recoil film
				open(folderlist[i]+"Basal.czi");
				roiManager("reset");
				ID=getImageID();
				selectImage(ID);
				// Cropping to only keep till frame=FrameCalculation
				getDimensions(width, height, channels, slices, frames);
				if (channels==2){
					selectImage(ID);
					run("Duplicate...", "duplicate channels=2");
					ID2=getImageID();
					selectImage(ID);
					close();
					selectImage(ID2);
					ID=getImageID();
				}
				run("In [+]");
				run("In [+]");
				run("In [+]");
				run("In [+]");
				run("Median...", "radius=1 stack");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
				run("Enhance Contrast", "saturated=0.35");
				
				// Manual estimation of initial basal opening
				selectImage(ID);
				setSlice(1);
				wait(500);
				setSlice(2);
				waitForUser("Draw line between the 2 vertices before recoil");
				roiManager("Add");
					
				// Visualisation of the basal recoil dynamics
				for (t=2;t<FrameCalculation+1;t++) {
					selectImage(ID);
					setSlice(t);
					wait(200);
				}
					
				// Manual estimation of basal opening at FrameCalculation
				waitForUser("Draw line between the 2 vertices after recoil");
				roiManager("Add");
			
				// Saving ROIs
				roiManager("Save",path+folderlist[i]+"Basal.zip");
				
				// Measuring basal recoil velocity
				run("Set Measurements...", "  redirect=None decimal=3");
				roiManager("Select",0);
				run("Measure");
				roiManager("Select",1);
				run("Measure");
				xO=getResult("Length",0);
				xt=getResult("Length",1);
				RecoilBasal[count]=(xt-xO)/(Timestep*(FrameCalculation-FrameAblation));
				run("Clear Results");
				roiManager("reset");
				selectImage(ID);
				close();
		

			} else { // Cases for which no apical recoil was filmed
				RecoilBasal[count]=666; // Attribution of an arbitrary value
			}
		}
		// Incremeting the count
		count=count+1;
	}
}




// Save values
for (pupa=0;pupa<count;pupa++){
	print(Timings[pupa]);
}
selectWindow("Log");
run("Text...", "save="+path+"Timings.csv");
run("Close");

for (pupa=0;pupa<count;pupa++){
	print(RecoilApical[pupa]);
}
selectWindow("Log");
run("Text...", "save="+path+"RecoilApical.csv");
run("Close");

for (pupa=0;pupa<count;pupa++){
	print(RecoilBasal[pupa]);
}
selectWindow("Log");
run("Text...", "save="+path+"RecoilBasal.csv");
run("Close");