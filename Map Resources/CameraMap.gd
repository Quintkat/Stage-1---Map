extends Camera2D

# The map
onready var Map = get_parent()

# Setup variables
const displaySize = Vector2(1920, 1080)
var mapSize : Vector2

# Camera behaviour variables
var maxZoom
const zoomLevels = 15
var zoomAmountLevels = []
var zoomJump
#var moving : bool = false	# Whether or not the camera is being dragged around
#var movingOrigin : Vector2	# Where the mouse started when the camera is being dragged
var movingPreviousMouse : Vector2
var movingSpeed = 20

# Camera info derivatives
var zoomGradient = []


# The initialisation function, sets up the camera in the middle of the map, zoomed out all the way
func init(tileSize : int, gridSize : Vector2):
	mapSize = tileSize*gridSize
	maxZoom = mapSize[0]/displaySize[0]
	zoomJump = maxZoom/zoomLevels
	for l in range(zoomLevels - 1):
		zoomAmountLevels.append(1 + l*zoomJump)
		
	# Setting up the zoom gradient for the fade out of nationality and fade in to terrain
	for z in range(1, maxZoom/3/zoomJump):
		zoomGradient.append(0)
	for z in range(maxZoom/3/zoomJump, 2*maxZoom/3/zoomJump):
		zoomGradient.append(zoomJump*3*z/maxZoom - 1)
	for z in range(2*maxZoom/3/zoomJump, maxZoom/zoomJump):
		zoomGradient.append(1)
	
	Fonts.init(self)
	
	updateZoom(maxZoom)
	move(mapSize/2)

# Moves the camera to a certain position
func move(pos : Vector2):
	var alteredPos = Vector2(0, 0)
	alteredPos[0] = int(max(zoom[0]*displaySize[0]/2, min(mapSize[0] - zoom[0]*displaySize[0]/2, pos[0])))
	alteredPos[1] = int(max(zoom[0]*displaySize[1]/2, min(mapSize[1] - zoom[1]*displaySize[1]/2, pos[1])))
	position = alteredPos
	Map.cameraMoveEvent()

func shift(shift : Vector2):
	move(position + shift)

# Setting the zoom to another level
func updateZoom(z : float):
	zoom = max(1, min(maxZoom, z))*Vector2(1, 1)
	shift(Vector2(0, 0))
	Map.cameraZoomEvent()


func _process(delta):
	inputs()

# Handles all the inputs in one place
func inputs():
	if Input.is_action_just_released("zoom_in"):
		zoomIn()
	
	if Input.is_action_just_released("zoom_out"):
		zoomOut()
	
	if Input.is_action_pressed("cam_down"):
		shift(Vector2(0, movingSpeed))
	
	if Input.is_action_pressed("cam_up"):
		shift(Vector2(0, -movingSpeed))
	
	if Input.is_action_pressed("cam_left"):
		shift(Vector2(-movingSpeed, 0))
	
	if Input.is_action_pressed("cam_right"):
		shift(Vector2(movingSpeed, 0))
	
	# Camera dragging
	if Input.is_action_just_pressed("cam_drag"):
		movingPreviousMouse = get_global_mouse_position()
	
	if Input.is_action_pressed("cam_drag"):
		shift(movingPreviousMouse - get_global_mouse_position())

func zoomIn():
	updateZoom(zoom[0] - zoomJump)

func zoomOut():
	updateZoom(zoom[0] + zoomJump)

func getZoomGradient():
	return zoomGradient[getIndexedZoomLevel()]

func getIndexedZoomLevel():
	return getZoom()/zoomJump - 2

func getZoomAmountLevels():
	return zoomAmountLevels

func getZoom():
	return zoom[0]

func getViewportSize():
	return displaySize*zoom[0]
