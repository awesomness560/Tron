extends HBoxContainer
class_name LobbyMember

var steamId : int = 0
var steamName : String = "[Empty]"

var userAvatar : Image

@export var usernameLabel : Label
@export var avatarRect : TextureRect

func _ready():
	Steam.avatar_loaded.connect(onAvatarLoaded)

func setMember(_steamId : int, _steamName : String) -> void:
	#Set steam id and username
	steamId = _steamId
	steamName = _steamName
	
	usernameLabel.text = steamName
	#Get player avatar
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steamId)

func _on_view_profile_pressed():
	Steam.activateGameOverlayToUser("steamid", steamId)

func onAvatarLoaded(id: int, this_size: int, buffer: PackedByteArray) -> void:
	# Check we're only triggering a load for the right player, and check the data has actually changed
	if id == steamId and (not userAvatar or not buffer == userAvatar.get_data()):
		print("Loading avatar for user: "+str(id))
		# Create the image and texture for loading
		userAvatar = Image.create_from_data(this_size, this_size, false, Image.FORMAT_RGBA8, buffer)
		# Apply it to the texture
		var avatar_texture: ImageTexture = ImageTexture.create_from_image(userAvatar)
		# Set it
		avatarRect.texture = avatar_texture
