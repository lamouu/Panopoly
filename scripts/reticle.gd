extends CenterContainer

@export var DOT_RADIUS: float = 1.5
@export var DOT_COLOUR: Color = Color.WHITE

var currentCameraAngle:= Vector2.ZERO
var lastCameraAngle:= Vector2.ZERO
var cameraAngleChange:= Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# find the current camera rotation in 3d space
	var cameraRotation = %Player/Camera3D.get_global_rotation_degrees()
	
	# project the camera rotation onto the XY camera plane
	currentCameraAngle = Vector2(cameraRotation[0], -cameraRotation[1])
	
	# if the mouse has moved since last tick
	if currentCameraAngle != lastCameraAngle:
		# calculate the change in camera angle
		cameraAngleChange = currentCameraAngle - lastCameraAngle
		
		# convert vector2 to float and set as the rotation for the direction indicator
		$DirectionIndicator.set_rotation(cameraAngleChange.angle())
		
		lastCameraAngle = currentCameraAngle


func _draw():
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOUR)
