extends Node

var blocks = [[
	# First L
	[1, 1, 1,
	 1, 0, 0, 
	 0, 0, 0],
	[0, 1, 1,
	 0, 0, 1,
	 0, 0, 1],
	[0, 0, 0,
	 0, 0, 1,
	 1, 1, 1],
	[1, 0, 0,
	 1, 0, 0,
	 1, 1, 0]],
	# Cube shape
	[[
	 1, 1, 0,
	 1, 1, 0,
	 0, 0, 0]],
	# Second L
	[[
	 1, 1, 1,
	 0, 0, 1,
	 0, 0, 0],
	[0, 0, 1,
	 0, 0, 1,
	 0, 1, 1],
	[0, 0, 0,
	 1, 0, 0,
	 1, 1, 1],
	[1, 1, 0,
	 1, 0, 0,
	 1, 0, 0]],
	# Triange
	[[
	 1, 1, 1,
	 0, 1, 0,
	 0, 0, 0],
	[0, 0, 1,
	 0, 1, 1,
	 0, 0, 1],
	[0, 0, 0,
	 0, 1, 0,
	 1, 1, 1],
	[1, 0, 0,
	 1, 1, 0,
	 1, 0, 0]],
	# First Z
	[[
	 1, 1, 0,
	 0, 1, 1,
	 0, 0, 0],
	[0, 0, 1,
	 0, 1, 1,
	 0, 1, 0],
	[0, 0, 0,
	 1, 1, 0,
	 0, 1, 1],
	[0, 1, 0,
	 1, 1, 0,
	 1, 0, 0]],
	# Second Z
	[[
	 0, 1, 1,
	 1, 1, 0,
	 0, 0, 0],
	[0, 1, 0,
	 0, 1, 1,
	 0, 0, 1],
	[0, 0, 0,
	 0, 1, 1,
	 1, 1, 0],
	[1, 0, 0,
	 1, 1, 0,
	 0, 1, 0]],
	# Space
	[[
	 0, 0, 0, 0,
	 1, 1, 1, 1,
	 0, 0, 0, 0,
	 0, 0, 0, 0],
	[0, 0, 1, 0,
	 0, 0, 1, 0,
	 0, 0, 1, 0,
	 0, 0, 1, 0],
	[0, 0, 0, 0,
	 0, 0, 0, 0,
	 1, 1, 1, 1,
	 0, 0, 0, 0],
	[0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 1, 0, 0]
	]]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
