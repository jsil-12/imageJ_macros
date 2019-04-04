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
	saveAs("Results", output + "data\\"+filename +"_"+toString(x)+"-"+toString(y)+".txt");
}

function set_threshold(file,threshdir){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	print(threshdir+"\\"+file);
	F=File.openAsString(threshdir+"\\"+file);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}

function threshold_binary(file,threshdir,subtract,despeck){
	if(subtract == "True"){
		run("Subtract Background...", "rolling=100");
	}
	if(despeck == "True"){
		run("Despeckle");
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



function set_binary(file,input,output,txtfile,threshdir){
	open(input+file);
	threshold_binary(txtfile,threshdir,subtract_background,despeckle);
	saveAs("Tiff",output+file);
	close();
	open(output+file);
	}

function check_if_fractal(){
	result = false;
	getStatistics(area, mean);
	if(mean > 0.1){
		result=true;
	}
	return result;
}



/*
 * This code deals with opening the relevant files for processing, and retrieving the gridsize from the commandline arugments
 * 
 */

 
setBatchMode(true);


//inputPath = "C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\";
//outputPath = "C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\";

gridsize = getArgument();
iArgs = split(gridsize, '=');
Array.print(iArgs);
XY=iArgs[0];
offset=iArgs[1];
inputDir = iArgs[2];
outputDir = iArgs[3];
threshDir = iArgs[4];
subtract_background = iArgs[5];
despeckle = iArgs[6];


input=inputDir+"\\";
output=outputDir+"\\";
binary_dir = output+"binary_images\\"
print(input);
print(output);
 
filelist = getFileList(input);
Array.print(filelist);
//IDs = newArray("JS7");
//days = newArray("4D");
//treatments = newArray("noFUS","FUS");
//cells = newArray("astrocyte");

//print(alist[0]);
if (offset == "True"){
	for(i=0; i < filelist.length; i++){
		file_inputs= split(filelist[i],"_");
		textfile=replace(filelist[i],".tif",".txt");
		filename=replace(filelist[i],".tif","");
		Array.print(file_inputs);
		for(z=0;z<2;z++){
			for(j=0;j<2;j++){
				/*
				mID=file_inputs[0];
				day=file_inputs[1];
				cond=file_inputs[2];
				cell=file_inputs[3];
				sec = replace(file_inputs[4],".tif","");
				*/
				startX =((parseInt(XY)/2) * z);
				startY =((parseInt(XY)/2) * j);
				toOpen=input+filelist[i];
				set_binary(filelist[i],input,binary_dir,textfile,threshDir);	
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



setBatchMode(false);

eval("script", "System.exit(0);");
