


function open_image(imPath,file,roiPath,roiFile,subtract){
	open(imPath+"\\"+file);
	subtract_background(roiPath, roiFile,subtract);
}

function subtract_background(roiPath, roiFile, subtract){
	roiManager("open", roiPath+"\\"+roiFile);
	roiManager("Select",0);
	run("Clear Outside");
	if(subtract == "False"){
		print("No Subtraction...");
	} else {
		run("Subtract Background...", "rolling="+subtract);
	}
	
}

function threshold(thresh_method){
	setAutoThreshold(thresh_method+" dark");
}

function process_section(erode,lowerSize){
	run("Make Binary");
	if( erode == "True"){
		run("Erode");
	}
	roiManager("Delete");
	run("Analyze Particles...", "size="+lowerSize+"-Infinity display clear include add");
	//run("Measure");
}

function save_data(outputDir,outF){
	//roiManager("Select", array(1
	//filename = replace(filename,".tif","");
	saveAs("Results", outputDir + "\\" + outF + ".txt");
	print("data saved...");
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

function reset_(){
	run("Clear Results");
	collectGarbageIfNecessary();
	close_windows();
}

function main(){
	setBatchMode(true);
	args = getArgument();
	inputs = split(args,"@");
	inputDir = inputs[0];
	outputDir = inputs[1];
	roiDir = inputs[2];
	threshType = inputs[3];
	subtract = inputs[4];
	erode = inputs[5];
	lowersize = inputs[6];
	
	filelist = getFileList(inputDir);
	for(f=0; f < filelist.length; f++){
		file = filelist[f];
		print(file);
		outF = replace(file,".tif","");
		//date, ID, treat, target, section
		f_ = split(file,"_");
		roiFile = f_[1] + "_" + f_[2] + "_hippocampus_"+f_[4];
		if(f_[4] == "sec1.tif"){
			print("skip sec1");
		} else {
			roiFile = replace(roiFile,".tif",".roi");
			print(roiFile);
			open_image(inputDir, file, roiDir, roiFile,subtract);
			threshold(threshType);
			process_section(erode,lowersize);
			save_data(outputDir, outF);
			wait(10000);
			reset_();
		}
		
	}
	setBatchMode(false);

	eval("script", "System.exit(0);");
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
setBatchMode(false);
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
setBatchMode(true);
}else collectGarbageCurrentIndex++;
}

main();