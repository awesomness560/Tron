extends MultiplayerSpawner
class_name PlayerSpawner

##This node handles the spawning and managing of players

@export var playerScene : PackedScene ##Scene that contains the player

func _ready():
	spawn_function = connectPlayer

func startGame():
	if is_multiplayer_authority():
		spawn(1) #Spawn the local player
		multiplayer.peer_connected.connect(connectPlayer)
		multiplayer.peer_disconnected.connect(removePlayer)

func connectPlayer(peer_id):
	var player := playerScene.instantiate()
	player.name = str(peer_id) #The player sets the authority to its name, so we have to make sure it has the right name before spawning it
	
	return player

func removePlayer(peer_id):
	var player := get_node(str(peer_id))
	player.queue_free()
