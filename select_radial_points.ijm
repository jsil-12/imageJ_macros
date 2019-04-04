outputpath = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\microglia_astrocyte_7D_output\\whole_output\\radial_analysis\\centers\\microglia\\";
inputpath = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_batch_microglia_astrocyte_7D\\";

files = getFileList(inputpath);

end = files.length;
//end = 2;
for (i=0;i<end;i++){
	file = files[i];
	outfile = replace(file,"tif","txt");
	open(inputpath+file);
	waitForUser("Select Points", "add a point to the ROI Manager for each center of activation");
	measure_points();
	if(nImages > 0) {
		close();
	}
	save_roi_file(outputpath,outfile);
	clear_roi_manager();
}

function measure_points(){
  n = roiManager("count");
  for (i=0; i<n; i++) {
      roiManager("select", i);
      run("Measure");
  }
}

function clear_roi_manager(){
	n = roiManager("count");
	while ( n > 0) {
		roiManager("select",0);
		roiManager("Delete");
		n = roiManager("count");
	}
}

function save_roi_file(outputpath,filename){
	saveAs("Results", outputpath+filename);
	run("Clear Results");
}

