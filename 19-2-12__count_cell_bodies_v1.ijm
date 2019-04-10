print("accessed cell count macro");
print("This macro will count microglia cell bodies");

//setBatchMode(true);
//selectWindow("JS1_1D_noFUS_microglia_sec4.tif");
//roiManager("Add");


function morphological_filtering(){
	run("Gray Scale Attribute Filtering", "operation=Opening attribute=Area minimum=25 connectivity=8");
	print("... Gray Filtering complete ...");
	run("Morphological Filters", "operation=Opening element=Octagon radius=1");
	print("... Morphological Filtering complete ...");
}

function morphological_filtering2(){
	run("Gray Scale Attribute Filtering", "operation=Opening attribute=Area minimum=50 connectivity=8");
	run("Gray Scale Attribute Filtering", "operation=[Top Hat] attribute=Area minimum=500 connectivity=8");
	print("... Gray Scale Filtering complete ...");
}

function autolocal_threshold(method,radius){
	run("8-bit");
	print(method);
	print(radius);
	//stop;
	run("Auto Local Threshold", "method="+method+" radius="+radius+" parameter_1=0 parameter_2=0 white");
	//run("Auto Local Threshold", "method=Contrast radius=40 parameter_1=0 parameter_2=0 white");
	
}

function intensity_threshold(threshpath){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	if(threshpath == "None"){
		run("Select All");
		setAutoThreshold("MaxEntropy dark");
	} else {
		print(threshpath);
		F=File.openAsString(threshdir+"\\"+file+".txt");
		getMinAndMax(min,max);
		lower_upper=split(F,"_");
		setThreshold(lower_upper[0],max+1);
	}
}

function save_image(filename,output){
	//roiManager("Select", array(1
	filename = replace(filename,".tif","");
	//D:\lab_files\imageJ_macro_working_directory\Gfap_Iba1_ki67\cell_counts_all\counts
	selectWindow("Results");
	saveAs("Results", output + "\\counts\\"+filename + ".txt");
	save_rois(output+"\\rois\\",filename);
}

function reset_(){
	n = roiManager("count");
	print(n);
	IJ.deleteRows(0,n+1);
	clear_roi_manager();
	close_windows();
	run("Clear Results");
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
	print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Delete");
}

function save_rois(outputDir,fname){
	array1 = newArray();
	print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Save", outputDir+fname+".zip");
}

function open_image(file,filepath,threshold_path){
	open(filepath+"\\"+file);
	selectWindow(file);
	if(threshold_path == "None"){
		roiManager("Add");
	}
}

function set_window(fname){
	//toselect=fname+"-attrFilt-Opening"; //for morphological_filtering v1
	toselect=fname+"-attrFilt-attrFilt"; //for v2
	selectWindow(toselect);
	roiManager("Select", 0);
}

function correct_image(subtract,subtract_amount,despeck,contrast){
	if(contrast == true){
		run("Enhance Contrast...", "saturated=0.3 normalize");
	}
	if(subtract == true){
		run("Subtract Background...", "rolling="+subtract_amount);
	}
	if(despeck == true){
		run("Despeckle");	
	}
}

function main(batchmode){
	setBatchMode(batchmode);


	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit redirect=None decimal=3");
	print("accessed main");
	//InputDir, ourputDir

	// ----- INPUT DIRECTORIES ------
	//inputDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/proximal/cutout_image/";
	
	//inputDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_Iba1_ki67/GFAP_Iba1_ki67_batch_microglia/"

	_dir = "E";
	//inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/proximal/s100b_cutout_image_no_preprocessing/";
	//outputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_imagefiles/150/proximal/count_data/";

	//inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_untreated_input/";

	//inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_s100b_v3/";
	//outputDir = _dir+":/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/whole_output/cell_counts/";
	

	cluster = "unclustered";
	
	//inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/cluster_files/cluster_imagefiles/150/"+cluster+"/cutout_image_no_preprocessing/";
	
	inputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/";
	//outputDir = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/cluster_files/cluster_imagefiles/150/"+cluster+"/count_data/";   //feature_files/single_threshold/count_data/";

	outputDir = _dir +":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/whole_output/count_data/"
	
	threshold_path = "None";

	//only subtract background for counting cells
	process_image = true;
	subtract = true;
	subtract_amount = "50"; //"50" for astrocyte and microglia
	despeckle = true; //false for astrocyte
	contrast = false; //false for astrocyte

	autolocalthreshold=false;   //true for astrocyte false for microglia
	
	method="Phansalkar";
	radius="60";
	
	filelist = getFileList(inputDir);
	for(f=0;f < filelist.length; f++){
		file = filelist[f];
		full_path = inputDir+file;
		open(full_path);
		roiManager("add");
		
		if (process_image){
			correct_image(subtract, subtract_amount, despeckle, contrast);
		}
		fname = replace(file,".tif","");

		//COUNT CELLS
		morphological_filtering2();

		set_window(fname);
		if (autolocalthreshold){
			autolocal_threshold(method,radius);
		} else {
			intensity_threshold(threshold_path);
		}

		run("Make Binary");

		size="15";
		print(size);
		
		run("Analyze Particles...", "size="+size+"-Infinity display clear include add");
		//roiManager("Deselect");
		//roiManager("Measure");
		print("... analyzed particles complete ...");

		save_image(file,outputDir);
		reset_();
	}
	setBatchMode(false);
}

function write_threshold_file(lower_upper,file,outputD){
	outputD = outputD+"\\threshold\\";
	f = File.open(outputD+file+".txt");
	print(f,toString(lower_upper[0]));
	print(f,"_");
	print(f,toString(lower_upper[1]));
	File.close(f);
}

function set_threshold(file,threshdir){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	print(threshdir+"\\"+file);
	F=File.openAsString(threshdir+"\\"+file+".txt");
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}




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
	setBatchMode(false);
	wait(collectGarbageWaitingTime);
	for(i=0; i<collectGarbageRepetitionAttempts; i++){
	wait(100);
	//run("Collect Garbage");
	call("java.lang.System.gc");
	}
	if(collectGarbageShowLogMessage) print("...Collecting Garbage...");
	collectGarbageCurrentIndex = 1;
	setBatchMode(true);
	} else collectGarbageCurrentIndex++;
}



print("accessed1");
main(false);



//eval("script", "System.exit(0);");

