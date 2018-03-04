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

var unit_sprite = preload("res://resources/scenes/Sprite.tscn")

var block_types = [
	[0, 1, 1, 0,
	 0, 1, 0, 0,
	 0, 1, 0, 0,
	 0, 0, 0, 0],
	[0, 1, 1, 0,
	 0, 0, 1, 0,
	 0, 0, 1, 0,
	 0, 0, 0, 0],
	[0, 0, 0, 0,
	 0, 1, 1, 0, 
	 0, 1, 1, 0,
	 0, 0, 0, 0],
	[1, 1, 1, 1,
	 0, 0, 0, 0,
	 0, 0, 0, 0,
	 0, 0, 0, 0],
	[0, 1, 0, 0,
	 0, 1, 1, 0,
	 0, 1, 0, 0,
	 0, 0, 0, 0],
]

# Initiates everything.
func _ready():
	setup_board()
	new_block()
	set_process(true)
	set_process_input(true)
	pass

# Update sprites of the falling block.
func update_block_sprites():
	var i = 0
	for x in range(4):
		for y in range(4):
			if current_block[x + y * 4] == 1:
				var sprite_pos = Vector2(
						x * block_size.x + 
						position_to_blocks(current_block_position).x * block_size.x,
						y * block_size.y +
						position_to_blocks(current_block_position).y * block_size.y)

				current_block_sprites[i].position = sprite_pos
				i+=1

# Creates a new block at the starting position.
func new_block():
	current_block = block_types[randi()%block_types.size()]
	current_block_position = blocks_to_position(Vector2(table_width/2-2, 0))
	current_block_sprites = []
	for block in get_block_positions(current_block):
		if table[block] != null:
			game_over()
			return
	var color = Color(randf(), randf(), randf())
	for i in range(4):
		var sprite = unit_sprite.instance()
		sprite.set_modulate(color)
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
	var returned = []
	for x in range(4):
		for y in range(4):
			if blocks[x + y * 4] == 1:
				returned.append(position_to_blocks(current_block_position) + Vector2(x, y))
	return returned

# Returns wether or not the block can be moved
# in that direction
func is_movable(pos):
	var block_positions = get_block_positions(current_block)
	
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
	for block in get_block_positions(current_block):
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
	var rotated = rotate()
	for pos in get_block_positions(rotated):
		if pos.x < 0 or pos.x >= table_width or pos.y >= table_height:
			return false
		if table[pos] != null:
			return false
	return true

func rotate():
	var b = Array()
	for i in [3, 2, 1, 0]:
		b.append(current_block[i])
		b.append(current_block[i+4])
		b.append(current_block[i+8])
		b.append(current_block[i+12])
	return b

func _input(event):
	if event.is_action_pressed("ui_left"):
		if is_movable(Vector2(-1, 0)):
			move(Vector2(-1, 0))
	if event.is_action_pressed("ui_right"):
		if is_movable(Vector2(1, 0)):
			move(Vector2(1, 0))
	if event.is_action_pressed("ui_up"):
		if is_rotateable():
			current_block = rotate()
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