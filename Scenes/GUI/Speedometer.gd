extends Node2D

@export var count := 0
@export var sprite : Node2D
@export var text : Label
@export var minimumSpeed := 5
@export var timer : Timer

func _process(delta):
	sprite.frame = count-1 
	text.text = str(count)
	print(get_parent().velocity.length())
	if get_parent().velocity.length() > minimumSpeed:
		if timer.is_stopped():
			timer.start(10)
		print(timer.time_left)
	else:
		if !timer.is_stopped():
			timer.stop()

func _on_speedometer_timer_timeout():
	count += 1
	if !visible:
		visible = true
