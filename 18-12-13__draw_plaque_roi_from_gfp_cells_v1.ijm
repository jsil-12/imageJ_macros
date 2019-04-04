/*
 * joey test code
 * 
path = "C:/Users/joey_/Desktop/";
file = "MAX_Section2-GFP-labeled-skeletons.txt";
file = "MAX_Section2-GFP only-GFP488-Abetacy3-Zstack-2tiles-10x-left HF.cz...ion2-GFP only-GFP488-Abetacy3-Zstack-2tiles-10x-left HF.czi #1 - C=0-1.txt";
coords = File.openAsString(path+file);
*/

nn = 0;
scale=1.0;

coord_input = "G:/spinning disk/Jan3 2019-GFP-Plaques-PVcam 20x/Finalized ready for quantify- Jan 29 2019/GFP_BINARY_XY_COORDS/";
img_input = "G:/spinning disk/Jan3 2019-GFP-Plaques-PVcam 20x/Finalized ready for quantify- Jan 29 2019/GFP_BINARY_IMG/";
output = "G:/spinning disk/Jan3 2019-GFP-Plaques-PVcam 20x/Finalized ready for quantify- Jan 29 2019/GFP_ROIs/";
radius = 100; //100/1.5 = 66.6um

setBatchMode(false);
files = getFileList(img_input);
Array.print(files);
for(f=0; f<files.length; f++){
	file = files[f];
	open(img_input+"/"+file);
	coord_file = replace(file,".tif",".txt");
	roi_file = replace(file,".tif",".roi");
	coords = File.openAsString(coord_input+"/"+coord_file);
	ea_coord = split(coords, "\n");
	for(i=0;i<ea_coord.length;i++){
		arr = split(ea_coord[i],"\t");
		Array.print(arr);
		x = arr[0];
		y = arr[1];
		//makePoint(x*scale, y*scale);
		makeOval(x*scale, y*scale, radius, radius);
		roiManager("add");
		/*
		if(nn == 1000){
			stop;
		}*/
		nn++;
	}
	print("...combining...");
	roiManager("deselect");
	roiManager("combine");
	print("combined");
	roiManager("add");
	
	last_index = roiManager("count");
	roiManager("select",last_index-1);
	roiManager("Save", output+"/"+roi_file);
	roiManager("deselect");
	roiManager("delete");

	for(z=1;z<nImages+1;z++){
		selectImage(z);
		close();
	}
	collectGarbageIfNecessary();

setBatchMode(false);

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