extends Node
class_name DefaultGameManager

func _ready():
	SignalBus.startGame.connect(onStartGame)

func onStartGame():
	var playersArray : Array[Player] = GlobalVars.players
	var spawnPositions : Array[SpawnPosition] = GlobalVars.spawnPositions
	
	for i in playersArray.size():
		print("Our position: " + str(playersArray[i].global_position) + "| Spawn position: " + str(spawnPositions[i].global_position))
		playersArray[i].global_position = spawnPositions[i].global_position
