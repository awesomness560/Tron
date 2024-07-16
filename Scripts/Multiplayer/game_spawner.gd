extends MultiplayerSpawner
class_name GameSpawner

##This node spawns game nodes on all players

func _ready():
	spawn_function = spawnNode

func spawnNode(scene : PackedScene): ##Takes a packed scene and spawns it in on all players
	var node = scene.instantiate()
	return node
