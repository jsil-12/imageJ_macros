function threshold(startX,startY,lower_upper,treatment,threshtype,subtract,despeck){
	if(subtract == "True"){
		run("Subtract Background...", "rolling=100");
	}
	if(despeck == "True"){
		run("Despeckle");	
	}
	thresh = threshtype;
	setAutoThreshold(thresh);
	run("Measure");
	setAutoThreshold(thresh+" dark");
	run("Measure");
	getThreshold(lower,upper);
	return newArray(lower,upper);
}

function grid_segment(startX, startY, gridX, gridY){

	//open("C:\\Users\\joey\\Documents\\LabWork\\imageJ_pics\\Gfap_Iba1_Ki67\\16.5.5_xyz_clustering\\1D_FUS_microglia.tif");
	x = startX; 
	y = startY;
	picWidth = getWidth();
	picHeight = getHeight();
	tW = gridX;
	tH = gridY;
	nX = ( picWidth - x ) / tW;
	nY = ( picHeight - y ) / tH;
	count = 0;
		
	for(i = 0; i < nY; i++){
		offsetY = y + (i * tH);
		//print(offsetY);
		for(j=0;j < nX; j++){
			offsetX = x + (j * tW);
			print(offsetX);
			makeRectangle(offsetX, offsetY, tW, tH);
			roiManager("Add");
			roiManager("Select", 0);
			//roiManager("Select", count);
			roiManager("Measure");
			roiManager("Delete");
			count++;
		}
	}
}

function write_threshold_file(lower_upper,file,outputD){
	outputD = outputD+"\\";
	f = File.open(outputD+file);
	print(f,toString(lower_upper[0]));
	print(f,"_");
	print(f,toString(lower_upper[1]));
	File.close(f);
}

function save_image(output,filename,x,y){
	//roiManager("Select", array(1
	//filename = replace(filename,".tif","");
	saveAs("Results", output + filename +"_"+toString(x)+"-"+toString(y)+".txt");
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
	//roiManager("Delete");
	close_windows();
	collectGarbageIfNecessary();
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
}else collectGarbageCurrentIndex++;
}

function main(){
	setBatchMode(true);
	inputs = getArgument();
	iArgs = split(inputs, "@");
	Array.print(iArgs);
	XY=iArgs[0]
	offset=iArgs[1];
	inputDir = iArgs[2];
	outputDir = iArgs[3];
	threshDir = iArgs[4];
	threshType = iArgs[5];
	subtract_background = iArgs[6];
	despeckle = iArgs[7];
	input=inputDir+"\\";
	output=outputDir+"\\";
	print(input);
	print(output);
	filelist = getFileList(input);
	Array.print(filelist);
	
	if(offset == "True"){
		print("not implemented");
	} else{
		startX = 0;
		startY = 0;
		for(i=0; i < filelist.length; i++){
			//open image
			f = filelist[i];
			fname = replace(f,".tif","");
			open(input+f);
			if(threshType == "None"){
				print("no threshold");
			} else{
				lower_upper=threshold(startX,startY,0,"noFUS",threshType,subtract_background,despeckle);
				write_threshold_file(lower_upper,fname+".txt",threshDir);
			}
			
			
			grid_segment(startX, startY, XY, XY);
			save_image(output,fname,startX,startY);
			reset_();
		}
	}
	setBatchMode(false);
	eval("script", "System.exit(0);");
	
}

main();

