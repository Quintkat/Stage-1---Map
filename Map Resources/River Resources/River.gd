extends Control

# Constants
const RiverSegment = preload("res://Map Resources/River Resources/RiverSegment.tscn")

# River info
var rName = ""
var startPos : Vector2

# River actualisation
var tileWidth : int
var segments = []


func init(n : String, sp : Vector2, tw : int, r : Dictionary):
	rName = n
	startPos = sp
	tileWidth = tw
	setup(r)
	

func setup(segments : Dictionary):
	rect_position = startPos*tileWidth
	var sPos = Vector2(0, 0)
	var offset = tileWidth*Vector2(1, 1)/2
	var dirVectors = {
		"N"	:	Vector2(0, -1),
		"E"	:	Vector2(1, 0),
		"S"	:	Vector2(0, 1),
		"W"	:	Vector2(-1, 0)
	}
	var dirRotations = {
		"N"	:	180,
		"E"	:	270,
		"S"	:	0,
		"W"	:	90
	}
	var maxSize = "small"		# The max size of the river, necessary to see where the cutoff is
	for size in Rivers.sizes:
		if size in segments:
			maxSize = size
	
	for size in Rivers.sizes:
		if !(size in segments):
			continue
			
		for i in len(segments[size]):
			var segment = segments[size][i]
			var dir = segment[0]	# The "N" in "N3"
			var scalar = int(segment.substr(1, len(segment) - 1))	# The 3 in "N3"
			
			# Create the river segment
			var riverS = RiverSegment.instance()
			add_child(riverS)
			riverS.rect_rotation = dirRotations[dir]
			riverS.rect_position = tileWidth*sPos + offset	# Bring it to the center of the tile
			riverS.rect_position -= tileWidth*riverS.sizePresets[size]*Vector2(cos(deg2rad(dirRotations[dir])), sin(deg2rad(dirRotations[dir])))/2	# Offset it based on its width
			if i == len(segments[size]) - 1 and size == maxSize:
				riverS.init(tileWidth, size, scalar, true)
			else:
				riverS.init(tileWidth, size, scalar)
			
			# Update the running position of the next river segment
			sPos += scalar*dirVectors[dir]
#	var riverS = RiverSegment.instance()
#	riverS.init(tileWidth, "medium")
#	add_child(riverS)
