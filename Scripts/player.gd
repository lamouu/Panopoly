extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_CAP = 0.02
const SWING_TIME = 1.3

var screenAngle

var swing : Dictionary
var swinging := false
var idle := true
var t := 0.0
@export var swing_inter: Curve

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


var sensitivity = 0.002
@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	elif swinging:
		t += delta
		%WeaponPivot.quaternion = %WeaponPivot.quaternion.slerp(swing["end"], swing_inter.sample(t))
		
		if t >= SWING_TIME:
			t = 0
			swinging = false
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var yRotation
		var xRotation
		
		if swinging:
			yRotation = clamp(-event.relative.x * sensitivity, -TURN_CAP, TURN_CAP)
			xRotation = clamp(-event.relative.y * sensitivity, -TURN_CAP, TURN_CAP)
		else:
			yRotation = -event.relative.x * sensitivity
			xRotation = -event.relative.y * sensitivity

		rotate_y(yRotation)
		camera.rotate_x(xRotation)
		
		screenAngle = event.relative

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		swing = $Camera3D.calc_swing(screenAngle)
		t = 0
		swinging = true
		%WeaponPivot.quaternion = swing["start"]
