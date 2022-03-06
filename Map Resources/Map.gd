extends Node2D

# Map children info
onready var CameraMap = $CameraMap
onready var LFPS = $CanvasLayer/LFPS
onready var ClCityLabels = $ClCityLabels
onready var GridOverlay = $GridOverlay
onready var NationLabelManager = $NationLabelManager

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
const cardinals = ["North", "East", "South", "West"]

# Other map data
var cities = {}
var rivers = {}

# Map Loading filepaths
var imgLoadTerrain = "res://Map Resources/Save Resources/mapTerrain.png"
var imgLoadNationality = "res://Map Resources/Save Resources/mapNationality.png"
var jsonLoadCities = "res://Map Resources/Save Resources/cities.json"
var jsonLoadRivers = "res://Map Resources/Save Resources/rivers.json"
var imgLoadRoads = "res://Map Resources/Save Resources/mapRoads.png"
var imgLoadRailroads = "res://Map Resources/Save Resources/mapRailroads.png"
var imgLoadResources = "res://Map Resources/Save Resources/mapResources.png"

# Selection data
var selectedPos : Vector2 = Vector2(-1, -1)
var selectedTile = null
var selectedSubtile = null
var dragSelecting : bool = false
var dragSelectOrigin : Vector2 = Vector2(0, 0)
const dragSelectMargin = 1

## Other
#const MapModeManager

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
	updateTileOrderMap()
	setupNations()


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
	
	# Sizing the grid overaly correctly
	GridOverlay.rect_size = getTileSize()*gridSize
	move_child(GridOverlay, get_child_count())

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
	updateAllInfrastructure()
	loadCities()
#	loadRivers()

func loadImgs():
	var imgTerrain = load(imgLoadTerrain).get_data()
	var imgNationality = load(imgLoadNationality).get_data()
	var imgRoads = load(imgLoadRoads).get_data()
	var imgRailroads = load(imgLoadRailroads).get_data()
	var imgResources = load(imgLoadResources).get_data()
	imgTerrain.lock()
	imgNationality.lock()
	imgRoads.lock()
	imgRailroads.lock()
	imgResources.lock()
	
	var roadColour = Color("#D8097E")
	var railroadColour = Color("#24468E")
	
	# Load all the initial tile features
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			# Read terrain
			var tile = getTile(Vector2(x, y))
			var terrain = Terrain.terrain(imgTerrain.get_pixel(x, y))
			tile.updateTerrain(terrain)
			if terrain == Terrain.TERRAIN_WATER || terrain == Terrain.TERRAIN_LAKE:
				continue
			
			# Read nationality
			var nationality = Nationality.nationality(imgNationality.get_pixel(x, y))
			tile.updateNationality(nationality)
			
			# Read infrastructure
			if imgRailroads.get_pixel(x, y) == railroadColour:
				tile.addRailroad()
				
			if imgRoads.get_pixel(x, y) == roadColour:
				tile.addRoad()
			
			# Read resources
			var resource = Resources.resource(imgResources.get_pixel(x, y))
			if resource != Resources.RESOURCE_NONE:
				tile.addResource(resource)
			
			
func updateAllInfrastructure():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			if getTile(Vector2(x, y)) == null:
				continue
			
			updateInfrastructure(Vector2(x, y))


func updateInfrastructure(pos: Vector2):
	var tile = getTile(pos)
	var neighbours = getNeighbours(pos)
	tile.updateRoads(neighbours)
	tile.updateRailroads(neighbours)


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
	riverFile.open(jsonLoadRivers, File.READ)
	var riverData = JSON.parse(riverFile.get_as_text()).result
	riverFile.close()
	
	var tileWidth = getTileSize()
	for rName in riverData:
		var info = riverData[rName]
		var startPos = Vector2(int(info["startX"]), int(info["startY"]))
		var segmentDict = {}
		for size in Rivers.sizes:
			if size in info:
				segmentDict[size] = info[size]
		
		var river = River.new()
		add_child(river)
		river.init(rName, startPos, tileWidth, segmentDict)

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
	var neighbours = getNeighbours(pos)
	
	if tile == null:
		return
	
	if tile.terrain == Terrain.TERRAIN_WATER || tile.terrain == Terrain.TERRAIN_LAKE:
		return
	
	for dir in cardinals:
		var neighbour = neighbours[dir]
		if neighbour == null:
			continue
		
		if neighbour.nationality != tile.nationality && neighbour.isLand():
			diffNats.append(dir)
	
	tile.updateBorders(diffNats)

# Update the nationality opacity of all tiles on the map
func updateTileVisibilityMap(nat : float):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			updateTileVisibility(Vector2(x, y), nat)

# Update the nationality opacity of a tile at a position
# On grid space
func updateTileVisibility(pos : Vector2, nat : float):
	getTile(pos).updateNationalityVisibility(nat)


func setupNations():
	NationLabelManager.init(150, grid)
	move_child(NationLabelManager, get_child_count())
	NationLabelManager.addLabel(Nationality.NAT_BOGARDIA)
	NationLabelManager.addLabel(Nationality.NAT_DELUGIA)
	NationLabelManager.addLabel(Nationality.NAT_TISGYAR)
	NationLabelManager.addLabel(Nationality.NAT_ZUMOLAIA)
	NationLabelManager.addLabel(Nationality.NAT_SASBYRG)
	NationLabelManager.addLabel(Nationality.NAT_FLUSSLAND)
	NationLabelManager.addLabel(Nationality.NAT_TROPODEIA)


func _process(delta):
	inputs()
	LFPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
	GridOverlay.visible = selectedTile != null or selectedSubtile != null

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


# Returns dict with the north, east, south and west neighbours of tile at pos
func getNeighbours(pos : Vector2): 
	var neighbours = {}
	var nsV = Vector2(0, 1)
	var ewV = Vector2(1, 0)
	neighbours["North"] = getTile(pos - nsV)
	neighbours["South"] = getTile(pos + nsV)
	neighbours["East"] = getTile(pos + ewV)
	neighbours["West"] = getTile(pos - ewV)
	
	return neighbours


func getNeighboursDistance(pos: Vector2, d : float):
	var neighbours = []
	var x = pos[0]
	var y = pos[1]
	for i in range(x - d, x + d + 1):
		for j in range(y - d, y + d + 1):
			# Can't include the tile itself
			if i == x and j == y:
				continue
			
			var testPos = Vector2(i, j)
			if pos.distance_to(testPos) <= d:
				if posValid(testPos):
					neighbours.append(getTile(testPos))
	
	return neighbours
	

# Grid validity functions
# On grid space
func posValid(pos : Vector2):
	return !(pos[0] < 0 || pos[0] >= gridSize[0] || pos[1] < 0 || pos[1] >= gridSize[1])


# On subgrid space
func posValidSubgrid(pos : Vector2):
	return !(pos[0] < 0 || pos[0] >= gridSize[0]*subgridSize || pos[1] < 0 || pos[1] >= gridSize[1]*subgridSize)


#func getAllTilesNation(nationality : String):


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
	updateTileFeatureVisibility(zoomGradient == 0)
		
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


func updateTileFeatureVisibility(vis : bool):
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateFeatureVisibility(vis)


func updateTileOrderMap():
	for x in range(gridSize[0]):
		for y in range(gridSize[1]):
			var tile = getTile(Vector2(x, y))
			if tile != null:
				tile.updateOrder()


func updateTileOrder(tile):
	if tile != null:
		tile.updateOrder()
