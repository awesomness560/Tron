extends Control
class_name HostMenu

@export_dir var mapDirectory : String ##The folder that contains all maps
@export_group("Scene References")
@export var steamUI : SteamUI
@export var mapTextureRect : TextureRect
@export var mapNameLabel : Label

var maps : Array[MapResource] = []
var currentMapIndex : int = 0

func _ready():
	Helper._dirContents(mapDirectory , maps) #To grab all map resources and add them to our local array
	selectMap(0)

func selectMap(index : int = 0):
	if maps and index < maps.size() and index >= 0:
		var selectedMap : MapResource = maps[index]
		
		if selectedMap.mapIcon:
			mapTextureRect.texture = selectedMap.mapIcon
		else:
			print("No map texture")
		
		if selectedMap.mapName:
			mapNameLabel.text = selectedMap.mapName
		else:
			print("No map name")
		
		currentMapIndex = index


func _on_left_pressed():
	selectMap(currentMapIndex - 1)


func _on_right_pressed():
	selectMap(currentMapIndex + 1)

func _on_host_button_pressed():
	var selectedMap : MapResource = maps[currentMapIndex]
	steamUI.host(selectedMap.mapLocation)
	hide()
