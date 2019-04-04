setBatchMode(true); 
print("Initiate re-cluster macro V2");

inputs = getArgument();
dirs = split(inputs,"@");
Array.print(dirs);
imagedir=dirs[1];
outputdir=dirs[2];
threshdir=dirs[3];
distal_cluster=dirs[4];
subtract=dirs[5];


print(imagedir);
print(outputdir);
print(threshdir);
print(distal_cluster);
clusterfiles=split(dirs[0],"=");
Array.print(clusterfiles);

//iter proximal/focal clusters

for(i=0;i<clusterfiles.length;i++){
	X=split(clusterfiles[i],"&");
	cl_type=X[1];
	dir=X[0]+"\\"+X[1];
	print(dir);
	wait(10000);
	
	
	clusterlist = getFileList(dir);
	//iter cluster files
	for(j=0;j<clusterlist.length;j++){
		count = 0;
		txt_file=clusterlist[j];
		tif_file=replace(txt_file,"txt","tif");
		//whole cluster
		open_image(imagedir+"\\"+tif_file,subtract);
		//open(imagedir+"\\"+tif_file);
		count=take_measures(txt_file,count,threshdir);
		boxes=open_cluster_file(dir,txt_file);
		if(boxes.length>0){
			make_clusters(boxes);
			merge_flatten();
			save_image(outputdir+"\\"+cl_type,"cluster_image",tif_file);
			close();
			clear_roi_manager("0",0);
			//cutout clusters
			open_image(imagedir+"\\"+tif_file,subtract);
			//open(imagedir+"\\"+tif_file);
			make_clusters(boxes);
			merge_clear_outside();
			count=take_measures(txt_file,count,threshdir);
			save_image(outputdir+"\\"+cl_type,"cutout",tif_file);
			clear_roi_manager("0",0);
		}
		save_data(outputdir+"\\"+cl_type,txt_file);
		reset_data(count);
		close();
		//measure distal clusters
		if(distal_cluster==cl_type ){ //=="combined\\"
			count=0;
			//open(imagedir+"\\"+tif_file);
			open_image(imagedir+"\\"+tif_file,subtract);
			count=take_measures(txt_file,count,threshdir);
			boxes=open_cluster_file(dir,txt_file);
			if(boxes.length>0){
				make_clusters(boxes);
				merge_clear();
				count=take_measures(txt_file,count,threshdir);
				save_image(outputdir+"\\distal","cutout",tif_file);
				clear_roi_manager("0",0);
				save_data(outputdir+"\\distal",txt_file);
				reset_data(count);
				close();
			} else {
				//count=take_measures(txt_file,count,threshdir);
				save_image(outputdir+"\\unclustered","cutout",tif_file);
				//clear_roi_manager("0",0);
				save_data(outputdir+"\\unclustered",txt_file);
				reset_data(count);
				close();
			}	
			
		}
		collectGarbageIfNecessary();
	}
//clusters=File.openAsString(
}
	
function open_cluster_file(dir,clusterfile){
	print(dir+"\\"+clusterfile);
	clusters=File.openAsString(dir+clusterfile);
	boxes=split(clusters,"=");
	return boxes;
}
//open image, subtract background
function open_image(file,subtract){
	open(file);
	if(subtract == "True"){
		run("Subtract Background...", "rolling=100");
	}
}

function make_square(box){
	//make polygon
	//Array.print(polyStr);
	X = box[0];
	Y = box[1];
	W = box[2];
	H = box[2];
	makeRectangle(X,Y,W,H);
	//print("made box");
}

function make_clusters(boxes){
	for(k=0;k<boxes.length;k++){
			box=split(boxes[k],"-");
			make_square(box);
			roiManager("Add");
		}
}

function merge_flatten(){
	roiManager("Show All without labels");
	roiManager("Combine");
	run("Add Selection...");
	run("Flatten");
}

function merge_clear_outside(){
	roiManager("Show All without labels");
	roiManager("Combine");
	run("Clear Outside");
}

function merge_clear(){
	roiManager("Show All without labels");
	roiManager("Combine");
	run("Clear");
	run("Select None");
}

function merge_clear_add(){
	roiManager("Combine");
	run("Clear");
	roiManager("Add");
}

function take_measures(file,count,threshdir){
	getMinAndMax(min,max);
	setThreshold(1,max);
	run("Measure");
	resetThreshold();
	set_threshold(file,threshdir);
	run("Measure");
	resetThreshold();
	count = count+2;
	return count;	
}
	
function save_image(dir,cl_type,file){
	print("saving image...");
	saveAs("Tiff",dir+"\\"+cl_type+"\\"+file);
	print("image saved...");
}

function save_data(dir,file){
	print("saving data!");
	saveAs("Results", dir+"\\data\\"+file);
	print("data saved");
}

function clear_roi_manager(start,adjustend){
	print(start);
	array1 = newArray(""+toString(start));
	print(roiManager("count"));
	for (i=1;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Delete");
}

function set_threshold(file,threshdir){
	//dir="C:\\Users\\joey\\Documents\\LabWork\\Staining\\immunofluorescense\\Gfap_Iba1_Ki67\\GFAP_Iba1_ki67_batch_output\\Thresholds\\";
	F=File.openAsString(threshdir+"\\"+file);
	getMinAndMax(min,max);
	lower_upper=split(F,"_");
	setThreshold(lower_upper[0],max);
}

function reset_data(count){
	IJ.deleteRows(0,count+1);
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

setBatchMode(false);

eval("script", "System.exit(0);");
