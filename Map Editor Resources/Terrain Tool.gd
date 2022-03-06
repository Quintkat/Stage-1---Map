extends "res://Map Editor Resources/Tool.gd"


func add(map, option, drawOption):
	map.editTerrainMouse(option)

func remove(map, option, drawOption):
	map.editTerrainMouse(Terrain.TERRAIN_WATER)
