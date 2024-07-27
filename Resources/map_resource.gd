extends Resource
class_name MapResource

@export var mapIcon : Texture2D ##The icon to be displayed in when selecting the map
@export var mapName : String ##The name of the map
@export_file("*.tscn") var mapLocation : String ##The place where the map scene is stored
