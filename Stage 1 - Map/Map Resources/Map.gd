extends Node2D

# Map children info
onready var CameraMap = $CameraMap
onready var LFPS = $CanvasLayer/LFPS
onready var ClCityLabels = $ClCityLabels

# Necessary for instancing tiles
const tileScene = preload("res://Map Resources/Tile Resources/Tile.tscn")
const Subtile = preload("res://Map Resources/Tile Resources/Subtile.gd")
const cityLabelScene = preload("res://Map Resources/City Label Resources/CityLabel.tscn")
const River = preload("res://Map Resources/River Resources/River.gd")

# The grid data
var gridSize = Vector2(96, 54)
var subgridSize = 3
var grid # Visual x, then visual y
var subgrid # Visual x, then visual y

# Other map data
var cities = {}
var rivers = {}

# Loading filepaths
var imgLoadTerrain = "res://Map Resources/Save Resources/mapTerrain.png"
var imgLoadNationality = "res://Map Resources/Save Resources/mapNationality.png"
var jsonLoadCities = "res://Map Resources/Save Resources/cities.json"
var jsonLoadRivers = "res://Map Resources/Save Resources/rivers.json"

# Selection data
var selectedPos : Vector2 = Vector2(-1, -1)
var selectedTile = null
var selectedSubtile = null
var dragSelecting : bool = false
var dragSelectOrigin : Vector2 = Vector2(0, 0)
const dragSelectMargin = 1

# Loading variables
var loadingFinished = false


func _ready():
	fillTileGrid()
	cameraSetup()
	loadMap()
	updateBordersMap()
	updateTileVisibilityMap(CameraMap.getZoomGradient())
	loadingFinished = true
	cameraZoomEvent()
	
# Fill the grid and subgrid variables with the necessary data
func fillTileGrid():
	# Filling of the normal grid
	grid = []
	for x in range(gridSize[0]):
		grid.append([])
		for y in range(gridSize[1]):
			var tileNew = tileScene.instance()
			add_child(tileNew)
			tileNew.init(Vector2(x, y))
			grid[x].append(tileNew)
	
	# Filling of the subgrid
	subgrid = []
	for sx in range(gridSize[0]*subgridSize):
		subgrid.append([])
		for sy in range(gridSize[1]*subgridSize):
			subgrid[sx].append(Subtile.new())

# Set up the camera
func cameraSetup():
	CameraMap.init(grid[0][0].getSize(), gridSize)

func fontSetup():
	Fonts.init(CameraMap)

func getTileSize():
	return grid[0][0].getSize()

func getSubtileSize():
	return grid[0][0].getSubtileSize()

# Loads map data from a set of images
func loadMap():
	loadImgs()
	loadCities()
	loadRivers()

func loadImgs():
	var imgTerrain = load(imgLoadTerrain).get_data()
	var imgNationality = load(imgLoadNationality).get_data()
	imgTerrain.lock()
	imgNationality.lock()
	
	# Load all the initial tile features
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			var terrain = Terrain.terrain(imgTerrain.get_pixel(x, y))
			tile.updateTerrain(terrain)
			if terrain == Terrain.TERRAIN_WATER || terrain == Terrain.TERRAIN_LAKE:
				continue
			
			var nationality = Nationality.nationality(imgNationality.get_pixel(x, y))
			tile.updateNationality(nationality)

func loadCities():
	# Load in the city file and populate a 2d array with the data
	var cityFile = File.new()
	var cityX = "x"
	var cityY = "y"
	var cityIC = "ic"
	var emptySign = "!"
	var emptyName = "Industrial Zone"
	
	# Populate the grid with the actual cities
	cityFile.open(jsonLoadCities, File.READ)
	var cityData = JSON.parse(cityFile.get_as_text()).result
	cityFile.close()
	
	for c in cityData:
		var city = cityData[c]
		var cityName = c
		if c[0] == emptySign:
			cityName = emptyName
		
		var cityGridPos = Vector2(city[cityX], city[cityY])
		var tile = getTile(Vector2(city[cityX], city[cityY]))
		tile.addCity(cityName, city[cityIC], cityGridPos)
		cities[tile.getCityName()] = tile.city
		
		if cityName != emptyName:
			createCityLabel(tile.city)
			
	updateCityLabels()

