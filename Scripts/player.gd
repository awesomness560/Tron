extends CharacterBody3D

@export var gravity : float = -20.0
@export var steeringLimit : float = 10.0
@export var wheelBase : float = 2.0
@export var enginePower : float = 6.0
@export var braking : float = -9.0
@export var friction : float = -2.0
@export var drag : float = -2.0
@export var visuals : Node3D

var acceleration : Vector3 = Vector3.ZERO
var steerAngle : float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if is_on_floor():
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
	
	acceleration.y = gravity
	velocity += acceleration * delta
	move_and_slide()

func apply_friction(delta):
	if velocity.length() < 0.2 and acceleration.length() == 0:
		velocity.x = 0
		velocity.y = 0
	var frictionForce = velocity * friction * delta
	var dragForce = velocity * velocity.length() * drag * delta
	acceleration += dragForce * frictionForce

func calculate_steering(delta):
	var rearWheel := transform.origin + transform.basis.z * wheelBase / 2.0
	var frontWheel := transform.origin - transform.basis.z * wheelBase / 2.0
	rearWheel += velocity * delta
	frontWheel += velocity.rotated(transform.basis.y, steerAngle) * delta
	var newHeading = rearWheel.direction_to(frontWheel)
	
	var d := newHeading.dot(velocity.normalized())
	if d > 0:
		velocity = newHeading * velocity.length()
	elif d < 0:
		velocity = -newHeading * velocity.length()
	look_at(transform.origin + newHeading, transform.basis.y)

func get_input():
	var turn = Input.get_action_strength("steer_left")
	turn -= Input.get_action_strength("steer_right")
	steerAngle = turn * deg_to_rad(steeringLimit)
	visuals.rotation.x = steerAngle
	
	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate"):
		acceleration = -transform.basis.z * enginePower
	if Input.is_action_pressed("brake"):
		acceleration = -transform.basis.z * braking


func _on_area_3d_body_entered(body):
	print(body)
