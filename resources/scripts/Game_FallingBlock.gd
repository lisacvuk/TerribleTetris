extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var time = 0

var tiles = [1, 1, 1,
			 0, 0, 1,
			 0, 0, 0]

func set_pos(pos):
	global_position = pos
func get_vectorpos(pos):
	var returned = Vector2(pos%3, pos/3)
	return returned
func get_tilepos(pos):
	var returned = pos.y * 3 + pos.x
	return returned
func loop_around(pos, origin):
	var m = Transform2D(Vector2(1, 0), Vector2(0, 1), origin)
	m.rotated(PI/2)
	var returned = m.xform(pos)
	return returned
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for i in range(0, tiles.size()):
		if tiles[i] == 1:
			get_node("Collision" + str(i)).disabled = false
			get_node("Sprite" + str(i)).texture = load("res://resources/images/tile_green.png")
	pass
func move_left():
	global_position-=Vector2(32, 0)
func move_right():
	global_position+=Vector2(32, 0)
func rotate_90():
	for i in range(0, tiles.size()):
		if tiles[i] == 1:
			get_node("Collision" + str(i)).disabled = true
			get_node("Sprite" + str(i)).texture = load("")
			var old_tilepos = get_vectorpos(i)
			var new_tilepos = loop_around(old_tilepos, get_vectorpos(5))
			var newpos = get_tilepos(new_tilepos)
			tiles[i] = 0
			print(newpos)
			if newpos > 8: 
				return
			tiles[newpos] = 1
			get_node("Collision" + str(newpos)).disabled = false
			get_node("Sprite" + str(newpos)).texture = load("res://resources/images/tile_green.png")

func _process(delta):
	time+=delta
	if Input.is_action_just_pressed("ui_left"):
		move_left()
	if Input.is_action_just_pressed("ui_right"):
		move_right()
	if Input.is_action_just_pressed("ui_up"):
		rotate_90()
	if time > 0.5:
		time = 0
		
		var collision = move_and_collide(Vector2(0,32))
		if collision: 
			# Make this falling block a part of the map,
			# and fall again.
			for i in range(0, tiles.size()):
				if tiles[i] == 1:
					var tile_pos = get_node("../TileMap").world_to_map(global_position) - Vector2(1, 0)
					tile_pos+=Vector2(i%3, i/3)
					print(Vector2(i%3, i/3))
					get_node("../TileMap").set_cellv(tile_pos, 0)
			global_position = Vector2(32, 16)
			rotate(0)
	pass
