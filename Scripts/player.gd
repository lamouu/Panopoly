extends CharacterBody3D

var screenAngle

@export var swing_curve: Curve
var swing : Dictionary
var swinging := false
var idle := true
var t := 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = cons.JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * cons.SPEED
		velocity.z = direction.z * cons.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, cons.SPEED)
		velocity.z = move_toward(velocity.z, 0, cons.SPEED)

	move_and_slide()

@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	elif swinging:
		t += delta
		%WeaponPivot.quaternion = %WeaponPivot.quaternion.slerp(swing["end"], swing_curve.sample(t))
		
		if t >= cons.SWING_TIME:
			t = 0
			swinging = false
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var yRotation
		var ySens
		var xRotation
		var xSens
		
		if swinging:
			ySens = cons.ySensitivity * cons.TURN_CAP
			xSens = cons.xSensitivity * cons.TURN_CAP
		else:
			ySens = cons.ySensitivity
			xSens = cons.xSensitivity
		
		yRotation = -event.relative.x * xSens   
		xRotation = -event.relative.y * ySens

		rotate_y(yRotation)
		camera.rotate_x(xRotation)
		
		screenAngle = event.relative

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		swing = calc_swing(screenAngle)
		t = 0
		swinging = true
		%WeaponPivot.quaternion = swing["start"]

func calc_swing(screenAngle):
	var swingDirection = Quaternion(Vector3.FORWARD, screenAngle.angle() - PI/2)
	swingDirection = swingDirection.normalized()
	
	var swingStart = swingDirection*Quaternion(Vector3.MODEL_RIGHT, cons.SWING_START_ROTATIION)
	swingStart = swingStart.normalized()
	
	var swingEnd = swingDirection*Quaternion(Vector3.MODEL_RIGHT, cons.SWING_END_ROTATIION)
	swingEnd = swingEnd.normalized()
	
	return {"start": swingStart, "end": swingEnd}
