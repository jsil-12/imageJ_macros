dir = "F:\\lab_files\\imageJ_macro_working_directory\\Gfap_Iba1_ki67\\GFAP_Iba1_ki67_output\\voronoi\\test\\";
file = "test_voronoi_output_strfile.txt";

coords=File.openAsString(dir+file);
coordsSep = split(coords,"=");
//coordsSep2 = split(coordsSep2,"\n");


for (i = 0; i < coordsSep.length; i++) {
	print(i);
	print("====");
	linecoords = split(coordsSep[i],"-");
	if(linecoords.length > 1){
		Array.print(linecoords);
		makeLine(parseInt(linecoords[0]),parseInt(linecoords[1]),parseInt(linecoords[2]),parseInt(linecoords[3]));
		roiManager("Add");
	}
}
//Array.print(coordsSep2);
//Array.print(coordsSep);