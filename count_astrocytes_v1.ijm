

function find_astrocytes(sigma1,sigma2,threshold1,threshold2,subtract,roi){
	run("8-bit");
	if (subtract == "True"){
		if( roi == "True" ) {
			roiManager("Select",0);
		}
		run("Subtract Background...", "rolling=100 stack");
	}
	
	run("Gaussian Blur 3D...", "x="+sigma1+" y="+sigma1+" z="+sigma1);
	

	for (i=1; i<=nSlices; i++){
		setSlice(i);
		if( roi == "True" ) {
			roiManager("Select",0);
		} 
		run("Auto Local Threshold", "method="+threshold1+" radius=30 parameter_1=0 parameter_2=0 white");
	}
	if( roi == "True" ) {
			roiManager("Select",0);
	}
	run("Gaussian Blur 3D...", "x="+sigma2+" y="+sigma2+" z="+sigma2);
	if( roi == "True" ) {
			roiManager("Select",0);
	}

	stop;
	run("Auto Threshold", "method="+threshold2+" white stack");
}

function particle_selection(mincut){
	run("Z Project...", "projection=[Max Intensity]");
	run("Make Binary");
	run("Analyze Particles...", "size="+mincut+"-Infinity display clear include add");
}

function save_data(outputDir,fname){
	array1 = newArray();
	print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1);
	run("Measure");
	saveAs("Results", outputDir+fname+".txt");
}

function save_rois(outputDir,fname){
	array1 = newArray();
	print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Save", outputDir+fname+".zip");
}

