extends Node2D

# Tile children info
onready var RTerrain = $RTerrain
onready var RNationality = $RNationality
onready var TSelection = $TSelection
const selectionImgPath = "res://Map Resources/Tile Resources/Selection.png"
const selectionSubgribImgPath = "res://Map Resources/Tile Resources/SelectionSubgrid.png"

# Tile size info
const subgridSize = 3
onready var size : int = RTerrain.rect_size[0]

# Borders
const bordersScene = preload("res://Map Resources/Tile Resources/Borders.tscn")
var borders = null
const borderDarkenAmount = 0.25
const borderOpacityOffset = 0.75

# City
const cityScene = preload("res://Map Resources/Tile Resources/City Resources/City.tscn")
var city = null

# Tile info
var terrain
var nationality

# The initialisation of each tile
func init(pos : Vector2):
	position = pos*size


# The starting procedure for each tile after initialisation (eg. this procedure is the exact same for every tile)
func _ready():
	updateTerrain(Terrain.TERRAIN_WATER)
	updateNationality(Nationality.NAT_DEFAULT)

func updateTerrain(t : String):
	terrain = t
	RTerrain.color = Terrain.colour(terrain)

func updateNationality(n : String):
	nationality = n
	RNationality.color = Nationality.colour(nationality)
	if nationality == Nationality.NAT_DEFAULT:
		RNationality.visible = false
	else:
		RNationality.visible = true


# Pass a list to this function of borders the tile should display
func updateBorders(borderList : Array):
	if len(borderList) > 0:
		if borders == null:
			addBorders()
		borders.updateState(borderList)
	else:
		if borders == null:
			return
		borders.queue_free()
		borders = null

func updateVisibility(nat : float):
	if !isLand():
		RNationality.visible = false
	else:
		RNationality.visible = true
		RNationality.color = colourOpacity(RNationality.color, nat)
		if nat == 1:
			RTerrain.visible = false
		elif nat > 0:
			RTerrain.visible = true
		elif nat == 0:
			RNationality.visible = false
	
func isLand():
	return Terrain.land(terrain)

func colourOpacity(c : Color, a : float):
	return Color(c.r, c.g, c.b, a)

# Used by updateBorders()
func addBorders():
	borders = bordersScene.instance()
	add_child(borders)
	borders.init(size, subgridSize, Nationality.colour(nationality).darkened(borderDarkenAmount))
	move_child(city, get_child_count())

func getSize():
	return size

func getSubgridSize():
	return subgridSize

func getSubtileSize():
	return size/subgridSize

func getTerrain():
	return terrain

func getNationality():
	return nationality

func updateBorderColour(c : Color):
	if borders != null:
		borders.updateColour(c)

func select():
	move_child(TSelection, get_child_count())
	TSelection.visible = true
	move_child(city, get_child_count())

func selectSubtile(pos : Vector2):
	select()
	TSelection.rect_position = pos*size/subgridSize
	TSelection.rect_scale = Vector2(1, 1)/subgridSize

func deselect():
	TSelection.rect_position = Vector2(0, 0)
	TSelection.rect_scale = Vector2(1, 1)
	TSelection.visible = false

func addCity(cityName : String, ic : int, cityPos : Vector2):
	city = cityScene.instance()
	add_child(city)
	city.init(cityName, ic, cityPos)
	if city != null:
		move_child(city, get_child_count())

func getCityName():
	if city == null:
		return ""
	else:
		return city.cityName


