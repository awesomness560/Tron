extends Node2D

@export var count := 0
@export var sprite : Node2D
@export var text : Label
@export var minimumSpeed := 5

func _process(delta):
	sprite.frame = count-1 
	text.text = str(round(get_parent().velocity.length()))
