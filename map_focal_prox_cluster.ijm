
print("This macro maps the focal and proximal clusters for a a single image -- for the purpose of figure picture");


function map_clusters(dir,txt_file,iter_start,del_start,adjust_iter_end){
	boxes=open_cluster_file(dir,txt_file);
	if(boxes.length>0){
		make_clusters(boxes);
		combine_clear(iter_start,del_start,adjust_iter_end);
	}
}
//clusters=File.openAsString(

function create_iter_array(start,adjustend){
	print("create array start");
	array1 = newArray(""+toString(start));
	//print(roiManager("count"));
	for (i=1+start;i<roiManager("count")-adjustend;i++){ 
        array1 = Array.concat(array1,i); 
        //Array.print(array1); 
	}
	print("array success!");
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


function main(){
	//iter proximal/focal clusters
	cell="microglia";
	fname = "JS12_7D_FUS_"+cell+"_sec4";
	//imdir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/input_gfap_v3_all/"
	//clustdir = "E:/lab_files/imageJ_macro_working_directory/Gfap_S100b_Nestin/output/gfap/cluster_files/cluster_coordinates/single_threshold/150/proximal/"
	
	imdir = "E:/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/Iba1_7D_input/"
	clustdir = "E:/lab_files/imageJ_macro_working_directory/Iba1_ML_re/Iba1_set1_19-3-23/output/Iba1_set2/cluster_files/cluster_coordinates/single_threshold/150/"

	
	file = imdir + fname + ".tif";
	open_image(file,"False");
	print("image opened");
	
	//dir,txt_file,iter_start,del_start,adjust_iter_end
	if( cell == "microglia"){
		map_clusters(clustdir+"combined/",fname+".txt",1,1,1);
		map_clusters(clustdir+"focal/",fname+".txt",2,2,2);
	};

	if( cell == "astrocyte" ){
		map_clusters(clustdir+"proximal\\",fname+".txt",1,1,1);
	} else {
		map_clusters(clustdir,fname+".txt",1,1,1);
	}

}

main();
print("done");

//eval("script", "System.exit(0);");