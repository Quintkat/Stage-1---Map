extends OptionButton

func _ready():
	for t in Terrain.colour:
		add_item(t)
