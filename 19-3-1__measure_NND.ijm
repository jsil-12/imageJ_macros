print("starting NND analysis...");

function open_image(file,filepath){
	open(filepath+"/"+file);
	run("Remove Overlay");
	crop = "False";
	
	if (crop == "True"){
		run("Auto Crop");
	}
	selectWindow(file);
	print(file);
}

function add_cell_rois(path,fname){
	roiManager("open", path+"/"+fname+".zip");
	N = roiManager("count");
	for (i = 0; i < N; i++){
		roiManager("Select", i);
		run("Measure");
	}
}

function get_NND(){
	run("8-bit");
	run("Nnd ");
	wait(50);
}

function save_data(path,fname){
	selectWindow("Nearest Neighbor Distances");
	saveAs("Results", path+"\\"+fname+"_NND.txt");
	wait(50);
}

function reset_(){
	run("Clear Results");
	roiManager("Deselect");
	roiManager("Delete");
	close_windows();
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

function main(batchmode){
	setBatchMode(batchmode);
	print("starting NND analysis...");
	/*
	inputDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_s100b_v3/";
	outputDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/proximal/count_data/nnd/";
	roiDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/proximal/count_data/rois/";
	*/

	dir = "E";
	inputDir = dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/";
	outputDir = dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set1/feature_files/single_threshold/count_data/nnd/";
	roiDir = dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set1/feature_files/single_threshold/count_data/rois/";

	
	filelist = getFileList(roiDir+"/");
	for(f=0;f < filelist.length; f++){
		file = filelist[f];
		print(file);
		fname = replace(file,".zip","");
		txtfile = fname+".txt";
	
		open_image(fname+".tif",inputDir);
		add_cell_rois(roiDir,fname);
		get_NND();
		save_data(outputDir,fname);
		reset_();
		collectGarbageIfNecessary();
	}
	setBatchMode(false);
}

main(true);











//Global variables
var collectGarbageInterval = 5; // the garbage is collected after n Images
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





//eval("script", "System.exit(0);");