print("accessed cell count macro");
print("This macro will count microglia cell bodies");

setBatchMode(true);
//selectWindow("JS1_1D_noFUS_microglia_sec4.tif");
//roiManager("Add");


function count_cells(fname,output,threshold_path){
	run("Gray Scale Attribute Filtering", "operation=Opening attribute=Area minimum=25 connectivity=8");
	print("... Gray Filtering complete ...");
	run("Morphological Filters", "operation=Opening element=Octagon radius=1");
	print("... Morphological Filtering complete ...");
	//run("Threshold...");
	if(threshold_path == "None"){
		set_window(fname);
		setAutoThreshold("MaxEntropy dark");
		getThreshold(lower,upper);
		lower_upper = newArray(lower,upper);
		write_threshold_file(lower_upper,fname,output);
	} else {
		set_threshold(fname,threshold_path);
	}
	run("Make Binary");
	run("Analyze Particles...", "size=10-Infinity display clear include add");
	print("... analyzed particles complete ...");
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
	toselect=fname+"-attrFilt-Opening";
	selectWindow(toselect);
	roiManager("Select", 0);
}

function subtract_background(){
	run("Subtract Background...", "rolling=100");
}

function main(){
	print("accessed main");
	//InputDir, ourputDir
	_in = getArgument();
	inputArgs = split(_in,"@");
	inputDir = inputArgs[0];
	outputDir = inputArgs[1];
	threshold_path = inputArgs[2];
	subtract = inputArgs[3];
	
	filelist = getFileList(inputDir+"\\");
	for(f=0;f < filelist.length; f++){
		print(f);
		file = filelist[f];
		open_image(file,inputDir,threshold_path);
		if(subtract == "True"){
			subtract_background();
		}
		fname = replace(file,".tif","");
		count_cells(fname,outputDir,threshold_path);
		save_image(file,outputDir);
		reset_();
	}
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
main();

setBatchMode(false);

eval("script", "System.exit(0);");

