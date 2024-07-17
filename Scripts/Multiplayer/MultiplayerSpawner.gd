extends MultiplayerSpawner

@export var playerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer
	SignalBus.joinedLobby.connect(joinedLobby)

var players := {}

func joinedLobby():##Spawns player whenver you join a lobby
	if multiplayer.is_server():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.name = str(data)
	players[data] = p
	GlobalVars.players.append(p)
	return p

func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
