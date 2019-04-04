print("grid complexity summary macro v1");

//Global variables

var collectGarbageInterval = 3; // the garbage is collected after n Images
var collectGarbageCurrentIndex = 1; // increment variable for garbage collection
var collectGarbageWaitingTime = 100; // waiting time in milliseconds before garbage is collected
var collectGarbageRepetitionAttempts = 1; // repeats the garbage collection n times
var collectGarbageShowLogMessage = true; // defines whether or not a log entry will be made

//Functions

//-------------------------------------------------------------------------------------------
// this function collects garbage after a certain interval
//-------------------------------------------------------------------------------------------
function collectGarbageIfNecessary(){
	if(collectGarbageCurrentIndex == collectGarbageInterval){
		//setBatchMode(false);
		wait(collectGarbageWaitingTime);
		for(i=0; i<collectGarbageRepetitionAttempts; i++){
			wait(100);
			//run("Collect Garbage");
			call("java.lang.System.gc");
		}
		if(collectGarbageShowLogMessage) print("...Collecting Garbage...");
		collectGarbageCurrentIndex = 1;
		//setBatchMode(true);
	} else collectGarbageCurrentIndex++;
}

function summarize_complexity(col_features){
	print(nResults);
	Array.print(col_features);

	//total branch length = average branch length * # branches == array[0] * array[5]
	summarized_features = newArray;
	
	for(j=0; j < col_features.length; j++){
		sum = 0;
		for(i=0; i<nResults; i++){
			sum = sum + getResult(col_features[j], i);
			//print(sum);
		}
		print(col_features[j]);
		print(sum);
		summarized_features[j] = sum;
	}
	//total branch length = average branch length * # branches == array[0] * array[5]
	summarized_features[col_features.length] = summarized_features[0] * summarized_features[5];
	return summarized_features;
}


function save_data(output,fname,extra,nBranches, nJunctions, nEnds, nJuncVoxels, nSlab, aveBranch, nTriple, nQuad, maxBranch, totalBranchLength, BX, BY){
	Array.show("complexity_results",nBranches,nJunctions,nEnds,nJuncVoxels,nSlab,aveBranch,nTriple,nQuad,maxBranch,totalBranchLength,BX,BY);		
	selectWindow("complexity_results");
	//stop;
	saveAs("Results", output+fname+"_"+extra+".txt");	
	selectWindow(fname+"_"+extra+".txt");
	run("Close");
}

function autothreshold(threshType){
	setAutoThreshold(threshType+" dark no-reset");
}

function threshold(threshdir,file){
	F=File.openAsString(threshdir+"\\"+file);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}

function binarize_skeleton(){
	run("Make Binary");
	run("Skeletonize (2D/3D)");
}

function initiate_results_table(){
	nBranches = newArray(1);
	nJunctions = newArray(1);
	nEnds = newArray(1);
	nJuncVoxels = newArray(1);
	nSlab = newArray(1);
	aveBranch = newArray(1);
	nTriple = newArray(1);
	nQuad = newArray(1);
	maxBranch = newArray(1);
	totalBranchLength = newArray(1);
	BX = newArray(1);
	BY = newArray(1);
	Array.show("complexity_results",nBranches,nJunctions,nEnds,nJuncVoxels,nSlab,aveBranch,nTriple,nQuad,maxBranch,totalBranchLength,BX,BY);		
}

