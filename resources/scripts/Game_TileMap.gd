extends Node2D

var table_height = 20
var table_width = 10

var score = 0

var block_size = Vector2(32, 32)

var table = {}

var can_move = true

var timer = 0

var current_block
var current_block_position
var current_block_sprites
var rotated = 0

var unit_sprite = preload("res://resources/scenes/Sprite.tscn")
var block_types2 = preload("res://resources/scripts/Game_BlockTypes.gd").new().blocks

# Initiates everything.
func _ready():
	randomize()
	setup_board()
	new_block()
	set_process(true)
	set_process_input(true)
	pass

# Update sprites of the falling block.
func update_block_sprites():
	var edge_length = sqrt(current_block[rotated].size())
	var i = 0
	for x in range(edge_length):
		for y in range(edge_length):
			if current_block[rotated][x + y * edge_length] == 1:
				var sprite_pos = Vector2(
						x * block_size.x + 
						position_to_blocks(current_block_position).x * block_size.x,
						y * block_size.y +
						position_to_blocks(current_block_position).y * block_size.y)

				current_block_sprites[i].position = sprite_pos
				i+=1

# Creates a new block at the starting position.
func new_block():
	rotated = 0
	current_block = block_types2[rand_range(0, block_types2.size())]
	#current_block = block_types2[5]
	current_block_position = blocks_to_position(Vector2(table_width/2-2, 0))
	current_block_sprites = []
	for block in get_block_positions(current_block[rotated]):
		if table[block] != null:
			game_over()
			return
	var color = Color(randf(), randf(), randf())
	for i in range(4):
		var rotate = rand_range(0, 1)
		var sprite = unit_sprite.instance()
		sprite.set_modulate(color)
		if rotate > 0.5:
			sprite.rotation = PI/2
		current_block_sprites.append(sprite)
		add_child(sprite)
	update_block_sprites()

# Returns the given position in blocks.
func position_to_blocks(pos):
	return Vector2(floor(pos.x / block_size.x), floor(pos.y / block_size.y))

# Returns the given blocks in position.
func blocks_to_position(pos):
	return Vector2(pos.x * block_size.x, pos.y * block_size.y)

# Returns an array of all positions of the falling
# blocks' sprites
func get_block_positions(blocks):
	var edge_length = sqrt(current_block[rotated].size())
	var returned = []
	for x in range(edge_length):
		for y in range(edge_length):
			if blocks[x + y * edge_length] == 1:
				returned.append(position_to_blocks(current_block_position) + Vector2(x, y))
	return returned

# Returns wether or not the block can be moved
# in that direction
func is_movable(pos):
	var block_positions = get_block_positions(current_block[rotated])
	
	if pos.x != 0:
		for block in block_positions:
			if block.x + pos.x >= table_width or block.x + pos.x < 0:
				return false
			if table[Vector2(block.x + pos.x, block.y)] != null:
				return false
	if pos.y > 0:
		for block in block_positions:
			if block.y + pos.y >= table_height:
				return false
			if table[Vector2(block.x, block.y + pos.y)] != null:
				return false
	return true

# Writes the current block to map.
func write_to_map():
	var i = 0
	for block in get_block_positions(current_block[rotated]):
		table[Vector2(block.x, block.y)] = current_block_sprites[i]
		current_block_sprites[i].position = block * block_size
		i+=1
	check_won()

func move_gap(gap_lines):
	gap_lines.sort()
	gap_lines.invert()
	var move = 1
	var next_index = 0
	for y in range(gap_lines[0], 0, -1):
		# if y reaches the current examing bingo_y line, add next_index by 1
		if y == gap_lines[next_index] and next_index < gap_lines.size()-1:
			next_index += 1
				
		# find continuous bingo lines
		var tmp_index = next_index
		while move < gap_lines.size() and y - move == gap_lines[tmp_index]:
			move+=1
			tmp_index+=1
				
		# if (y - move) reaches top, exit
		if y - move < 0:
			break
				
		for x in range(table_width):
			table[Vector2(x, y)] = table[Vector2(x, y-move)]
			if table[Vector2(x, y)] != null:
				table[Vector2(x, y)].position = Vector2(x * block_size.x, y * block_size.y)
			table[Vector2(x, y-move)] = null

func remove_line(pos):
	for x in range(table_width):
		table[Vector2(x, pos)].queue_free()
		table[Vector2(x, pos)] = null
	var lines = [pos]
	move_gap(lines)

func check_won():
	var so_far = 1
	for y in range(table_height):
		for x in range(table_width):
			if table[Vector2(x, y)] == null:
				so_far = 0
		if so_far == 1:
			remove_line(y)
			score+=1000
		else:
			so_far = 1

func move(pos):
	current_block_position += blocks_to_position(pos)
	update_block_sprites()

func game_over():
	setup_board()
	var sprites = get_node(".").get_children()
	for sprite in sprites:
		sprite.queue_free()
	new_block()
	score = 0

func is_rotateable():
	var rotated_t = rotate()
	for pos in get_block_positions(current_block[rotated_t]):
		if pos.x < 0 or pos.x >= table_width or pos.y >= table_height:
			return false
		if table[pos] != null:
			return false
	return true

func rotate():
	#rotate = rotate + 1
	if current_block.size() - 1 > rotated:
		return rotated + 1
	else:
		return 0

func _input(event):
	if event.is_action_pressed("ui_left"):
		if is_movable(Vector2(-1, 0)):
			move(Vector2(-1, 0))
	if event.is_action_pressed("ui_right"):
		if is_movable(Vector2(1, 0)):
			move(Vector2(1, 0))
	if event.is_action_pressed("ui_up"):
		if is_rotateable():
			rotated = rotate()
			update_block_sprites()
	if event.is_action_pressed("ui_down"):
		if is_movable(Vector2(0, 1)):
			move(Vector2(0, 1))

func _process(dtime):
	timer += dtime
	if timer > 0.5:
		timer = 0
		if is_movable(Vector2(0, 1)):
			move(Vector2(0, 1))
		else:
			write_to_map()
			new_block()

# Prepare the board.
func setup_board():
	for x in range(table_width):
		for y in range(table_height):
			table[Vector2(x, y)] = null