func createCityLabel(city):
	var label = cityLabelScene.instance()
	var textWidth = Fonts.fontCityConstant.get_string_size(city.cityName)[0]
	label.init(city.cityName, city.gridPos)
	ClCityLabels.add_child(label)
	label.rect_position = label.gridPos*getTileSize() + Vector2(getTileSize()/2, -15)

func loadRivers():
	var riverFile = File.new()
	var lineID = "ID"
	var lineIndex = "n"
	var lineSkip = "#"
	var lineEmpty = ""
	var riverStart = "?RIVERSTART"
	var riverEnd = "!RIVEREND"
	var lineEnd = ""
	var minIndex = 1
	var maxIndex = 7
	var sizes = ["small", "medium", "large"]
	
	riverFile.open(jsonLoadRivers, File.READ)
	var riverData = JSON.parse(riverFile.get_as_text()).result
	riverFile.close()
	
	var editedRiver
	for r in riverData:
		var id = r[lineID]
		if id == lineEmpty || id[0] == lineSkip:
			continue
		
		if id == riverStart:
			editedRiver = River.new()
			continue
		
		if id == riverEnd:
			continue
		
		if !(id in sizes):
			editedRiver.init(id, Vector2(r[lineIndex + "1"], r[lineIndex + "2"]))
			rivers[editedRiver.rName] = editedRiver
			continue
		else:
			pass

func addRiverToTiles():
	pass

# Update the borders of all tiles in the map
func updateBordersMap():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateBorders(Vector2(x, y))

# Update the borders of a tile at a position
# On grid space
func updateBorders(pos : Vector2):
	var tile = getTile(pos)
	var diffNats = []
	var neighbourPos = [pos + Vector2(1, 0), pos - Vector2(0, 1), pos - Vector2(1, 0), pos + Vector2(0, 1)]
	
	if tile == null:
		return
	
	if tile.terrain == Terrain.TERRAIN_WATER || tile.terrain == Terrain.TERRAIN_LAKE:
		return
	
	for i in range(len(neighbourPos)):
		var neighbour = getTile(neighbourPos[i])
		if neighbour == null:
			return
		
		if neighbour.nationality != tile.nationality && neighbour.isLand():
			diffNats.append(i)
	
	tile.updateBorders(diffNats)

# Update the nationality opacity of all tiles on the map
func updateTileVisibilityMap(nat : float):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateTileVisibility(Vector2(x, y), nat)

# Update the nationality opacity of a tile at a position
# On grid space
func updateTileVisibility(pos : Vector2, nat : float):
	getTile(pos).updateVisibility(nat)


func _process(delta):
	inputs()
	LFPS.text = str(Performance.get_monitor(Performance.TIME_FPS))