function grid_skeleton(startX, startY, scale){
	/*
	 * FUNCTION grid_measure
	 */
	x = startX; 
	y = startY;
	picWidth = getWidth();
	picHeight = getHeight();
	tW = xy;
	tH = xy;
	nX = ( picWidth - x ) / tW;
	nY = ( picHeight - y ) / tH;
	
	//count = 0;
	//scale = 1.5;
	nextStop=false;

	nBranches = newArray;
	nJunctions = newArray;
	nEnds = newArray;
	nJuncVoxels = newArray;
	nSlab = newArray;
	aveBranch = newArray;
	nTriple = newArray;
	nQuad = newArray;
	maxBranch = newArray;
	totalBranchLength = newArray;
	BX = newArray;
	BY = newArray;

	branch_features = newArray("# Branches","# Junctions","# End-point voxels","# Junction voxels", "# Slab voxels","Average Branch Length","# Triple points","# Quadruple points", "Maximum Branch Length");
	row = 0;
	//selectWindow("complexity_results");
	for(n = 0; n < nY; n++){
		offsetY = y + (n * tH);
		for(m=0;m < nX; m++){
			offsetX = x + (m * tW);
			print(offsetX);
			makeRectangle(offsetX, offsetY, tW, tH);
			roiManager("Add");
			roiManager("Select", 0);
			run("Measure");
			Mean = getResult("Mean",0);
			
			if(Mean > 0){
				roiManager("Select", 0);
				wait(1);
				run("Duplicate...", "title=grid");
				selectWindow("grid");
				wait(1);
				run("Analyze Skeleton (2D/3D)", "prune=none");
				wait(1);
				array1 = summarize_complexity(branch_features);

				nBranches[row] = array1[0];
				nJunctions[row] = array1[1];
				nEnds[row] = array1[2];
				nJuncVoxels[row] = array1[3];
				nSlab[row] = array1[4];
				aveBranch[row] = array1[5];
				nTriple[row] = array1[6];
				nQuad[row] = array1[7];
				maxBranch[row] = array1[8];
				totalBranchLength[row] = array1[9];
				BX[row] = offsetX/scale;
				BY[row] = offsetY/scale;
				
				selectWindow("Tagged skeleton");
				wait(1);
				close();
				selectWindow("grid");
				wait(1);
				close();
				row++;
			}

			roiManager("Select", 0);
			wait(1);
			roiManager("delete");
			run("Clear Results");
			wait(1);
			selectWindow(fname+".tif");
			wait(1);
		}
	}
	Table.showArrays("complexity_results_"+toString(x)+"_"+toString(y),nBranches,nJunctions,nEnds,nJuncVoxels,nSlab,aveBranch,nTriple,nQuad,maxBranch,totalBranchLength,BX,BY);
	stop;
}

function main(batchmode){
	setBatchMode(batchmode);
	setOption("ExpandableArrays", true);
	
	//input_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap_redoTest/";
	//input_dir = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_S100b_Nestin\\input_batch_gfap_redoBASIC\\";
	//input_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_redo_untreated/";
	input_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_retiled_batch/";
	
	output_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/branch_features/150/"; //output features textfile directory
	//output_dir = "C:/Users/joey_/Desktop/";
	threshold_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/threshold_files/"; //directory to output recorded lower / upper threshold values
	thresh = "Triangle"; //method to use for thresholding
	startX = 0;
	startY = 0;
	xy = 150;
	numOffsets = 2;
	autothresh = true;
	subtract = "100"; //value to subtract bacground by needs to be string to be read by imageJ macro
	scale = 1.5;

	print(input_dir);
	
	filelist = getFileList(input_dir);
	Array.print(filelist);
	for(i=0; i < filelist.length; i++){
		print(filelist[i]);
		img_file = input_dir + filelist[i];
		file_inputs= split(filelist[i],"_");
		Array.print(file_inputs);
		
		//pre-determined naming structure for file -- files are named as [mouseID]_[treatmentDay]_[treatmentCondition]_[IFTarget]_[section].txt
		mID=file_inputs[0];
		day=file_inputs[1];
		cond=file_inputs[2];
		cell=file_inputs[3];
		sec = replace(file_inputs[4],".tif","");
		fname = toString(mID)+"_"+toString(day)+"_" + toString(cond) + "_"+toString(cell)+"_"+toString(sec);
		open(img_file);
		
		run("Subtract Background...", "rolling="+subtract);
		if(autothresh){
			autothreshold(thresh);
		} else {
			threshold(threshold_dir,fname+".txt");
		}
		binarize_skeleton();
		//run("Measure");
		//initiate_results_table();
		
		//iters = 0;
		for(z=0;z<numOffsets;z++){
			for(j=0;j<numOffsets;j++){
				start_offsetX =((parseInt(xy)/numOffsets) * z);
				start_offsetY =((parseInt(xy)/numOffsets) * j);
				grid_skeleton(start_offsetX,start_offsetY,scale);
			}
		}
		save_data(output_dir,fname,xy,nBranches, nJunctions, nEnds, nJuncVoxels, nSlab, aveBranch, nTriple, nQuad, maxBranch, totalBranchLength, BX, BY);
		//stop;
		collectGarbageIfNecessary();
	}
	setBatchMode(false);
}

print("HERE");







main(true);



//threshold_binarize_skeletonize(thresh);



/*
array1 = summarize_complexity();

Array.show("test",array1);

threshold="Otsu";

saveAs("Results", "C:/Users/joey_/Desktop/test.csv");
*/
