// Top max projection of the imaging data
/* 
Input: List of hyperstacks(x,y,z) for each timepoint (t) and each animal/stage (s)
Ouput: List of projected stacks(x,y) for each timepoint (t) and each animal/stage (s)
 */

path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
newDir = getDirectory("Choose output Directory"); 
File.makeDirectory(newDir); 
setBatchMode(true); 
for (i=0; i<filename.length; i++) { 
        if(endsWith(filename[i], ".TIF")) { 
                open(path+filename[i]); 
				ID=getImageID();
				selectImage(ID);
				getDimensions(width, height, channels, slices, frames);
				run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" unit=pixel pixel_width=0.322 pixel_height=0.322 voxel_depth=1");
				run("Z Project...", "start=1 stop=" + slices + " projection=[Max Intensity]");
				IDProj=getImageID();
				selectImage(IDProj);
				saveAs("tif", newDir + "allz" + getTitle); 
				selectImage(IDProj);
				close();
				selectImage(ID);
				close();
        } 
} 