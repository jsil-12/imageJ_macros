/*
 * convenience macro, measure fluorescense, cell counts, and fluorescence for whole sections
 * for astrocytes and microglia
 * v1, updated 19-4-7
 * 
 */
 
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
}else collectGarbageCurrentIndex++;
}



function process_file_check(file, ID_checklist){
	pass = false;
	for(z=0;z<ID_checklist.length;z++){
		ref_ID = ID_checklist[z];
		info = split(file,"_");
		ID = info[0];
		if(ID == ref_ID){
			pass = true;
		}
	}
	return pass;
}

function process_image(subtract,subtract_by,contrast,despeckle){
	if(contrast == true){
		run("Enhance Contrast...", "saturated=0.3 normalize");
	}
	if(subtract == true){
		run("Subtract Background...", "rolling="+subtract_by);
	}
	if(despeckle == true){
		run("Despeckle");	
	}
}

function background_measure(){
	getMinAndMax(min,max);
	setThreshold(1, max+1);
	run("Measure");
	resetThreshold();
}

function autolocal_threshold(threshtype,radius){
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
}

function threshold_measure(autolocal,thresh,radius){
	if(autolocal){
		autolocal_threshold(thresh,radius);
		selectWindow("2");
		roiManager("select",0);
		roiManager("measure");
	} else {
		print("error... non-autolocalthreshold not implemented");
	}
}

function calculate_percArea(roiID){
	run("Select All");
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
	return newArray(percArea, fore, back);
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

function clear_roi_manager(){
	roiManager("deselect");
	roiManager("Delete");
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


function reset_all(){
	run("Clear Results");
	clear_roi_manager();
	close_windows();
	collectGarbageIfNecessary();
}


function save_results(dir,extra,file){
	print("saving data!");
	saveAs("Results", dir+"/"+extra+"/"+file);
	print("data saved");
}

function save_skeleton(path,fname){
	selectWindow("Branch information");
	saveAs("Results", path+"/"+fname+"_branchInfo.txt");
	selectWindow("Results");
	saveAs("Results", path+"/"+fname+"_rawInfo.txt");
}


function main(batchmode){
	setBatchMode(batchmode);

	/* directories
	 * 
	 */

	//open all files
	dir = "E";
	//input_dir = dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_v3_all/";
	//output_dir = dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/whole_output/"

	input_dir = dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/"
	output_dir = dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/whole_output/"
	
	autolocal=true;
	local_thresh_type = "Phansalkar"; //"Phansalkar"; //Niblack for microglia
	radius = 60;
	subtract = true; //subtract background
	subtract_by = "100"; // amount to subtract by -- input as string for imageJ to interpret
	despeckle = true; // apply 1 round of despeckling
	contrast = true;
	//scale = 1.5;

	imagefiles = getFileList(input_dir);
	Array.print(imagefiles);

	for(j=0;j<imagefiles.length;j++){
		img_file=imagefiles[j];
		txt_file=replace(img_file,"tif","txt");
		fname = replace(img_file,"tif","");

		//process IF data
		open(input_dir+"/"+img_file);
		process_image(subtract,subtract_by,contrast,despeckle);

		background_measure();
		threshold_measure(autolocal,local_thresh_type,radius);
		save_results(output_dir,"/IF_data/",txt_file);
		run("Clear Results");

		//process skeleton data

		area_metrics = calculate_percArea(0);
		percArea = area_metrics[0];
		fore = area_metrics[1];
		back = area_metrics[2];
		print(fore);
		print(back);
		
		selectWindow("1");
		run("Select All");
		skeleton_analysis();
		selectWindow("Results");
		setResult("percArea", 0, percArea);
		setResult("Area", 0, fore);
		setResult("backgroundArea", 0, back);
		updateResults();
		save_skeleton(output_dir+"/skeleton_data/",fname);
		
		reset_all();
	}
}

main(true);

