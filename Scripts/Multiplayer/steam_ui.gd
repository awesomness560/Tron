extends CanvasLayer

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()

@export var lobbyVBox : VBoxContainer
@export var lobbyLineEdit : LineEdit
@export var playerSpawner : PlayerSpawner
@export var gameSpawner : GameSpawner
@export var level1 : PackedScene

func _ready():
	peer.lobby_created.connect(onLobbyCreated)
	Steam.lobby_match_list.connect(onLobbyMatchList)
	openLobbyList()

func host():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	
	gameSpawner.spawn(level1)

func join(id : int):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	#GlobalSteam.lobbyId = id

func onLobbyCreated(connect, id):
	if connect:
		GlobalSteam.lobbyId = id
		var lobbyId = GlobalSteam.lobbyId
		Steam.setLobbyData(lobbyId, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobbyId, true)
		print(lobbyId)
		
		#Get rid of the main menu
		playerSpawner.startGame()
		queue_free()

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
	Steam.requestLobbyList()

func _on_refresh_pressed():
	if lobbyVBox.get_child_count() > 0:
		for n in lobbyVBox.get_children():
			n.queue_free()
	openLobbyList()

func _on_join_with_code_pressed():
	var lobbyCode = lobbyLineEdit.text.to_int()
	join(lobbyCode)
