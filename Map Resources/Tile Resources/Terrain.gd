extends Node

const TERRAIN_DEFAULT = "Default"
const TERRAIN_WATER = "Water"
const TERRAIN_LAKE = "Lake"
const TERRAIN_PLAINS = "Grassland"
const TERRAIN_FOREST = "Forest"
const TERRAIN_TAIGA = "Taiga Forest"
const TERRAIN_HILLS = "Hills"
const TERRAIN_MOUNTAINS = "Mountains"
const TERRAIN_SAVANNA = "Savanna"
const TERRAIN_DESERT = "Hot Desert"
const TERRAIN_FARMLAND = "Farmland"
const TERRAIN_CITY = "City"

# Used for seeing what colour is associated with a terrain type
const colour = {
	TERRAIN_DEFAULT		: Color("#FFFFFF"),
	TERRAIN_WATER		: Color("#203165"),
	TERRAIN_LAKE		: Color("#487BC2"),
	TERRAIN_PLAINS		: Color("#2E7D31"),
	TERRAIN_FOREST		: Color("#155918"),
	TERRAIN_TAIGA		: Color("#435944"),
	TERRAIN_HILLS		: Color("#A1BfA2"),
	TERRAIN_MOUNTAINS	: Color("#9E9E9E"),
	TERRAIN_SAVANNA		: Color("#E0F56C"),
	TERRAIN_DESERT		: Color("#FFE999"),
	TERRAIN_FARMLAND	: Color("#7FC248"),
	TERRAIN_CITY		: Color("#ADA08C"),
}

# Used for seeing what terrain something is based on a colour (for reading a map image)
var terrain = {}

# Used for seeing if a terrain type is land or not
const nonLand = [TERRAIN_DEFAULT, TERRAIN_WATER, TERRAIN_LAKE]

func _init():
	for t in colour:
		terrain[colour[t]] = t


func colour(t):
	if !(t in colour):
		return colour[TERRAIN_DEFAULT]
	return colour[t]

func terrain(c):
	if !(c in terrain):
		return TERRAIN_DEFAULT
	return terrain[c]

func land(t):
	return !(t in nonLand)
