extends Camera3D

func camera_direction(screenAngle):
	var swingStartAngle = Quaternion(Vector3.FORWARD, screenAngle)
	#var swingEndAngle = Quaternion(Vector3.FORWARD, screenAngle + PI/2)
	
	%WeaponPivot.quaternion = swingStartAngle

	#var tween = get_tree().create_tween()
	#tween.tween_property(%WeaponPivot, "quaternion", swingEndAngle, 0.5)
