print("...opened imageJ_pairwsie_grid_v5 macro...");


/*
 * This code thresholds the image,
 * creates a rectangle of a defined height and width
 * measures the intensity and IntDen
 */

function grid_threshold_segment_measure(startX,startY,gridX,gridY,scale,threshtype,radius,apply_threshold){
	x = startX; 
	y = startY;
	picWidth = getWidth();
	picHeight = getHeight();
	tW = gridX;
	tH = gridY;
	//radius=60;
	
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
		//print(offsetY);
		for(j=0;j < nX; j++){
			offsetX = x + (j * tW);

			makeRectangle(offsetX, offsetY, tW, tH);
			run("Duplicate...", "title=1");
			run("Duplicate...", "title=2");
			selectWindow("1");
			getStatistics(area,mean);
			print(mean);
			if(mean > 1 ){
				if(apply_threshold){
					threshold(threshtype, radius);
				}
				run("Create Selection");
				roiManager("Add");
				nROI = roiManager("count");
				
				selectWindow("2");
				roiManager("select", nROI-1);
				roiManager("measure");
				
				//delete roi manager
				roiManager("deselect");
				roiManager("delete");

				Table.set("BX", row, offsetX/scale);
				Table.set("BY", row, offsetY/scale);
				row++;
			}
			for(n=0;n<closeWindows.length;n++){
				selectWindow(closeWindows[n]);
				close();
			}
		}
	}
	Table.update;
}


function threshold(threshtype,radius){
	thresh = threshtype;
	run("8-bit");
	run("Auto Local Threshold", "method="+threshtype+" radius="+radius+" parameter_1=0 parameter_2=0 white");
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

function background_foreground_measurements(thresh){
	setAutoThreshold(thresh);
	run("Measure"); // takes background section mesaurements
	setResult("ground",0,"background");
	setAutoThreshold(thresh+" dark");
	run("Measure"); // takes foreground section measurements
	setResult("ground",1,"foreground");
	resetThreshold();
}

function combine_roi_manager(){
	array1 = newArray("",toString(0));
	print(roiManager("count"));
	for (i=1;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Combine");
	roiManager("Add");
}

function clear_roi_manager(){
	array1 = newArray("",toString(0));
	for (i=1;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
	} 
	roiManager("select", array1); 
	roiManager("Delete");
}

function save_image(output,filename,extra){
	//roiManager("Select", array(1
	filename = replace(filename,".tif","");
	//IJ.renameResults("Summary","Results");
	saveAs("Results", output + filename +"_"+extra+".txt");
}

function reset_(){
	run("Clear Results");
	close();
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
	} else collectGarbageCurrentIndex++;
}


function main(batch){

	print("BEGIN IMAGEJ MACRO");


	/*
	 * This code deals with opening the relevant files for processing, and retrieving the gridsize from the commandline arugments
	 * 
	 */
	setBatchMode(batch);
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit nan redirect=None decimal=3");
	
	//iArgs = split(gridsize, '=');
	XY=100 //box pixel size
	offset=true; //whether add an offset
	numOffsets=2; //denotes level of overlap.. 2 = 50%, 3 = 66.6% overlap
	//input = "D:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap/";//input image directory
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap_redoBASIC/";
	//input = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_S100b_Nestin\\input_batch_gfap_redoBASIC\\";
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_v3_extra2/";
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_redo_fus/";

	input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_v3_all/";
	//input = "E:/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/";

	_dir = "E"
	//input = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/"
	//output = _dir+":/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/feature_files/single_threshold/features/150/"
	
	
	output = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/feature_files/single_threshold/features/"+toString(XY); //output features textfile directory
	//threshDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/threshold_files/"; //directory to output recorded lower / upper threshold values
	local_thresh_type = "Phansalkar"; //"Phansalkar"; //Niblack for microglia
	radius = 60;
	
	subtract_background = true; //subtract background
	subtract_by = "100"; // amount to subtract by -- input as string for imageJ to interpret
	despeckle = true; // apply 1 round of despeckling
	contrast = true;
	scale = 1.5;

	background_threshold = "Otsu";
	grid_wise_threshold=true;

	//threshold_whole_image=true;
	
	print(input);
	print(output);
	
	filelist = getFileList(input);
	Array.print(filelist);
	//stop;
	
	if (offset == true){
		print(filelist.length);
		for(i=0; i < filelist.length; i++){
			file_inputs= split(filelist[i],"_");
			Array.print(file_inputs);
			//pre-determined naming structure for file -- files are named as [mouseID]_[treatmentDay]_[treatmentCondition]_[IFTarget]_[section].txt
			mID=file_inputs[0];
			day=file_inputs[1];
			cond=file_inputs[2];
			cell=file_inputs[3];
			sec = replace(file_inputs[4],".tif","");
			
			F = toString(mID)+"_"+toString(day)+"_"+cond+"_"+toString(cell)+"_"+toString(sec);
			open(input+F+".tif");

			//threshold(threshtype,subtract,subtract_amount,despeck,contrast)
			correct_image(subtract_background,subtract_by,despeckle,contrast);
			background_foreground_measurements(background_threshold);

			for(z=0;z<2;z++){
				for(j=0;j<2;j++){
					startX =((parseInt(XY)/2) * z);
					startY =((parseInt(XY)/2) * j);
					grid_threshold_segment_measure(startX,startY,XY,XY,scale,local_thresh_type,radius,grid_wise_threshold);
				}
			}
			save_image(output,F,"150x150");
			reset_();
		}
	} else {
		print("NOT IMPLEMENTED");
		}

	setBatchMode(false);
}

main(true);




//eval("script", "System.exit(0);");
