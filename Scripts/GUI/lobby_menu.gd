extends Control
class_name LobbyMenu

@export var playersContainer : VBoxContainer
@export var lobbyMemberScene : PackedScene

var lobbyMembers : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.lobby_chat_update.connect(onLobbyChatUpdate)

func getLobbyMembers() -> void:
	#Clear previous lobby list
	lobbyMembers.clear()
	#Clear the player list
	for member in playersContainer.get_children():
		member.queue_free()
	#Get num of members in this lobby
	var members : int = Steam.getNumLobbyMembers(GlobalSteam.lobbyId)
	
	#Get the data of these players from Steam
	for member in range(0, members):
		#Get the member's steam id
		var memberId : int = Steam.getLobbyMemberByIndex(GlobalSteam.lobbyId, member)
		#Get the member's steam name
		var memberSteamName : String = Steam.getFriendPersonaName(memberId)
		#Add them to the player list
		addPlayerToConnectList(memberId, memberSteamName)

#Add new steam user to the players list
func addPlayerToConnectList(steamId : int, steamName : String) -> void:
	#Add them to the array
	lobbyMembers.append({"steamId":steamId, "steamName":steamName})
	#Instance lobby member node
	var lobbyMember : LobbyMember = lobbyMemberScene.instantiate()
	#Add their steam name and id
	lobbyMember.name = str(steamName)
	lobbyMember.setMember(steamId, steamName)
	#Add them to the Vbox
	playersContainer.add_child(lobbyMember)

func onLobbyChatUpdate(lobbyId : int, changedId : int, makingChangeId : int, chatState : int) -> void:
	# Note that chat state changes is: 1 - entered, 2 - left, 4 - user disconnected before leaving, 8 - user was kicked, 16 - user was banned
	var changer = Steam.getFriendPersonaName(changedId)
	
	# If a player has joined the lobby
	if chatState == 1:
		print(str(changer)+" has joined the lobby.")
	#Else if a player left the lobby
	elif chatState == 2:
		print(str(changer)+" has left the lobby.")
	#Else if a player has been kicked
	elif chatState == 8:
		print(str(changer)+" has been kicked from the lobby.")
	#Else if a player has been banned
	elif chatState == 16:
		print(str(changer)+" has been banned from the lobby.")
	#Else there was some unknown change
	else:
		print(str(changer)+" did something...")
	#Update the lobby now that a change has occured
	getLobbyMembers()

func _on_visibility_changed():
	if visible:
		getLobbyMembers()
