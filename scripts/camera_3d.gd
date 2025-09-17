extends Camera3D

var SWING_TIME = 0.5
var SWING_START_ROTATIION := PI / 5
var SWING_END_ROTATIION := 4 * PI / 5

func camera_direction(screenAngle):
	var swingSide = sign(screenAngle.angle())
	
	var swingDirection = Quaternion(Vector3.FORWARD, screenAngle.angle() - PI/2)
	swingDirection = swingDirection.normalized()
	
	var swingStart = swingDirection*Quaternion(Vector3.MODEL_RIGHT, SWING_START_ROTATIION)
	swingStart = swingStart.normalized()
	
	var swingEnd = swingDirection*Quaternion(Vector3.MODEL_RIGHT, SWING_END_ROTATIION)
	swingEnd = swingEnd.normalized()
	
	%WeaponPivot.quaternion = swingStart
	
	var tween = get_tree().create_tween()
	tween.tween_property(%WeaponPivot, "quaternion", swingEnd, SWING_TIME)
