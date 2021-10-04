extends Node2D

# Map editor children info
const optionPre = "CanvasLayer/HOptions/"
const toolPre = optionPre + "VToolSelection/"
onready var OTool = get_node(toolPre + "OTool")
onready var ODraw = get_node(optionPre + "ODraw")
onready var Map = $Map
onready var CActivate = $CanvasLayer/CActivate

# Tool info
var tools = {
	"Terrain"		:	preload("res://Map Editor Resources/Terrain Tool.gd").new(),
	}
var selected

# Draw Info
var drawOptions = ["1", "2", "3", "5", "10", "Fill"]


func _ready():
	for t in tools:
		OTool.add_item(t)
	OTool.select(2)
	
	for d in drawOptions:
		ODraw.add_item(d)


func _process(delta):
	selected = OTool.getText()
	if CActivate.pressed:
		inputs()

func inputs():
	if Input.is_action_pressed("map_edit_add"):
		print(tools[selected])
		tools[selected].add(Map, getOptionText(), getDrawOption())
	
	if Input.is_action_pressed("map_edit_remove"):
		tools[selected].remove(Map, getOptionText(), getDrawOption())

# Gets the text that's selected in the selected tool. Eg. if the terrain tool is selected, default could be a result of this function
func getOptionText():
	var toolOption = getToolOptionNode()
	return toolOption.get_item_text(toolOption.get_selected_id())

# Returns the OptionButton that is associated with the currently selected tool
func getToolOptionNode():
	return get_node(toolPre + "H" + OTool.getText() + "/O" + OTool.getText())

func getDrawOption():
	return ODraw.getOption()
