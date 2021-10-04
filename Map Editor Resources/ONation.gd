extends OptionButton

func _ready():
	for n in Nationality.color:
		add_item(n)
