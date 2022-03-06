extends Node

# Camera info
var Cam

# Initialisation info for city fonts
const pathCity = "res://Font Resources/Roboto-Regular.ttf"
const citySize = 13
const cityOutlineSize = 1
const cityOutlineColour = Color("#000000")
const citySizeCapitalMult = 1.5

# All the different fonts
var fontCity = []
var fontCapital = []
const fontCityConstant = preload("res://Font Resources/fontCity.tres")
#var fontCity : DynamicFont
#var fontCapital : DynamicFont

func init(cam):
	Cam = cam
#	fontCity = DynamicFont.new()
#	fontCity.font_data = load(pathCity)
#	fontCity.size = citySize
#	fontCity.outline_size = cityOutlineSize
#	fontCity.outline_color = cityOutlineColour
#
#	fontCapital = DynamicFont.new()
#	fontCapital.font_data = load(pathCity)
#	fontCapital.size = citySize*citySizeCapitalMult
#	fontCapital.outline_size = cityOutlineSize
#	fontCapital.outline_color = cityOutlineColour
	
	# Make an array of fonts with different sizes for the different zoom levels
	for level in Cam.getZoomAmountLevels():
		var fcs = DynamicFont.new()
		fcs.font_data = load(pathCity)
		fcs.size = citySize*level
		fcs.outline_size = cityOutlineSize*level
		fcs.outline_color = cityOutlineColour
		fontCity.append(fcs)

		var fcc = DynamicFont.new()
		fcc.font_data = load(pathCity)
		fcc.size = int(2*citySize*citySizeCapitalMult*Cam.maxZoom/(level + 1))
		fcc.outline_size = 2*cityOutlineSize*Cam.maxZoom/(level + 1)
		fcc.outline_color = cityOutlineColour
		fontCapital.append(fcc)


#func updateCityFonts(zoomLevel : int):
#	fontCity.size = 2*citySize*Cam.maxZoom/(zoomLevel + 1)
#	fontCity.outline_size = 2*cityOutlineSize*Cam.maxZoom/(zoomLevel + 1)
#	fontCapital.size = 2*citySize*citySizeCapitalMult*Cam.maxZoom/(zoomLevel + 1)
#	fontCapital.outline_size = 2*cityOutlineSize*Cam.maxZoom/(zoomLevel + 1)

func getFontCity(zoomLevel : int):
	return fontCity[zoomLevel]

func getFontCapital(zoomLevel : int):
	return fontCapital[zoomLevel]

func getFontCityCam():
	return getFontCity(Cam.getIndexedZoomLevel())

func getFontCapitalCam():
	return getFontCapital(Cam.getIndexedZoomLevel())






