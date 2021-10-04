extends TextureRect

# Children info
onready var LName = $LName

# City info
var cityName : String = ""
var IC : int = 0
var gridPos : Vector2 = Vector2(0, 0)

# City image filepaths
var imgSmall = "res://Map Resources/Tile Resources/City Resources/citySmall.png"
var imgMedium = "res://Map Resources/Tile Resources/City Resources/cityMedium.png"
var imgLarge = "res://Map Resources/Tile Resources/City Resources/cityLarge.png"
var imgIndustry = "res://Map Resources/Tile Resources/City Resources/cityIndustry.png"

# IC cutoffs
const cutoffMedium = 5
const cutoffLarge = 20
const cutoffIndustry = 5
const emptyName = "Industrial Zone"


func init(n : String, ic : int, pos : Vector2):
	updateName(n)
	updateIC(ic)
	gridPos = pos
#	updateLabelFont(Fonts.fontCity)

func updateName(n : String):
	cityName = n
	LName.text = cityName

func updateIC(ic : int):
	IC = ic
	if cityName == emptyName && IC >= cutoffIndustry:
		texture = load(imgIndustry)
	elif IC >= cutoffLarge:
		texture = load(imgLarge)
	elif IC >= cutoffMedium:
		texture = load(imgMedium)
	else:
		texture = load(imgSmall)


func overrideTexture(size : String):
	if size == "industry":
		texture = load(imgIndustry)
	elif size == "small":
		texture = load(imgSmall)
	elif size == "medium":
		texture = load(imgMedium)
	elif size == "large":
		texture = load(imgLarge)

func updateLabelFont(font : DynamicFont):
	LName.add_font_override("custom_fonts/font", font)

func getDrawPointName():
	return rect_position + Vector2(rect_size[0]/2, 0)


func _draw():
	pass
#	if cityName == "Gyomov":
#		print(Fonts.getFontCityCam().size)
#	draw_string(Fonts.getFontCityCam(), rect_position, cityName)

func drawUpdate():
	update()


