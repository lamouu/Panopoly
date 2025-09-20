extends CharacterBody3D

@export var swing_curve: Curve

# state stuff to be refactored
var swing : Dictionary
var swinging := false
var idle := true


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



var speed
var t_bob = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = cons.JUMP_VELOCITY
	
	if Input.is_action_pressed("shift"):
		speed = cons.RUN_SPEED
	elif Input.is_action_pressed("ctrl"):
		speed = cons.CROUCH_SPEED
		$CollisionShape3D.shape.height = cons.CROUCH_HEIGHT
	else:
		speed = cons.WALK_SPEED
		$CollisionShape3D.shape.height = cons.STANDING_HEIGHT
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	$Camera3D.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, cons.RUN_SPEED * 2)
	var target_fov = cons.BASE_FOV + cons.FOV_CHANGE * velocity_clamped
	$Camera3D.fov = lerp($Camera3D.fov, target_fov, delta * 8.0)

	move_and_slide()



var t := 0.0

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	elif swinging:
		t += delta
		var progress = clamp(t / cons.SWING_TIME, 0.0, 1.0)
		var swing_angle = cons.SWING_END_ROTATIION - cons.SWING_START_ROTATIION
		var current_rotation = swing_angle * progress * swing_curve.sample(progress)
		# dumbass: progress' scaling means that swing_curve.sample(progress) has very little weight at the start
		
		%WeaponPivot.quaternion = swing["start"].slerp(swing["end"], min(1.0, current_rotation / swing["start"].angle_to(swing["end"])))
		
		if progress >= 1.0:
			t = 0
			swinging = false
	
	
var	screenAngle
	
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
		$Camera3D.rotate_x(xRotation)
		
		screenAngle = event.relative

	if event is InputEventMouseButton and event.is_pressed() and screenAngle != null and event.button_index == MOUSE_BUTTON_LEFT:
		swing = calc_swing(screenAngle)
		t = 0
		swinging = true
		%WeaponPivot.quaternion = swing["start"]

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * cons.BOB_FREQUENCY) * cons.BOB_AMPLITUDE
	pos.x = cos(time * cons.BOB_FREQUENCY / 2) * cons.BOB_AMPLITUDE / 2
	return pos

func calc_swing(screenAngle):
	var swingDirection = Quaternion(Vector3.FORWARD, screenAngle.angle() - PI/2)
	swingDirection = swingDirection.normalized()
	
	var swingStart = swingDirection*Quaternion(Vector3.MODEL_RIGHT, cons.SWING_START_ROTATIION)
	swingStart = swingStart.normalized()
	
	var swingEnd = swingDirection*Quaternion(Vector3.MODEL_RIGHT, cons.SWING_END_ROTATIION)
	swingEnd = swingEnd.normalized()
	
	return {"start": swingStart, "end": swingEnd}
