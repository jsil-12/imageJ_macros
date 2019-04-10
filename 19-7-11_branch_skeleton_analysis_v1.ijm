


function correct_image(subtract,subtract_amount,despeck,contrast){
	if(subtract == true){
		run("Subtract Background...", "rolling="+subtract_amount);
	}
	if(despeck == true){
		run("Despeckle");	
	}
	if(contrast == true){
		run("Enhance Contrast...", "saturated=0.3 normalize");
	}
}

function autolocal_threshold(threshtype, radius){
	run("Select All");
	run("Duplicate...", "title=1");
	run("Duplicate...", "title=2");
	
	selectWindow("1");
	thresh = threshtype;
	run("8-bit");
	run("Auto Local Threshold", "method="+threshtype+" radius="+radius+" parameter_1=0 parameter_2=0 white");
	//run("Analyze Particles...", "include add");
	run("Create Selection");
	roiManager("Add");
	//selectWindow("1");
	//close();
}

function set_threshold(threshpath){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	F=File.openAsString(threshpath);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}

function skeleton_analysis(){
	print("skeletonizing");
	run("Skeletonize (2D/3D)");
	print("analyze skeletons");
	//run("Analyze Skeleton (2D/3D)", "prune=none calculate show");
	//run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] prune show");
	run("Analyze Skeleton (2D/3D)", "prune=none show");
	print("completed analysis");
}

function save_data(path,fname){
	selectWindow("Branch information");
	saveAs("Results", path+"/"+fname+"_branchInfo.txt");
	selectWindow("Results");
	saveAs("Results", path+"/"+fname+"_rawInfo.txt");
}

function reset_all(){
	run("Clear Results");
	clear_roi_manager();
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
	roiManager("deselect");
	roiManager("Delete");
}

function calculate_percArea(roiID){
	selectWindow("2");
	getMinAndMax(min, max);
	setThreshold(1, max+1);
	run("Measure");
	back = getResult("Area",0);
	resetThreshold();
	roiManager("select",roiID);
	run("Measure");
	fore = getResult("Area",1);
	percArea = fore/back;
	print(percArea);
	run("Clear Results");
	selectWindow("2");
	close();
	return newArray(percArea, fore, back);
}

function main(batchmode){
	setBatchMode(batchmode);
	//_in = getArgument();
	//inputArgs = split(_in,"@");
	_dir = "E";


	cluster = "unclustered";

	
	inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/"+cluster+"/cutout_image/";
	//inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/cluster_files/cluster_imagefiles/150/"+cluster+"/cutout_image/";
	
	outputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/"+cluster+"/skeleton_data/";
	//outputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/cluster_files/cluster_imagefiles/150/"+cluster+"/skeleton_data/";
	
	set_threshold_path = "";

	local_threshold=true;
	local_threshold_method = "Phansalkar";
	radius=60;
	
	subtract = true;
	subtract_amount = "100";
	contrast = true;
	despeckle = true;
	clearOutside = "False";

	apply_image_corrections=false;
	
	filelist = getFileList(inputDir+"/");
	Array.print(filelist);
	for(f=0;f < filelist.length; f++){
		//print(f);
		file = filelist[f];
		//open_image(file,inputDir);
		fname = replace(file,".tif","");
		txtfile = replace(file,".tif",".txt");

		open(inputDir+"/"+file);
		if(apply_image_corrections){
			correct_image(subtract,subtract_amount,despeckle,contrast);
		}
		
		if(local_threshold){
			autolocal_threshold(local_threshold_method, radius);
		} else {
			set_threshold(set_threshold_path);
		}

		print(file);
		print("..Background Measures..");
		
		area_metrics = calculate_percArea(0);
		
		percArea = area_metrics[0];
		fore = area_metrics[1];
		back = area_metrics[2];

		selectWindow("1");
		
		/*
		print("..thresholded..");
		run("Make Binary");
		print("..Binarized..");
		*/
		run("Select All");
		skeleton_analysis();
		selectWindow("Results");
		setResult("percArea", 0, percArea);
		setResult("Area", 0, fore);
		setResult("backgroundArea", 0, back);
		updateResults();
		save_data(outputDir,fname);
		reset_all();
		
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



main(true);



//eval("script", "System.exit(0);");