func inputs():
	if Input.is_action_just_released("game_end"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("select_tile"):
		dragSelectOrigin = mouseGridPosition()
	
	if Input.is_action_pressed("select_tile") && detectDragSelecting(dragSelectOrigin):
		dragSelecting = true
	
	if Input.is_action_just_released("select_tile"):
		if !dragSelecting:
			if !isSubtileSelecting():
				deselectSubtile()
				var previousSelected = selectedTile
				if previousSelected != null:
					deselectTile()
					
				selectTile(mouseGridPosition())
				if previousSelected == selectedTile:
					deselectTile()
					
			else:
				deselectTile()
				var previousSelected = selectedSubtile
				if previousSelected != null:
					deselectSubtile()
				
				selectSubtile(mouseSubgridPosition())
				if previousSelected == selectedSubtile:
					deselectSubtile()
				
		else:
			dragSelecting = false

# Selecting functions
# On grid space
func detectDragSelecting(origin : Vector2):
	var diff = origin - mouseGridPosition()
	return abs(diff[0]) >= dragSelectMargin || abs(diff[1]) >= dragSelectMargin

# On grid space
func selectTile(pos : Vector2):
	selectedTile = getTile(pos)
	selectedPos = pos
	selectedTile.select()

# On subgrid space
func selectSubtile(pos : Vector2):
	selectedSubtile = getSubtile(pos)
	selectedPos = pos
	selectedSubtile.select()
	
	# The super tile only handles the visual aspect of the selection box)
	getSuperTile(pos).selectSubtile(VectorMath.mod(pos, subgridSize))

# On grid space
func deselectTile():
	if selectedTile != null:
		selectedTile.deselect()
		resetSelectedTile()

# On subgrid space
func deselectSubtile():
	if selectedSubtile != null:
		selectedSubtile.deselect()
		getSuperTile(selectedPos).deselect()
		resetSelectedSubtile()

func resetSelectedTile():
	selectedTile = null
	selectedPos = Vector2(-1, -1)

func resetSelectedSubtile():
	selectedSubtile = null
	selectedPos = Vector2(-1, -1)

func isSubtileSelecting():
	return !Input.is_action_pressed("select_modifier") && CameraMap.getZoomGradient() == 0


# Info retrieving functions
# On grid space
func getTile(pos : Vector2):
	if !posValid(pos):
		return null
	return grid[pos[0]][pos[1]]

# On subgrid space
func getSubtile(pos : Vector2):
	if !posValidSubgrid(pos):
		return null
	return subgrid[pos[0]][pos[1]]

# On subgrid space
func getSuperTile(pos : Vector2):
	return getTile(VectorMath.vectInt(pos/subgridSize))

# Grid validity functions
# On grid space
func posValid(pos : Vector2):
	return !(pos[0] < 0 || pos[0] >= gridSize[0] || pos[1] < 0 || pos[1] >= gridSize[1])

# On subgrid space
func posValidSubgrid(pos : Vector2):
	return !(pos[0] < 0 || pos[0] >= gridSize[0]*subgridSize || pos[1] < 0 || pos[1] >= gridSize[1]*subgridSize)


# Mouse conversion functions
func mouseGridPosition():
	return VectorMath.vectInt(get_global_mouse_position()/getTileSize())

func mouseSubgridPosition():
	return VectorMath.vectInt(get_global_mouse_position()/getSubtileSize())


# Map editing functions
func editTerrainMouse(terrain):
	editTerrain(mouseGridPosition(), terrain)

func editTerrain(pos, terrain):
	getTile(pos).updateTerrain(terrain)

func editNationalityMouse(nationality):
	editNationality(mouseGridPosition(), nationality)

func editNationality(pos, nationality):
	getTile(pos).updateNationality(nationality)


# Listener functions
# Effectively a listener for the camera
func cameraZoomEvent():
	var zoomGradient = CameraMap.getZoomGradient()
	updateTileVisibilityMap(zoomGradient)
	updateCityLabelVisbility(zoomGradient == 0)
		
	if loadingFinished:
		updateCityLabels()
	
	updateCityLabelsLayer()

func cameraMoveEvent():
	updateCityLabelsLayer()

func updateCityLabels():
	ClCityLabels.scale = Vector2(1, 1)/CameraMap.getZoom()
	for label in ClCityLabels.get_children():
		label.rect_scale = CameraMap.zoom

func updateCityLabelsLayer():
	ClCityLabels.offset = -CameraMap.position/CameraMap.getZoom() + CameraMap.displaySize/2

func updateCityLabelVisbility(vis : bool):
	for label in ClCityLabels.get_children():
		label.visible = vis



