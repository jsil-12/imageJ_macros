function process_file_check(path,ID,trt,sec){
	files= getFileList(path);
	file_already_completed = false;
	for(i=0; i < files.length; i++){
		ID_check = false;
		trt_check = false;
		sec_check = false;
		file = files[i];
		info = split(file,"_");
		for(j=0; j < info.length; j++){
			if(matches(info[j],".*"+ID+".*")){
				ID_check = true;
			} if(matches(info[j],trt)){
				print(info[j]);
				trt_check = true;
			} if(matches(info[j],".*"+sec+".*")){
				sec_check = true;
			}
		}
		file_already_completed = file_already_completed | (ID_check & trt_check & sec_check);
	}
	return !file_already_completed;
}




input = "F:/joey/s100b_gfap_nestin/JS67v3/tiled/";
zstack_out = "F:/joey/s100b_gfap_nestin/JS67v3/zstacks/";
MIP_out = "F:/joey/s100b_gfap_nestin/JS67v3/MIP/";
cut_out = "";
roi_path = "";

channel0 = "s100b";
channel1 = "nestin";
channel2 = "dapi";
channel3 = "gfap";

date = "19-1-16";
ID = "JS67v3";
day="untreated";


channels = newArray(channel0,channel1,channel2,channel3);


Array.print(channels);

files = getFileList(input);

for(i=0;i<files.length; i++){
	file = files[i];

	info = split(file,"_");
	Array.print(info);
	end = info.length;
	sec = info[end-2];
	trt = info[end-3];
	
	full_path = input + "/" + file;

	process_file = process_file_check(zstack_out,ID,trt,sec);

	//print(process_file);

	if(process_file){
	/*
		print("TRUE");
	} if (process_file == 2){
	*/
		run("Bio-Formats Importer", "open=[full_path] color_moded=default view=Hyperstack");
		print("opening file...");
		
		//run("Bio-Formats", "open=full_path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
		
		main_img = "main_image"+"_"+ID+"_"+trt+"_"+sec;

		rename(main_img);
		/*
		if((matches(img,".*#1.*"))	){
			full_path = full_path + " - " +img;
		}*/
		run("Split Channels");

		print("split");
		
		setBatchMode(true);
		for(j=0; j<channels.length; j++){
			selectWindow("C"+toString(j+1)+"-"+main_img);
			print(getTitle());
			//save z-stacks
			//outFile = main_img+"_"+channels[j]+"_"+".tif";

			outFile = date+"_"+ID+"_"+day+"_"+trt+"_"+channels[j]+"_"+sec+".tif";
	
			print("================");
			print(outFile);
			print("================");
			
			print("saving...");
			saveAs("Tiff", zstack_out+outFile);
			print("saved");
			run("Z Project...", "projection=[Max Intensity]");
			selectWindow(outFile);
			close();
			selectWindow("MAX_"+outFile);
			print("saving...");
			saveAs("Tiff", MIP_out+outFile);
			print("saved");
			
			}
			setBatchMode(false);
		while (nImages>0) {
          selectImage(nImages);
          close(); 
      	} 
	}
}
