extends Node

const RESOURCE_OIL = "Oil"
const RESOURCE_STEEL = "Steel"
const RESOURCE_SULPHUR = "Sulphur"
const RESOURCE_ALUMINIUM = "Aluminium"
const RESOURCE_FOOD = "Food"
const RESOURCE_NONE = "None"

var textures = {
	RESOURCE_OIL			: load("res://Map Resources/Tile Resources/Resource Resources/Oil.png"),
	RESOURCE_STEEL			: load("res://Map Resources/Tile Resources/Resource Resources/Steel.png"),
	RESOURCE_SULPHUR		: load("res://Map Resources/Tile Resources/Resource Resources/Sulphur.png"),
	RESOURCE_ALUMINIUM		: load("res://Map Resources/Tile Resources/Resource Resources/Aluminium.png"),
}

const colours = {
	RESOURCE_OIL			: Color("#000000"),
	RESOURCE_STEEL			: Color("#000CFF"),
	RESOURCE_SULPHUR		: Color("#FFE100"),
	RESOURCE_ALUMINIUM		: Color("#FF0010"),
}

var resources = {}


func _init():
	for r in colours:
		resources[colours[r]] = r


func resource(c: Color):
	if !(c in resources):
		return RESOURCE_NONE
	return resources[c]


func texture(r):
	return textures[r]
