
function open_image(file,filepath){
	open(filepath+"\\"+file);
	run("Remove Overlay");
	crop = "False";
	
	if (crop == "True"){
		run("Auto Crop");
	}
	selectWindow(file);
	print(file);
}

function threshold(file,threshdir,subtract,despeckle,makebinary,clearOutside){
	if( subtract == "True" ){
		print("subtracting background...");
		run("Subtract Background...", "rolling=100");
	}
	if( despeckle == "True"){
		print("despeckling background...");
		run("Despeckle");
	}
	
	F=File.openAsString(threshdir+"\\"+file);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
	
	if( makebinary == "True"){
		run("Make Binary");
	}
	if( clearOutside == "True"){
		print("clearing outside");
		clear_residuals();
	}
	
}

function add_image_segements(segment_thresh,xsplit,ysplit){
	getMinAndMax(min,max);
	setThreshold(1,max);
	getStatistics(area);
	resetThreshold();
	iterate = false;
	print("add_image_segemnt");
	if( area > segment_thresh ){
		iterate = true;
		iwidth = getWidth();
		iheight = getHeight();
		x=0;
		y=0;
		rectH = round(iheight / ysplit);
		rectW = round(iwidth / xsplit);
		print(rectH);
		print(rectW);
		print(xsplit);
		print(ysplit);
		
		for( i = 0; i < xsplit; i++){
			for (j = 0; j < ysplit; j++){
				print("i:"+toString(i) + "j:"+toString(j));
				makeRectangle(x+(rectW*i),y+(rectH*j),rectW,rectH);
				roiManager("Add");
			}
		}
	}
	return iterate;
}

function iter_skeleton_segments(outputDir, fname){
	nROIs = roiManager("count");
	for (i = 0; i < nROIs; i++){
		selectWindow(fname+".tif");
		run("Duplicate...", " ");
		selectWindow(fname+"-"+toString(i+1)+".tif");
		roiManager("Select", i);
		run("Clear Outside");
		//run("Auto Crop");
		skeleton_analysis();
		
		save_data(outputDir,fname+"-"+toString(i+1));
		
		
	}
	reset_("True");
}

function clear_residuals(){
	print("clearing residuals...");
	run("Analyze Particles...", "size=10-Infinity display clear include summarize add");
	run("Select All");
	roiManager("Combine");
	run("Clear Outside");
}

function skeleton_analysis(){
	print("skeletonizing");
	
	run("Skeletonize (2D/3D)");
	//run("Skeletonize");
	//run("Colors...", "foreground=white background=blue");
	
	
	watershed = "False";
	if(watershed == "True"){
		print("running watershed...");
		run("Watershed");
	}
	print("analyze skeletons");
	//run("Analyze Skeleton (2D/3D)", "prune=none calculate show");
	//run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] prune show");
	run("Analyze Skeleton (2D/3D)", "prune=none show");
	print("completed analysis");
	
	
}

function save_data(path,fname){
	selectWindow("Branch information");
	saveAs("Results", path+"\\"+fname+"_branchInfo.txt");
	selectWindow("Results");
	saveAs("Results", path+"\\"+fname+"_rawInfo.txt");
}

function reset_(clear_roi){
	n = roiManager("count");
	print(n);
	IJ.deleteRows(0,n+1);
	if( clear_roi == "True"){
		clear_roi_manager();
	}
	close_windows();
	collectGarbageIfNecessary();
}

function close_windows(){
	while (nImages>0) { 
          selectImage(nImages); 
          close(); 
    }
	list = getList("window.titles"); 
     for (i=0; i<list.length; i++){ 
     winame = list[i]; 
     	selectWindow(winame); 
     run("Close"); 
     } 
}

function clear_roi_manager(){
	array1 = newArray();
	//print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Delete");
}

function main(){
	setBatchMode(true);
	_in = getArgument();
	inputArgs = split(_in,"@");
	inputDir = inputArgs[0];
	outputDir = inputArgs[1];
	cell_branch_thresh = inputArgs[2];
	//cell_soma_thresh = inputArgs[3]; //cell_count threshold_path
	subtract = inputArgs[3];
	despeckle = inputArgs[4];
	makebinary = "True";
	clearOutside = "False";
	
	filelist = getFileList(inputDir+"\\");
	for(f=0;f < filelist.length; f++){
		//print(f);
		file = filelist[f];
		open_image(file,inputDir);
		fname = replace(file,".tif","");
		txtfile = replace(file,".tif",".txt");
		segment_thresh = 1000000000000;
		xsplit = 1;
		ysplit = 1;
		print("acessing add image_segments");
		iterate = add_image_segements(segment_thresh,xsplit,ysplit);
		threshold(txtfile,cell_branch_thresh,subtract,despeckle,makebinary,clearOutside);
		print("threshold");
		if(iterate == true){
			iter_skeleton_segments(outputDir, fname);
		} else {
			skeleton_analysis();
			save_data(outputDir,fname);
			reset_("False");
		}
	
		
		
		/*
		//skeleton_analysis();
		//save_data(outputDir,fname);
		reset_(clearOutside);
		*/
	}
	setBatchMode(false);
}

//Global variables
var collectGarbageInterval = 1; // the garbage is collected after n Images
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
	call("java.lang.System.gc");
	run("Collect Garbage"); 
	run("Collect Garbage"); 
	}
	if(collectGarbageShowLogMessage) print("...Collecting Garbage...");
	collectGarbageCurrentIndex = 1;
	//setBatchMode(true);
	} else collectGarbageCurrentIndex++;
}



main();



eval("script", "System.exit(0);");