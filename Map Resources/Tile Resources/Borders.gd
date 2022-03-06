extends Control

#onready var East = $East
#onready var North = $North
#onready var West = $West
#onready var South = $South
const cardinals = ["North", "East", "South", "West"]

# Setting up all of the border rectangles based on info the tile provides
func init(tileSize : int, subgridSize : int, colour : Color):
	var width : int = tileSize/subgridSize
	var rotation = 0
	var positions = [Vector2(0, 0), Vector2(tileSize, 0), Vector2(tileSize, tileSize), Vector2(0, tileSize)]
	
	for dir in cardinals:
		var border = get_node(dir)
		border.rect_size = Vector2(tileSize, width)
		border.rect_position = positions[rotation/90]
		border.rect_rotation = rotation
		rotation += 90
		
	updateState([])
	updateColour(colour)

func updateState(borders: Array):
	for dir in cardinals:
		get_node(dir).visible = dir in borders

func updateColour(c : Color):
	for dir in cardinals:
		get_node(dir).color = c

func updateWidth(scale : float):
	for dir in cardinals:
		get_node(dir).rect_scale[1] = scale
