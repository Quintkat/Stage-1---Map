extends Control

# Variables for calculations
var tileWidth : int
var grid
const NationLabelScene = preload("res://Map Resources/Nation Label Resources/NationLabel.tscn")

# Variables for the created labels
var nations = {}	# Nation : label

####################
# Everything in this class should work under the assumption that positions to access the grid are actually valid
# since there are no checks :|
####################


func init(tw : int, g):
	tileWidth = tw
	grid = g


func addLabel(nationality : String):
	# Create label
	var label = NationLabelScene.instance()
	add_child(label)
	label.init(nationality)
	positionLabel(label, nationality)
		

func positionLabel(label : Label, nationality : String):
	var result = getTilesNationIsolatedRectangle(nationality)
	var rect = result[0]
	var startPosRect = result[1]
	
	# Split the rectangle/"nation" into 4 quadrants, 
	# and then see whether the top-left-bottom-right or bottom-left-top-right allignment is better
	var nWidth = len(rect)
	var nHeight = len(rect[0])
	var centerPoint : Vector2 = VectorMath.vectInt(Vector2(nWidth, nHeight)/2)
	
	# Calculating the candidates for each quadrant
	var topLeftPos = getFurthest(rect, centerPoint, 0, 0, nWidth/2, nHeight/2)
	var topRightPos = getFurthest(rect, centerPoint, nWidth/2, 0, nWidth, nHeight/2)
	var botLeftPos = getFurthest(rect, centerPoint, 0, nHeight/2, nWidth/2, nHeight)
	var botRightPos = getFurthest(rect, centerPoint, nWidth/2, nHeight/2, nWidth, nHeight)
#	testRect(centerPoint + startPosRect, "#FFFFFF")
#	testRect(topLeftPos + startPosRect, "#002EFF")
#	testRect(topRightPos + startPosRect, "#FF00B2")
#	testRect(botLeftPos + startPosRect, "#00FF37")
#	testRect(botRightPos + startPosRect, "#FFD800")
	
	# Decide between upwards slope or downwards slope line
	var leftPos : Vector2
	var rightPos : Vector2
	if topLeftPos.distance_to(botRightPos) > botLeftPos.distance_to(topRightPos):
		leftPos = topLeftPos + startPosRect
		rightPos = botRightPos + startPosRect
	else:
		leftPos = botLeftPos + startPosRect
		rightPos = topRightPos + startPosRect
	
	label.rect_position = leftPos*tileWidth
	label.rect_rotation = rad2deg(leftPos.angle_to_point(rightPos)) + 180
	label.rect_size = Vector2(leftPos.distance_to(rightPos)*tileWidth, 200)
	print(label.text)
	print(leftPos)
	print(rightPos)
#	print(label.rect_position)
	print(label.rect_rotation)
	

func getFurthest(rect, center : Vector2, xMin, yMin, xMax, yMax) -> Vector2:
	var furthestPoint = center
	var currentLargestDistance = 0
	for x in range(int(xMin), int(xMax)):
		for y in range(int(yMin), int(yMax)):
			if rect[x][y] == null:
				continue
			
			var testPos = Vector2(x, y)
			var testDist = extraDistanceMetric(center, testPos)
			if  testDist > currentLargestDistance:
				furthestPoint = testPos
				currentLargestDistance = testDist
	
	return furthestPoint


# Metric that also takes into account how far from the supposed x and y axes centered on u v is
func extraDistanceMetric(u : Vector2, v : Vector2):
	var baseScore = u.distance_squared_to(v)
#	var extraScore = pow(abs(u[0] - v[0])*abs(u[1] - v[1]), 2)
	var extraScore = abs(u[0] - v[0])*abs(u[1] - v[1])
	return baseScore + extraScore


# Returns all of the tiles of a certain nationality in a rectangular grid, 
# as if it was cut out of the original grid
func getTilesNationIsolatedRectangle(nationality : String):
	
	# Find out the the bounds of the eventual rectangle
	var minXPos = len(grid)
	var maxXPos = 0
	var minYPos = len(grid[0])
	var maxYPos = 0
	
	for x in range(len(grid)):
		for y in range(len(grid[x])):
			var tile = getTile(x, y)
			if tile.getNationality() != nationality:
				continue
			
			minXPos = min(x, minXPos)
			minYPos = min(y, minYPos)
			maxXPos = max(x, maxXPos)
			maxYPos = max(y, maxYPos)
			
	# Slice the rectangle into existence
	var rect = []
	for i in range(minXPos, maxXPos + 1):
		var vertSlice = grid[i].slice(minYPos, maxYPos + 1)
		rect.append(vertSlice.duplicate())
		
	# Make all the tiles that are not of the desired nationality null, for ease of use I suppose.
	for i in range(len(rect)):
		for j in range(len(rect[i])):
			var tile = rect[i][j]
			if tile.getNationality() != nationality:
				rect[i][j] = null
	
	# For reference, the top left position of rect in the actual grid is also given
	var startPos = Vector2(minXPos, minYPos)
	
	return [rect, startPos]


func getTile(x, y):
	return grid[x][y]


func testRect(pos, c):
	var rect = ColorRect.new()
	add_child(rect)
	rect.rect_position = pos*tileWidth
	rect.rect_size = Vector2(100, 100)
	rect.color = Color(c)






