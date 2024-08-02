extends CanvasLayer
class_name SteamUI

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()

@export var lobbyVBox : VBoxContainer
@export var lobbyLineEdit : LineEdit
@export var lobbyMenu : Control
@export var joinLobbyMenu : Control
@export var hostMenu : Control
#@export var playerSpawner : PlayerSpawner
#@export var gameSpawner : GameSpawner
@export var ms : MultiplayerSpawner
@export var level1 : PackedScene
@export var testLevel : PackedScene
@export var testGameMode : PackedScene

func _ready():
	ms.spawn_function = spawnLevel
	peer.lobby_created.connect(onLobbyCreated)
	Steam.lobby_match_list.connect(onLobbyMatchList)
	openLobbyList()

func host(mapPath : String):
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	
	ms.spawn(mapPath) #TODO: Make move the player spawner out of the map and see if it is possible to spawn the map directly

func spawnLevel(data : String):
	#var a = data.instantiate()
	var a = (load(data) as PackedScene).instantiate()
	return a

func join(id : int):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	GlobalSteam.lobbyId = id
	#hide()
	joinLobbyMenu.hide()
	lobbyMenu.show()
	#var level = testLevel.instantiate()
	#add_child(level)

func leaveLobby() -> void:
	#If in a lobby, leave it
	if GlobalSteam.lobbyId != 0:
		#Send leave request to steam
		Steam.leaveLobby(GlobalSteam.lobbyId)
		#Wipe current lobby id from our device
		GlobalSteam.lobbyId = 0
		#TODO: Show main menu after this
		lobbyMenu.hide()
		joinLobbyMenu.show()

func onLobbyCreated(connect, id):
	if connect:
		GlobalSteam.lobbyId = id
		var lobbyId = GlobalSteam.lobbyId
		Steam.setLobbyData(lobbyId, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyData(lobbyId, "mode", "Tron01")
		Steam.setLobbyJoinable(lobbyId, true)
		
		# Allow P2P connections to fallback to being relayed through Steam if needed
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)
		
		print(lobbyId)
		
		#Get rid of the main menu
		#playerSpawner.startGame()
		#queue_free()
		#hide()
		joinLobbyMenu.hide()
		lobbyMenu.show()
		SignalBus.joinedLobby.emit()
		
		#TextChat.chat.print_message(TextChat.chat.col(Color.GREEN, "Succesfully joined lobby [i]" + str(lobbyId) + "[/i]"))

func onLobbyMatchList(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		
		var button : Button = Button.new()
		button.set_size(Vector2(100, 5))
		button.text = str(lobby_name, "| Players: ", memb_count)
		button.connect("pressed", Callable(self, "join").bind(lobby))
		
		lobbyVBox.add_child(button)

func openLobbyList():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("mode", "Tron01", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _on_refresh_pressed():
	if lobbyVBox.get_child_count() > 0:
		for n in lobbyVBox.get_children():
			n.queue_free()
	openLobbyList()

func _on_join_with_code_pressed():
	var lobbyCode = lobbyLineEdit.text.to_int()
	join(lobbyCode)


func _on_host_pressed():
	hostMenu.show()
	joinLobbyMenu.hide()
