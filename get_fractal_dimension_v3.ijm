/*
 * This code thresholds the image,
 * creates a rectangle of a defined height and width
 * measures the intensity and IntDen
 */
 
function grid_segment(input, output, filename, startX, startY, gridX, gridY){
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
			//print(offsetX);
			makeRectangle(offsetX, offsetY, tW, tH);
			roiManager("Add");
			//roiManager("Select", 0);
			//roiManager("Select", count);
			frac_check = check_if_fractal();
			//print(frac_check);
			run("Measure");
			count++;
			if(frac_check){
				fractal_box();
				count++;
			}
			roiManager("Delete");
		}
	}
	save_image(output,filename,x,y);
	reset_(count);
	print("...reset...");
}

function save_image(output,filename,x,y){
	//roiManager("Select", array(1
	saveAs("Results", output +filename +"_"+toString(x)+"-"+toString(y)+".txt");
}

function set_threshold(file,threshdir){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	print(threshdir+"\\"+file);
	F=File.openAsString(threshdir+"\\"+file);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}

function threshold_binary(file,threshdir,subtract,despeck,contrast){
	if(subtract == true){
		run("Subtract Background...", "rolling=100");
	}
	if(despeck == true){
		run("Despeckle");
	}
	if(contrast == true) {
		run("Enhance Contrast...", "saturated=0.3 normalize");
	}
	
	set_threshold(file,threshdir);
	setOption("BlackBackground", true);
	run("Make Binary");
}

function reset_(count){
	IJ.deleteRows(0,count+2);
	close();
	collectGarbageIfNecessary();
}

function fractal_box(){
	run("Clear Outside");
	roiManager("Select", 0);
	run("Crop");
	//IJ.redirectErrorMessages();
	run("Fractal Box Count...", "box=2,3,4,6,8,12,16,32,64 black");
	close();
	run("Revert");
}



function set_binary(file,output){
	saveAs("Tiff",output+file);
	close();
	open(output+file);
}

function process_image(file,txtfile,input,threshdir,subtract_background,despeckle,contrast){
	open(input+file);
	threshold_binary(txtfile,threshdir,subtract_background,despeckle,contrast);
}

function check_if_fractal(){
	result = false;
	getStatistics(area, mean);
	if(mean > 0.1){
		result=true;
	}
	return result;
}


//Global variables

var collectGarbageInterval = 2; // the garbage is collected after n Images
var collectGarbageCurrentIndex = 1; // increment variable for garbage collection
var collectGarbageWaitingTime = 100; // waiting time in milliseconds before garbage is collected
var collectGarbageRepetitionAttempts = 3; // repeats the garbage collection n times
var collectGarbageShowLogMessage = true; // defines whether or not a log entry will be made

//Functions

//-------------------------------------------------------------------------------------------
// this function collects garbage after a certain interval
//-------------------------------------------------------------------------------------------
function collectGarbageIfNecessary(){
	if(collectGarbageCurrentIndex == collectGarbageInterval){
		print("COLLECTING LOTS OF MOTHA FUCKIN GARBAGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
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

function main(batchmode){
	/*
	 * This code deals with opening the relevant files for processing, and retrieving the gridsize from the commandline arugments
	 * 
	 */

	 
	setBatchMode(batchmode);

	//inputPath = "C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\";
	//outputPath = "C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\";

	XY=150 //box pixel size
	offset=true; //whether add an offset
	numOffsets=2; //denotes level of overlap.. 2 = 50%, 3 = 66.6% overlap
	//input = "D:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap/";//input image directory
	//input = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_batch_images_gfap_redoTest/";
	
	input = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_S100b_Nestin\\input_gfap_redo_untreated2\\";
	output = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/fractal_dimension/datafiles/150/"; //output features textfile directory
	threshDir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/threshold_files/"; //directory to output recorded lower / upper threshold values
	binary_dir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/feature_files/single_threshold/fractal_dimension/images/"
	
	threshType = "Triangle"; //method to use for thresholding
	subtract_background = false; //subtract background
	subtract_by = "100"; // amount to subtract by -- input as string for imageJ to interpret
	despeckle = true; // apply 1 round of despeckling
	ref_treatment = "noFUS"; //only used if pairwise == True, uses ref_treatment section as to assess threshold values and apply to treatment
	exp_treatment = "FUS";
	pairwise = false;
	particles = false;
	contrast = true;
	//scale = 1.5; // 1.5 for BASIC corrected, 1.0 for ZEISS
	
	print(input);
	print(output);
	 
	filelist = getFileList(input);
	Array.print(filelist);
	
	if (offset == true){
		for(i=0; i < filelist.length; i++){
			file_inputs= split(filelist[i],"_");
			txtfile=replace(filelist[i],".tif",".txt");
			filename=replace(filelist[i],".tif","");
			Array.print(file_inputs);
			for(z=0;z<numOffsets;z++){
				for(j=0;j<numOffsets;j++){
					startX =((parseInt(XY)/numOffsets) * z);
					startY =((parseInt(XY)/numOffsets) * j);
					//toOpen=input+filelist[i];
					process_image(filelist[i],txtfile,input,threshDir,subtract_background,despeckle,contrast);
					set_binary(filelist[i],binary_dir);	
					grid_segment(input, output, filename, startX, startY, XY, XY);
				}
			}
		}
	} else {
		for (i = 0; i < filelist.length; i++){
			grid_segment(input, output, filelist[i], 0, 0, XY, XY);
			//save_image(output,alist[i]),0,0);
			//reset_();
		}
	}
	setBatchMode(false);
}



main(true);

//eval("script", "System.exit(0);");
