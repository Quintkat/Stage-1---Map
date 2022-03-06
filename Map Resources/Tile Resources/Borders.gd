extends Control

onready var East = $East
onready var North = $North
onready var West = $West
onready var South = $South

# Setting up all of the border rectangles based on info the tile provides
func init(tileSize : int, subgridSize : int, colour : Color):
	var width : int = tileSize/subgridSize
	East.rect_size = Vector2(width, tileSize)
	East.rect_position = Vector2(tileSize - width, 0)
	East.color = colour
	East.visible = false
	North.rect_size = Vector2(tileSize, width)
	North.rect_position = Vector2(0, 0)
	North.color = colour
	North.visible = false
	West.rect_size = Vector2(width, tileSize)
	West.rect_position = Vector2(0, 0)
	West.color = colour
	West.visible = false
	South.rect_size = Vector2(tileSize, width)
	South.rect_position = Vector2(0, tileSize - width)
	South.color = colour
	South.visible = false

func updateState(borders: Array):
	East.visible = 0 in borders
	North.visible = 1 in borders
	West.visible = 2 in borders
	South.visible = 3 in borders

func updateColour(c : Color):
	East.color = c
	North.color = c
	West.color = c
	South.color = c
