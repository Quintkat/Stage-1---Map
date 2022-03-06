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

# River
var river = null

# Infrastructure
const roadScene = preload("res://Map Resources/Tile Resources/Infrastructure Resources/Road.tscn")
const railroadScene = preload("res://Map Resources/Tile Resources/Infrastructure Resources/Railroad.tscn")
var road = null
var railroad = null

# Resource
const resourceScene = preload("res://Map Resources/Tile Resources/Resource Resources/Resource.tscn")
var resource = null

# Tile info
var terrain
var nationality

# Misc
const cardinals = ["North", "East", "South", "West"]


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


func updateNationalityVisibility(nat : float):
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
		
		if borders != null:
			borders.updateWidth(nat*0.5 + 0.5)
	

func isLand():
	return Terrain.land(terrain)


func colourOpacity(c : Color, a : float):
	return Color(c.r, c.g, c.b, a)


# Used by updateBorders()
func addBorders():
	borders = bordersScene.instance()
	add_child(borders)
	borders.init(size, subgridSize, Nationality.colour(nationality).darkened(borderDarkenAmount))


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


func updateOrder():
	var cc = get_child_count()
	# The basic things of a tile
	moveToFront(RTerrain, cc)
	moveToFront(RNationality, cc)
	
	# Specific features
	moveToFront(borders, cc)
	moveToFront(road, cc)
	moveToFront(railroad, cc)
	moveToFront(resource, cc)
	moveToFront(city, cc)
	moveToFront(TSelection, cc)

func moveToFront(child, cc : int):
	if child != null:
		move_child(child, cc)

func select():
	TSelection.visible = true


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


func getCityName() -> String:
	if city == null:
		return ""
	else:
		return city.cityName


func hasCity() -> bool:
	return city != null


func addRoad():
	road = roadScene.instance()		# widepeepoHappy
	add_child(road)


func hasRoad() -> bool:
	return road != null


func updateRoads(neighbours : Dictionary):
	if !hasRoad():
		return
	
	for dir in cardinals:
		if neighbours[dir] != null:
			road.get_node(dir).visible = neighbours[dir].hasRoad()
		else:
			road.get_node(dir).visible = false


func addRailroad():
	railroad = railroadScene.instance()		# widepeepoHappy
	add_child(railroad)


func hasRailroad() -> bool:
	return railroad != null


func updateRailroads(neighbours : Dictionary):
	if !hasRailroad():
		return
	
	for dir in cardinals:
		if neighbours[dir] != null:
			railroad.get_node(dir).visible = neighbours[dir].hasRailroad()
		else:
			railroad.get_node(dir).visible = false
	

func updateFeatureVisibility(vis : bool):
	if hasCity():
		city.visible = vis
	
	if hasRoad():
		road.visible = vis
	
	if hasRailroad():
		railroad.visible = vis
		
	if hasResource():
		resource.visible = vis


func addResource(r : String):
	resource = resourceScene.instance()
	add_child(resource)
	resource.init(r)


func hasResource() -> bool:
	return resource != null


func getResource() -> String:
	if resource == null:
		return Resources.RESOURCE_NONE
	else:
		return resource.rName


func updateResourceVisibility(vis : bool):
	if hasResource():
		resource.visibility = vis


