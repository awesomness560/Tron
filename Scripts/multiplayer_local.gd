extends CanvasLayer

@export var mainMenu : PanelContainer
@export var multiplayerSpawner : MultiplayerSpawner
@export var playerScene : PackedScene

const PORT = 9999
var enetPeer = ENetMultiplayerPeer.new()

func _on_host_pressed():
	mainMenu.hide()
	
	enetPeer.create_server(PORT)
	multiplayer.multiplayer_peer = enetPeer
	multiplayer.peer_connected.connect(addPlayer)
	
	addPlayer(multiplayer.get_unique_id())


func _on_join_pressed():
	mainMenu.hide()
	
	enetPeer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enetPeer

func addPlayer(peerId):
	var player = playerScene.instantiate()
	player.name = str(peerId)
	multiplayerSpawner.add_child(player)
	
