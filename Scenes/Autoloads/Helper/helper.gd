extends Node

##A class that holds all helper functions

func _dirContents(path, array : Array): ##Grabs all resources in a directory and appends them to the array variable that you pass in
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var level = load(path + "/" + file_name)
				array.append(level)
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
