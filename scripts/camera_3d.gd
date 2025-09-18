extends Camera3D

var SWING_START_ROTATIION := 0.1
var SWING_END_ROTATIION := PI
#var SWING_DURATION := 1.5
#var SWING_EASE := 2
#var SWING_TRANS := 3

#var tween

func calc_swing(screenAngle):
	var swingDirection = Quaternion(Vector3.FORWARD, screenAngle.angle() - PI/2)
	swingDirection = swingDirection.normalized()
	
	var swingStart = swingDirection*Quaternion(Vector3.MODEL_RIGHT, SWING_START_ROTATIION)
	swingStart = swingStart.normalized()
	
	var swingEnd = swingDirection*Quaternion(Vector3.MODEL_RIGHT, SWING_END_ROTATIION)
	swingEnd = swingEnd.normalized()
	
	return {"start": swingStart, "end": swingEnd}
	
	
	# OLD ANIMATION
	#%WeaponPivot.quaternion = swingStart
	#tween = create_tween()
	#tween.tween_property(%WeaponPivot, "quaternion", swingEnd, SWING_DURATION).set_ease(SWING_EASE).set_trans(SWING_TRANS)
