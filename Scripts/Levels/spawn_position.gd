extends Node3D
class_name SpawnPosition

##Takes it's position as a possible spawn position

func _enter_tree():
	GlobalVars.spawnPositions.append(self)
