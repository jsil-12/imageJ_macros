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










function grid_measure(startX,startY,gridX,gridY){
	x = startX; 
	y = startY;
	picWidth = getWidth();
	picHeight = getHeight();
	tW = gridX;
	tH = gridY;
	
	print(tW);
	print(tH);
	
	nX = ( picWidth - x ) / tW;
	nY = ( picHeight - y ) / tH;
	//scale = 1.5;
	nextStop=false;

	closeWindows = newArray("1","2");
	row = nResults;
	print("===============");
	print(row);
	print("===============");
	
	for(i = 0; i < nY; i++){
		offsetY = y + (i * tH);
		for(j=0;j < nX; j++){
			offsetX = x + (j * tW);
			makeRectangle(offsetX, offsetY, tW, tH);
			setThreshold(1, 255);
			run("Measure");
		}
	}
}

function save_data(output_dir,output_file){
	saveAs("Results", output_dir+"/"+output_file+".csv");
}

function reset_all(){
	run("Clear Results");
	clear_roi_manager();
	close_windows();
	collectGarbageIfNecessary();
}

function clear_roi_manager(){
	if (roiManager("count") > 0) {
		roiManager("deselect");
		roiManager("Delete");
	}
	
}

function close_windows(){
	while (nImages>0) { 
          selectImage(nImages); 
          close(); 
    }
    /*
	list = getList("window.titles"); 
	for (i=0; i<list.length; i++){ 
	winame = list[i]; 
		selectWindow(winame); 
	run("Close"); 
	}*/
}

function main(batchmode){
	setBatchMode(batchmode);
	//input = "E:/Mali's script/GFP_BINARY_IMG/Cleaned/";
	input = "E:/Mali's script/Plaque mask/";
	//output_dir = "E:/Mali's script/GFP_measure_output/"";
	output_dir = "E:/Mali's script/plaque_mask_output/";
	
	filelist = getFileList(input);
	startX = 0;
	startY = 0;
	grid_size = 300;
	
	for(i=0;i<filelist.length;i++){
		file = filelist[i];
		full_img_path = input+"/"+file;
		output_file = replace(file,".tif","");
		open(full_img_path);
		run("Make Binary");
		grid_measure(startX,startY,grid_size,grid_size);
		save_data(output_dir,output_file);
		reset_all();
	}
	print("FINISHED SCRIPT");
}

main();