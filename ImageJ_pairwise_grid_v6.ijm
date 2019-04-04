print("...opened imageJ_pairwsie_grid_v5 macro...");


/*
 * This code thresholds the image,
 * creates a rectangle of a defined height and width
 * measures the intensity and IntDen
 */
function grid_segment(startX, startY, gridX, gridY, particles, scale){

	//open("C:\\Users\\joey\\Documents\\LabWork\\imageJ_pics\\Gfap_Iba1_Ki67\\16.5.5_xyz_clustering\\1D_FUS_microglia.tif");
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
	count = 0;
	//scale = 1.5;
	nextStop=false;
		
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
			//roiManager("Measure");

			if(particles){
				run("Analyze Particles...", "add");
				roiManager("Select", 0);
				roiManager("Delete");
				
				if(roiManager("count") > 0){
					if(roiManager("count") > 1){
						combine_roi_manager();
					}
					
					last = roiManager("count");
					roiManager("Select", last-1);
					roiManager("measure");
					clear_roi_manager();
	
					row = Table.size - 1;
					Table.set("BX", row, offsetX/scale);
					Table.set("BY", row, offsetY/scale);
					print("======================");
					print(row);
					print(offsetX);
					print(offsetY);
					Table.update;
				}
			} else {
				run("Measure");
				roiManager("Select", 0);
				roiManager("Delete");
			}
			count++;
		}
	}
}

function threshold(lower_upper,threshtype,subtract,subtract_amount,despeck,contrast,auto_thresh){
	if(subtract == true){
		run("Subtract Background...", "rolling="+subtract_amount);
	}
	if(despeck == true){
		run("Despeckle");	
	}
	if(contrast == true){
		run("Enhance Contrast...", "saturated=0.3 normalize");
	}
	thresh = threshtype;
	//measure background
	if(auto_thresh==true){
		setAutoThreshold(thresh);
		run("Measure"); // takes background section mesaurements
		setResult("ground",0,"background");
		setAutoThreshold(thresh+" dark");
		run("Measure"); // takes foreground section measurements
		setResult("ground",1,"foreground");
		getThreshold(lower,upper);
		return newArray(lower,upper);
	} else{
		getMinAndMax(min,max); // establish min and max pixel value
		setAutoThreshold(thresh);
		run("Measure"); // takes background section mesaurements
		setResult("ground",0,"background");
		setThreshold(lower_upper[0],max);
		setResult("ground",1,"foreground");
		run("Measure"); // takes foreground section measurements
		return lower_upper;
	}
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
	
	//iArgs = split(gridsize, '=');
	XY=150 //box pixel size
	offset=true; //whether add an offset
	numOffsets=2; //denotes level of overlap.. 2 = 50%, 3 = 66.6% overlap
	//input = "D:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap/";//input image directory
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap_redoBASIC/";
	//input = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_S100b_Nestin\\input_batch_gfap_redoBASIC\\";
	input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_retiled_batch/";
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_redo_fus/";
	
	
	output = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/features/150/"; //output features textfile directory
	threshDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/threshold_files/"; //directory to output recorded lower / upper threshold values
	threshType = "Triangle"; //method to use for thresholding
	subtract_background = true; //subtract background
	subtract_by = "100"; // amount to subtract by -- input as string for imageJ to interpret
	despeckle = false; // apply 1 round of despeckling
	ref_treatment = "noFUS"; //only used if pairwise == True, uses ref_treatment section as to assess threshold values and apply to treatment
	exp_treatment = "FUS";
	particles = false;
	contrast = true;
	scale = 1.5;
	
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
			lower_upper=threshold(0,threshType,subtract_background,subtract_by,despeckle,contrast,true);
			write_threshold_file(lower_upper,F+".txt",threshDir);
			
			for(z=0;z<2;z++){
				for(j=0;j<2;j++){
					startX =((parseInt(XY)/2) * z);
					startY =((parseInt(XY)/2) * j);
					grid_segment(startX, startY, XY, XY, particles, scale);
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

main();




//eval("script", "System.exit(0);");
