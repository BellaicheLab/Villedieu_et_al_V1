// This macro generates a smaller and preprocessed version of each hyperstack to detect topomap
// Optimal for detection of the apical plane labelled with E-cadherin marker

// Made by Aurelien Villedieu (03/2020)

// Prerequisite //////////////////////////////////////////////////////////////////////////////
/*
Put in a folder only the stacks you want to use for topo detection
 */
//////////////////////////////////////////////////////////////////////////////////////////////

// Parameters ////////////////////////////////////////////////////////////////////////////////
RollingBallRadius=2;
ScalingFactor=0.1;
MedianFilterSize=3;
VarianceZSize=2;
GaussianblurZSize=2;
MultiplicationValue=500;
//////////////////////////////////////////////////////////////////////////////////////////////

// CODE //////////////////////////////////////////////////////////////////////////////////////

// User select the path where stacks are stored
path = getDirectory("Select the folder containing images for topomap detection");
files = getFileList(path);

// Output folder creation
pathOut = path + "TopoMapDetection" + File.separator;
File.makeDirectory(pathOut);

// Batchmode activation
setBatchMode(true);

// Treatment for each stack
for (i=0; i<files.length; i++) { 
		// Opening the stack
        if(endsWith(files[i],'.TIF')) {
        	open(path+files[i]);
        	ID=getImageID();
        	selectImage(ID);
        	
			// Rolling ball to extract dynamic contours (Ecadherin signal)
        	run("Subtract Background...", "rolling="+RollingBallRadius+" stack");
        	
        	// Downscaling the image
        	getDimensions(width, height, channels, slices, frames);
        	newWidth=floor(width*ScalingFactor);
        	newHeight=floor(height*ScalingFactor);
        	run("Scale...", "x="+ScalingFactor+" y="+ScalingFactor+" z=1.0 width="+newWidth+" height="+newHeight+" depth="+slices+" interpolation=Bilinear average process create");
        	ID2=getImageID();
        	selectImage(ID);
        	close();
        	selectImage(ID2);
        	
        	// 2D median filter
        	run("Median...", "radius="+MedianFilterSize+" stack");
        	
        	// Variance filter in z, to detect the plane of high z variance (apical plane)
        	run("Variance 3D...", "x=0 y=0 z="+VarianceZSize);
        	
        	// Gaussian filter in z to smooth the profile (to ease maximum detection)
        	run("Gaussian Blur 3D...", "x=0 y=0 z="+GaussianblurZSize);

        	// Multiplication of the values, to increase resolution
			run("Multiply...", "value="+MultiplicationValue+" stack");
			// Saving image
			selectImage(ID2);
			saveAs("tiff",pathOut+files[i]);
			
			// Closing image
        	selectImage(ID2);
        	close();
        	}
}