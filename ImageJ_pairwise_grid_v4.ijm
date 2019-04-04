print("...opened imageJ_pairwsie_grid_v4 macro...")


/*
 * This code thresholds the image,
 * creates a rectangle of a defined height and width
 * measures the intensity and IntDen
 */
function grid_segment_and_save(output, filename, startX, startY, gridX, gridY){

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

	save_image(output,filename,x,y);
	reset_(count);
	
}

function threshold(startX,startY,lower_upper,threshtype,subtract,despeck,ref_treatment){
	if(subtract == "True"){
		run("Subtract Background...", "rolling=100");
	}
	if(despeck == "True"){
		run("Despeckle");	
	}
	thresh = threshtype;
	if( (startX == 0) & (startY== 0) ){
		//measure background
		if(ref_treatment=="True"){
			setAutoThreshold(thresh);
			run("Measure");
			setAutoThreshold(thresh+" dark");
			run("Measure");
			getThreshold(lower,upper);
			return newArray(lower,upper);
		} else{
			getMinAndMax(min,max);
			setAutoThreshold(thresh);
			run("Measure");
			setThreshold(lower_upper[0],max);
			run("Measure");
			return lower_upper;
		}
		
	} else {
		if (ref_treatment=="True"){
			setAutoThreshold(thresh+" dark");
			getThreshold(lower,upper);
			return newArray(lower,upper);
		} else {
			getMinAndMax(min,max);
			setThreshold(lower_upper[0],max);
			return lower_upper;
		}
	}
}

function save_image(output,filename,x,y){
	//roiManager("Select", array(1
	filename = replace(filename,".tif","");
	saveAs("Results", output + filename +"_"+toString(x)+"-"+toString(y)+".txt");
}

function reset_(count){
	IJ.deleteRows(0,count+2);
	close();
	collectGarbageIfNecessary();
}

function write_threshold_file(lower_upper,file,outputD){
	outputD = outputD+"\\";
	f = File.open(outputD+file);
	print(f,toString(lower_upper[0]));
	print(f,"_");
	print(f,toString(lower_upper[1]));
	File.close(f);
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


function main(){

	print("BEGIN IMAGEJ MACRO");


	/*
	 * This code deals with opening the relevant files for processing, and retrieving the gridsize from the commandline arugments
	 * 
	 */
	setBatchMode(true);
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit nan redirect=None decimal=3");

	gridsize = getArgument();
	iArgs = split(gridsize, '=');
	XY=iArgs[0]
	offset=iArgs[1];
	inputDir = iArgs[2];
	outputDir = iArgs[3];
	threshDir = iArgs[4];
	threshType = iArgs[5];
	subtract_background = iArgs[6];
	despeckle = iArgs[7];
	ref_treatment = iArgs[8];
	exp_treatment = iArgs[9];
	pairwise = iArgs[10];
	input=inputDir+"\\";
	output=outputDir+"\\";
	print(input);
	print(output);
	 
	filelist = getFileList(input);
	Array.print(filelist);
	if (pairwise == "True"){
		if (offset == "True"){
			print(filelist.length);
			for(i=0; i < filelist.length; i++){
				file_inputs= split(filelist[i],"_");
				Array.print(file_inputs);
				mID=file_inputs[0];
				day=file_inputs[1];
				cond=file_inputs[2];
				cell=file_inputs[3];
				sec = replace(file_inputs[4],".tif","");
				if( cond == ref_treatment){
					for(z=0;z<2;z++){
						for(j=0;j<2;j++){
							startX =((parseInt(XY)/2) * z);
							startY =((parseInt(XY)/2) * j);
			
							//noFUS
							F = toString(mID)+"_"+toString(day)+"_"+ref_treatment+"_"+toString(cell)+"_"+toString(sec);
							open(input+F+".tif");	
							lower_upper=threshold(startX,startY,0,threshType,subtract_background,despeckle,"True");
							write_threshold_file(lower_upper,F+".txt",threshDir);
							grid_segment_and_save(output, F, startX, startY, XY, XY);
							//FUS
							F = toString(mID)+"_"+toString(day)+"_" + exp_treatment + "_"+toString(cell)+"_"+toString(sec);
							open(input+F+".tif");	
							lower_upper=threshold(startX,startY,lower_upper,threshType,subtract_background,despeckle,"False");
							write_threshold_file(lower_upper,F+".txt",threshDir);
							grid_segment_and_save(output, F, startX, startY, XY, XY);
								//save_image(output,F,startX,startY);
								//reset_();
						}
					/*
					for (i = 0; i < alist.length; i++){
						startX = (parseInt(XY[0])/2) * z;
						startY = (parseInt(XY[1])/2) * j;
						grid_segment(input, output, alist[i], startX, startY, XY[0], XY[1]);
						//save_image(output,alist[i],startX,startY);
						//reset_();
					}*/
					}
				}
				
			}
		} else {
			print("NOT IMPLEMENTED");
			/*
			for (i = 0; i < filelist.length; i++){
				grid_segment(input, output, filelist[i], 0, 0, XY, XY);
				
				//save_image(output,alist[i]),0,0);
				//reset_();
			
			}
			*/
		}
	} else {
		if (offset == "True"){
			print(filelist.length);
			for(i=0; i < filelist.length; i++){
				file_inputs= split(filelist[i],"_");
				Array.print(file_inputs);
				mID=file_inputs[0];
				day=file_inputs[1];
				cond=file_inputs[2];
				cell=file_inputs[3];
				sec = replace(file_inputs[4],".tif","");
				for(z=0;z<2;z++){
					for(j=0;j<2;j++){
						startX =((parseInt(XY)/2) * z);
						startY =((parseInt(XY)/2) * j);
		
						//noFUS
						F = toString(mID)+"_"+toString(day)+"_"+cond+"_"+toString(cell)+"_"+toString(sec);
						open(input+F+".tif");	
						lower_upper=threshold(startX,startY,0,threshType,subtract_background,despeckle,"True");
						write_threshold_file(lower_upper,F+".txt",threshDir);
						grid_segment_and_save(output, F, startX, startY, XY, XY);
					}
				}	
			}
		} else {
			print("NOT IMPLEMENTED");
			}
		



		}
	setBatchMode(false);
}

main();




eval("script", "System.exit(0);");
