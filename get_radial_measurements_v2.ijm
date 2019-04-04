//Global variables
var collectGarbageInterval = 5; // the garbage is collected after n Images
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

function print_instructions(){
	showMessage("To use this macro, use the point tool to choose a new point, add the selection area as the first selection in the roimanager for proper thresholding");
}

function get_center(){
	s = selectionType();
	if( s == -1 ) {
		print_instructions();
	    exit("There was no selection.");
	    
	} else if( s != 10 ) {
		print_instructions();
	    exit("The selection wasn't a point selection.");
	    
	} else {
	    getSelectionCoordinates(xPoints,yPoints);
	    pointX = xPoints[0];
	    pointY = yPoints[0];
	    _ = newArray(pointX,pointY);
	    return _;
	}
}

//X, Y is center
function make_circle(x,y,radius){
	topX = x - (radius/2);
	topY = y - (radius/2);
	makeOval(topX,topY,radius,radius);	
}

function iter_circles_and_measure(X,Y,radius,n,lower,upper,mainWindow,measurement,ground){
	for (i=1; i<(n+1); i++){
		selectWindow(mainWindow);
		//run("Duplicate...", "title=iter_circle.tif");
		//selectWindow("iter_circle.tif");
		wait(5);
		make_circle(X,Y,radius*i);

		row = i - 1;
		value = radius * i;
		/*
		if(i > 1){
			wait(5);			
		}*/
		if(measurement == "measure"){
			if( ground == "foreground") {
				threshold_measure(lower,upper);
			} else if (ground == "background") {
				area_measure(upper);
			}
			setResult("radius_iter", row , value);
			updateResults();

			
		} else if (measurement == 'soma'){
			print();
		} else if (measurement == 'NND'){
			print();
		} else if (measurement == 'skeleton'){
			print();
		}
		/*
		if( i <= n){
			close();
		};*/
		
	}
}

function threshold_measure(lower,upper){
	//roiManager("Select", 0);
	setThreshold(lower, upper);
	run("Measure");
}

function area_measure(upper){
	//roiManager("Select", 0);
	setThreshold(5,upper);
	run("Measure");
}

function threshold(){
	roiManager("Select", 0);
	setAutoThreshold("Li dark");
	getThreshold(lower,upper);
	_ = newArray(lower,upper);
	return _;
}

function save_results(numpoint,path,filename){
	saveAs("Results", path+filename+"_"+toString(numpoint)+".txt");
	if (isOpen("Results")) { 
       selectWindow("Results"); 
       run("Close"); 
   } 	
}

function per_file_execution(xy_coord_dir, output_dir, file, radius, n, measurement){
	roiManager("Add"); //add background roi
	windowTitle = getTitle();
	f_name = replace(windowTitle,".tif","");
	add_points(xy_coord_dir,f_name + ".txt");
	N = roiManager("Count");
	print(N);
	if( N > 1) {
		run("Subtract Background...", "rolling=100");
		lower_upper = threshold();
		lower = lower_upper[0];
		upper = lower_upper[1];
		for (i = 1; i < N; i++){
			run("Clear Results");
			XY = get_point_XY(i);
			run("Clear Results");
			centerX = XY[0];
			centerY = XY[1];
			iter_circles_and_measure(centerX,centerY,radius,n,lower,upper,windowTitle,measurement,"foreground");
			save_results(i,output_dir+"foreground\\",f_name);
			iter_circles_and_measure(centerX,centerY,radius,n,lower,upper,windowTitle,measurement,"background");
			save_results(i,output_dir+"background\\",f_name);
		}
		clear_roi_manager(0);

	} else {
		roiManager("Delete");
	}
	close();
	
}
function get_point_XY(roi_id){
	roiManager("Select",roi_id);
	roiManager("Measure");
	X = getResult("X",0) * 1.5; //scale for 20x image is 1.5
	Y = getResult("Y",0) * 1.5;
	return newArray(X,Y);
}

function clear_roi_manager(start_clear){
	while(N > start_clear) {
			roiManager("Select",0);
			roiManager("Delete");
			N = roiManager("count");
		}
}

function add_points(xy_coord_dir,fname){
	print("called add points");
	lineseparator = "\n";
    cellseparator = ",\t";
	lines=split(File.openAsString(xy_coord_dir+fname), lineseparator);
	if(lines.length > 1){
		labels=split(lines[0], cellseparator);
		if (labels[0]==" ")
	        k=1; // it is an ImageJ Results table, skip first column
	     else
	        k=0; // it is not a Results table, load all columns
	     for (j=k; j<labels.length; j++)
	        setResult(labels[j],0,0);
	
	        // dispatches the data into the new RT
	     run("Clear Results");
	     for (i=1; i<lines.length; i++) {
	        items=split(lines[i], cellseparator);
	        for (j=k; j<items.length; j++)
	           setResult(labels[j],i-1,items[j]);
	     }
	     updateResults();
	 for(l=0; l < lines.length-1; l++){
	 	 X = getResult("X",l) * 1.5; //scale for 20x image is 1.5
	     Y = getResult("Y",l) * 1.5;
	     makePoint(X, Y);
	     roiManager("Add");
	     }
     
	} else {
		print("no points");
	}
}



function main(bool){
	if(bool == true){
		setBatchMode(true);
	}
	input_dir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_batch_microglia_astrocyte_7D\\";
	xy_coord_dir =  "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\microglia_astrocyte_7D_output\\whole_output\\radial_analysis\\centers\\microglia\\";
	output_dir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\microglia_astrocyte_7D_output\\whole_output\\radial_analysis\\features\\";
	radius = 150;
	n = 20;
	measurement = "measure";

	
	files = getFileList(input_dir);
	end = files.length;
	//end = 2;
	for (i=0;i<end;i++){
		file = files[i];
		open(input_dir+file);
		per_file_execution(xy_coord_dir,output_dir,file,radius,n,measurement);
		collectGarbageIfNecessary();
	}
	if(bool == true){
		setBatchMode(false);
	}
}


main(false);


/*
setBatchMode(true);
windowTitle = getTitle();
print(windowTitle);
xy = get_center();
centerX = xy[0];
centerY = xy[1];
radius=200;


run("Subtract Background...", "rolling=100");
lower_upper = threshold();
lower = lower_upper[0];
upper = lower_upper[1];
n=20;
measurement='measure';
iter_circles_and_measure(centerX,centerY,radius,n,lower,upper,windowTitle,measurement);
pointID = 1;
path = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\microglia_astrocyte_7D_output\\whole_output\\radial_analysis\\features\\microglia\\";
filename = replace(windowTitle,".tif","");
print(filename);
save_results(pointID,path,filename);
setBatchMode(false);
//make_circle(centerX,centerY,radius);




//makeOval(x, y, 569, 569);
*/