function reset_(){
	n = roiManager("count");
	print(n);
	IJ.deleteRows(0,n+1);
	clear_roi_manager();
	close_windows();
	collectGarbageIfNecessary();
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

function clear_roi_manager(){
	array1 = newArray();
	print(roiManager("count"));
	for (i=0;i<roiManager("count");i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	} 
	roiManager("select", array1); 
	roiManager("Delete");
}

//Global variables
var collectGarbageInterval = 1; // the garbage is collected after n Images
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

function rename_tiled(file,hasdate,label){
	//date, ID, day, treatment, sec, tiled
	filelist = split(file,"_");

	//re = ID, day, treatment, celltype, sec
	if( hasdate == "True" ){
		re = filelist[1] + "_" + filelist[2] + "_" + filelist[3] + "_" + label + "_" + filelist[4];
	} else {
		re = filelist[0] + "_" + filelist[1] + "_" + filelist[2] + "_" +label + "_" + filelist[3];
	}
	
	return replace(re, ".czi", "");
}

function open_tiled(inputdir, file){
	//open(inputdir+"\\"+file);
	run("Bio-Formats Importer", "open="+inputdir+file+" autoscale color_mode=Default rois_import=[ROI manager] split_channels view=[Standard ImageJ] stack_order=Default");
}

function open_roi_file(inputdir,file){
	open(inputdir+"\\"+file);
	roiManager("Add");
	selectWindow(file);
	close();
}

function clear_outside(window){
	selectWindow(window);
	roiManager("Select",0);
	run("Clear Outside");
}

function select_astrocyte_window(file,fname){
	title_has_num1="False";
	titles = newArray(nImages()); 
	for (i=1; i<=nImages(); i++) { 
		selectImage(i); 
		title = getTitle();
		if (indexOf(title, "#1") >= 0) {
			print("TRUE");
			title_has_num1="True";
		} else {
			print("FALSE");
		}
	}
	
	if(title_has_num1 == "True"){
		selectWindow(file+" - "+file+" #1 - C=3");
	} else {
		selectWindow(file+" - C=3");
	}
	rename(fname);
	run("8-bit");run("8-bit");
}

function main(batchmode,inputdir,outputdir,roidir,label){
	if (batchmode == "True"){
		setBatchMode(true);
	}
	
	sigma1 = 2;
	sigma2 = 4;
	threshold1 = "Bernsen";
	threshold2 = "Otsu";
	subtract = "True";
	hasdate = "True";
	roi = "True";
	mincut = "40";
	
	datadir = outputdir + "counts\\";
	coorddir = outputdir + "rois\\";
	
	
	filelist = getFileList(inputdir+"\\");
	for(f=0;f < filelist.length; f++){
	
		file = filelist[f];
		
		print("opening file...");
		print(file);
		if (indexOf(file, "NaN") >= 0) {
			print('skip');
						
		} else {
			fname = rename_tiled(file,hasdate,label);
	
			open_roi_file(roidir,fname+".tif");
			open_tiled(inputdir,file); //open tiled file
	
			select_astrocyte_window(file,fname);
			clear_outside(fname);
					
			find_astrocytes(sigma1,sigma2,threshold1,threshold2,subtract,roi);
			/*
			particle_selection(mincut);
			//wait(10000000000000);
			save_data(datadir, fname);
			save_rois(coorddir, fname);
			
			reset_();
			*/

			stop
		}
	}
		
	if (batchmode == "True"){print("opening file...");print("opening file...");
		setBatchMode(false);
	}
}

function iter_dirs(){
	batchmode="False";
	//inputdir = "F:\\Joey\\whole_hippocampus\\30D\\JS50\\tiled";
	//outputdir = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_output\\cell_counts_all\\astrocyte\\";
	//roidir = "E:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_batch_astrocyte";
	//inputdir = "C:\\Users\\joey\\OneDrive\\Documents\\LabWork\\Staining\\immunofluorescense\\CZI_files\\Gfap_Iba1_Ki67\\weston_analysis\\test\\";
	
	//inputdir = "E:\\Joey\\whole_hippocampus\\untreated\\JS17_v2\\tiled_test\\";
	
	
	//inputdir = "F:\\Joey\\whole_hippocampus\\30D\\JS50\\tiled\\";
	//outputdir = "C:\\Users\\joey\\OneDrive\\Documents\\LabWork\\Staining\\immunofluorescense\\CZI_files\\Gfap_Iba1_Ki67\\weston_analysis\\test_out\\";
	//outputdir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_output\\output_whole\\astrocyte\\cell_counts\\";
	//roidir = "C:\\Users\\joey\\OneDrive\\Documents\\LabWork\\Staining\\immunofluorescense\\CZI_files\\Gfap_Iba1_Ki67\\weston_analysis\\test_roi\\";
	
	
	//roidir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_batch_astrocyte\\";
	//roidir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_batch_untreated\\";
	

	/*
	inputdirs = newArray("E:\\Joey\\whole_hippocampus\\untreated\\JS17_v2\\tiled\\",
	"");
	*/

	//inputdirs = newArray("E:\\Joey\\whole_hippocampus\\untreated\\JS17_v2\\tiled\\");
	
	
	/*
	inputdirs = newArray("E:\\Joey\\whole_hippocampus\\1D\\JS1\\tiled\\",
	"E:\\Joey\\whole_hippocampus\\1D\\JS2\\redo\\tiled\\",
	"E:\\Joey\\whole_hippocampus\\1D\\JS3\\redo\\tiled\\",
	"E:\\Joey\\whole_hippocampus\\1D\\JS64\\tiled\\");
	*/

	
	/*
	inputdirs = newArray(
		"E:\\Joey\\whole_hippocampus\\1D\\JS3\\redo\\tiled\\4D\\JS6\\tiled\\",
		"E:\\Joey\\whole_hippocampus\\4D\\JS7\\redo\\tiled\\"
		);
		//"E:\\Joey\\whole_hippocampus\\4D\\JS5_v4\\tiled\\");
	*/
	
	//"E:\\Joey\\whole_hippocampus\\7D\\redo\\JS12\\tiled\\",




	inputdirs = newArray("F:\\joey\\s100b_gfap_nestin\\JS59\\tiled\\");
	roidir = "F:\\joey\\s100b_gfap_nestin\\JS59\\z-stacks\\cut\\";
	outputdir = "F:\\joey\\s100b_gfap_nestin\\output_whole\\astrocyte\\cell_counts\\";
	label="gfap";

	/*
	"G:\\Joey\\whole_hippocampus\\10D\\JS10\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\10D\\JS60\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\30D\\JS50\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\30D\\JS51\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\30D\\JS52\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\30D\\JS53\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\JS16\\Tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS12\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS13\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS14\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\1D\\JS1\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\1D\\JS2\\redo\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\1D\\JS3\\redo\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\1D\\JS64\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\10D\\JS11\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\10D\\JS8\\tiled\\"
	 */
	/* 
	inputdirs = newArray(
	"G:\\Joey\\whole_hippocampus\\7D\\JS16\\Tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS12\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS13\\tiled\\",
	"G:\\Joey\\whole_hippocampus\\7D\\redo\\JS14\\tiled\\"
	);*/

	//INDISK + ":\\Joey\\whole_hippocampus\\7D\\redo\\JS14\\tiled\\",
	
	
	for(i=0;i<inputdirs.length;i++){
		print(inputdirs[i]);
		inputdir = inputdirs[i];
		main(batchmode,inputdir,outputdir,roidir,label);
	}

	
	//Array.print(inputdirs);
	//main(batchmode,inputdir,outputdir,roidir);
	
	
}
	
iter_dirs();
//main("False");



