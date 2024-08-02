extends Control
class_name LobbyMenu

@export var playersContainer : VBoxContainer
@export var startGameButton : Button
@export var lobbyMemberScene : PackedScene

var lobbyMembers : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.lobby_chat_update.connect(onLobbyChatUpdate)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_message.connect(_on_lobby_message)
	
	SignalBus.message.connect(onMessageSent)

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		GlobalSteam.lobbyId = lobby_id
		SignalBus.joinedLobby.emit()
		TextChat.chat.print_message(TextChat.chat.col(Color.GREEN, "Successfully Joined Lobby " + str(lobby_id)))
		
		toggleStartGameButton()
		getLobbyMembers()
	
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:	FAIL_REASON = "This lobby no longer exists."
			3:	FAIL_REASON = "You don't have permission to join this lobby."
			4:	FAIL_REASON = "The lobby is now full."
			5:	FAIL_REASON = "Uh... something unexpected happened!"
			6:	FAIL_REASON = "You are banned from this lobby."
			7:	FAIL_REASON = "You cannot join due to having a limited account."
			8:	FAIL_REASON = "This lobby is locked or disabled."
			9:	FAIL_REASON = "This lobby is community locked."
			10:	FAIL_REASON = "A user in the lobby has blocked you from joining."
			11:	FAIL_REASON = "A user you have blocked is in the lobby."
		print("Failed joining lobby "+str(lobby_id)+": "+str(FAIL_REASON))
		TextChat.chat.print_message(TextChat.chat.col(Color.RED, "Failed joining lobby "+str(lobby_id)+": "+str(FAIL_REASON)))

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
	print(steamName)
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
		TextChat.chat.print_message(TextChat.chat.col(Color.BLUE, str(changer)+" has joined the lobby."))
	#Else if a player left the lobby
	elif chatState == 2:
		print(str(changer)+" has left the lobby.")
		TextChat.chat.print_message(TextChat.chat.col(Color.BLUE, str(changer)+" has left the lobby."))
	#Else if a player has been kicked
	elif chatState == 8:
		print(str(changer)+" has been kicked from the lobby.")
		TextChat.chat.print_message(TextChat.chat.col(Color.BLUE, str(changer)+" has been kicked from the lobby."))
	#Else if a player has been banned
	elif chatState == 16:
		print(str(changer)+" has been banned from the lobby.")
		TextChat.chat.print_message(TextChat.chat.col(Color.BLUE, str(changer)+" has been banned from the lobby."))
	#Else there was some unknown change
	else:
		print(str(changer)+" did something...")
		TextChat.chat.print_message(TextChat.chat.col(Color.BLUE, str(changer)+" did something..."))
	#Update the lobby now that a change has occured
	getLobbyMembers()
	toggleStartGameButton()

func toggleStartGameButton(): ##Toggles the start game button depending on whether you are the host or not
	if multiplayer.is_server():
		startGameButton.disabled = false
	else:
		startGameButton.disabled = true

# When a lobby message is received
func _on_lobby_message(_result: int, user: int, message: String, type: int) -> void:
	process_lobby_message(_result, user, message, type)

func process_lobby_message(_result: int, user: int, message: String, type: int):
# We are only concerned with who is sending the message and what the message is
	var SENDER = Steam.getFriendPersonaName(user)
	# If this is a message or host command AND we are not the sender
	if type == 1 and not user == GlobalSteam.steamId:
		TextChat.chat.print_message("[i]" + str(SENDER)+": "+str(message) + "[/i]")
	# Else this is a different type of message
	else:
		match type: #TODO: Change the color of these messages
			2: TextChat.chat.print_message(str(SENDER)+" is typing...\n")
			3: TextChat.chat.print_message(str(SENDER)+" sent an invite that won't work in this chat!\n")
			4: TextChat.chat.print_message(str(SENDER)+" sent a text emote that is deprecated.\n")
			6: TextChat.chat.print_message(str(SENDER)+" has left the chat.\n")
			7: TextChat.chat.print_message(str(SENDER)+" has entered the chat.\n")
			8: TextChat.chat.print_message(str(SENDER)+" was kicked!\n")
			9: TextChat.chat.print_message(str(SENDER)+" was banned!\n")
			10: TextChat.chat.print_message(str(SENDER)+" disconnected.\n")
			11: TextChat.chat.print_message(str(SENDER)+" sent an old, offline message.\n")
			12: TextChat.chat.print_message(str(SENDER)+" sent a link that was removed by the chat filter.\n")

func onMessageSent(msg : String):
	#If there is a message
	if msg.length() > 0:
		# Pass the message to Steam
		var isSent : bool = Steam.sendLobbyChatMsg(GlobalSteam.lobbyId, msg)
		# Was it sent successfully?
		if not isSent:
			TextChat.chat.print_message(TextChat.chat.col(Color.RED, "Failed to send message"))

func _on_start_game_pressed():
	Steam.setLobbyJoinable(GlobalSteam.lobbyId, false)
	#startGameRPC.rpc()
	rpc("startGameRPC")

@rpc("any_peer", "call_local", "reliable")
func startGameRPC():
	SignalBus.startGame.emit()
	hide()
