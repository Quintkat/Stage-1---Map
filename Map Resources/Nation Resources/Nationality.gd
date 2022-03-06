extends Node

const NAT_DEFAULT = "default"
const NAT_BOGARDIA = "Bogardia"
const NAT_DELUGIA = "Delugia"
const NAT_FLUSSLAND = "Flussland"
const NAT_SASBYRG = "Sasbyrg-Tylos"
const NAT_TISGYAR = "Tisgyar"
const NAT_TROPODEIA = "Tropodeia"
const NAT_ZUMOLAIA = "Zumolaia"

# Used for seeing what colour is associated with a nationality
const colour = {
	NAT_DEFAULT			: Color("#FFFFFF"),
	NAT_BOGARDIA		: Color("#E53232"),
	NAT_DELUGIA			: Color("#52F2EF"),
	NAT_FLUSSLAND		: Color("#DB8A00"),
	NAT_SASBYRG			: Color("#73EF3E"),
	NAT_TISGYAR			: Color("#EF9B87"),
	NAT_TROPODEIA		: Color("#76C1E2"),
	NAT_ZUMOLAIA		: Color("#F3DEB6"),
}

# Used for seeing what nationality something is based on a colour (for reading a map image)
var nationality = {}


func _init():
	for n in colour:
		nationality[colour[n]] = n


func colour(n):
	if !(n in colour):
		return colour[NAT_DEFAULT]
	return colour[n]

func nationality(c):
	if !(c in nationality):
		return NAT_DEFAULT
	return nationality[c]
