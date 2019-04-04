//setBatchMode(true); 
print("Initiate find cluster overlap macro V1");


function main(){
	setBatchMode(true); 
	inputs = getArgument();
	dirs = split(inputs,"@");
	Array.print(dirs);
	imagedir=dirs[0];
	outputdir=dirs[1];
	//distal_cluster=dirs[4];
	//subtract=dirs[5];
	microglia_cluster_dir = dirs[2];
	astrocyte_cluster_dir = dirs[3];
	
	overlap_cluster_files(microglia_cluster_dir,astrocyte_cluster_dir,"microglia","astrocyte",imagedir);
	setBatchMode(false); 
}

function overlap_cluster_files(queryDir,refDir,qCell,rCell,imageDir){
	qClusterlist = getFileList(queryDir);
	//rClusterlist = getFileList(refDir);
	for(i = 0; i < qClusterlist.length;i++){
		qfile = qClusterlist[i];
		print(qfile);
		//ID,day,cond,cell,sec.txt
		f = split(qfile,"_");
		outFn = f[0]+"_"+f[1]+"_"+f[2]+"_"+f[4];
		rfile = replace(qfile,qCell,rCell);
		tif_file=replace(qfile,"txt","tif");
		qCl=open_cluster_file(queryDir,qfile);
		rCl=open_cluster_file(refDir,rfile);
		print("===");
		Array.print(qCl);
		Array.print(rCl);
		print("===");
		if(qCl.length>0){
			open(imageDir+"\\"+tif_file);
			make_clusters(qCl,0,0,1);
			if(rCl.length>0){
				//dont delete first combined cluster
				make_clusters(rCl,1,1,1);
				
				//wait(10000);
				find_overlap("combined",outputdir, outFn);
				//overlap microglia and astrocytes
				print("DONE!");
			} else {
				//microglia only
				find_overlap("microglia",outputdir, outFn);
			}
			close();
		} else {
			if(rCl.length>0){
				open(imageDir+"\\"+tif_file);
				//astrocyte only
				make_clusters(rCl,0,0,1);
				find_overlap("astrocyte",outputdir, outFn);
				close();
			}
		}
	}
}


function open_cluster_file(dir,clusterfile){
	print(dir+"\\"+clusterfile);
	clusters=File.openAsString(dir+"\\"+clusterfile);
	boxes=split(clusters,"=");
	return boxes;
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

function make_clusters(boxes,iterstart,delstart,adjustend){
	for(k=0;k<boxes.length;k++){
		box=split(boxes[k],"-");
		make_square(box);
		roiManager("Add");
	}
	//wait(5000);
	combine_clear(iterstart,delstart,adjustend);
	//wait(5000);
}

function create_iter_array(start,adjustend){
	array1 = newArray(""+toString(start));
	//print(roiManager("count"));
	for (i=1+start;i<roiManager("count")-adjustend;i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	}
	return array1;
}

function combine_clear(iterstart,delstart,adjustend){
	array1 = create_iter_array(iterstart,0);
	roiManager("Select",array1);
	roiManager("Combine");
	roiManager("Add");
	//wait(5000);
	clear_roi_manager(delstart,adjustend);
}

function clear_roi_manager(start,adjustend){
	//print(start);
	array1 = create_iter_array(start,adjustend);
	roiManager("select", array1); 
	roiManager("Delete");
	print("RoiManager cleared..");
	//roiManager("reset"); 
}

function reset_data(){
	//IJ.deleteRows(0,count+1);
	run("Clear Results"); 
	print("reset");
}

function save_overlap_data(overlap,outputdir,file){
	print("saving data!");
	print(file);
	saveAs("Results", outputdir+"\\"+overlap+"\\"+file);
	print("data saved");
	reset_data();
}

function area_threshold(){
	getMinAndMax(min,max);
	setThreshold(0,max);
}

function find_overlap(overlap,outputdir,fname){
	//wait(10000);
	print("cluster overlap: " + overlap);
	//setTool("rectangle");
	if(overlap == "combined"){
		//measure microglia
		roiManager("Select", 0);
		roiManager("Measure");
		
		//measure astrocyte
		roiManager("Select", 1);
		roiManager("Measure");
	
		//measure combined
		roiManager("Select", newArray(0,1));
		roiManager("AND");
		roiManager("Add");
		
		roiManager("Select", 2);
		//area_threshold();
		roiManager("Measure");
		
		/*
		//measure all microglia
		roiManager("select", 1);
		run("Clear", "slice");
		roiManager("select", 0);
		area_threshold();
		roiManager("Measure");
		//wait(10000);
		close();
		
		//astrocyte only
		open(imageDir+"\\"+tif_file);
		roiManager("select", 0);
		run("Clear", "slice");
		roiManager("select", 1);
		area_threshold();
		roiManager("Measure");
		//wait(10000);
		//close();
		
		wait(10000);
		*/
		save_overlap_data(overlap,outputdir,fname);
	} else if (overlap == "microglia"){
		roiManager("select", 0);
		roiManager("Measure");
		save_overlap_data(overlap,outputdir,fname);
	} else if (overlap == "astrocyte"){
		roiManager("select", 0);
		roiManager("Measure");
		save_overlap_data(overlap,outputdir,fname);
	}
	//wait(10000);
	clear_roi_manager(0,0);
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


main();

eval("script", "System.exit(0);");

