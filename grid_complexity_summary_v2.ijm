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

function summarize_complexity(){
	print(nResults);
	col_features = newArray("# Branches","# Junctions","# End-point voxels","# Junction voxels", "# Slab voxels","Average Branch Length","# Triple points","# Quadruple points", "Maximum Branch Length");
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
		
		iters = 0;
		for(z=0;z<numOffsets;z++){
			for(j=0;j<numOffsets;j++){
				//defines top X and top Y of first square in grid -- defines how grid array will look
				startX =((parseInt(xy)/numOffsets) * z);
				startY =((parseInt(xy)/numOffsets) * j);
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
						//print(Mean);
						
						if(Mean > 0){
							roiManager("Select", 0);
							run("Duplicate...", "title=grid");
							selectWindow("grid");
							run("Analyze Skeleton (2D/3D)", "prune=none");
							array1 = summarize_complexity();
							
							//Array.print(array1);
							nBranches[iters] = array1[0];
							nJunctions[iters] = array1[1];
							nEnds[iters] = array1[2];
							nJuncVoxels[iters] = array1[3];
							nSlab[iters] = array1[4];
							aveBranch[iters] = array1[5];
							nTriple[iters] = array1[6];
							nQuad[iters] = array1[7];
							maxBranch[iters] = array1[8];
							totalBranchLength[iters] = array1[9];
							BX[iters] = offsetX/scale;
							BY[iters] = offsetY/scale;
							
							selectWindow("Tagged skeleton");
							close();
							selectWindow("grid");
							close();
							run("Clear Results");
							iters++;
						}
							
						selectWindow(fname+".tif");
						roiManager("Select", 0);
						roiManager("delete");
						run("Clear Results");
					}
				}
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
