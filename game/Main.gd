extends Node2D

const CELL_SIZE = 15
const ROWS = 41
const COLS = 41
const BORDER_WIDTH = 2
const WIDTH = (COLS + BORDER_WIDTH * 2) * CELL_SIZE
const HEIGHT = (ROWS + BORDER_WIDTH * 2) * CELL_SIZE

const DARK_BLUE = Color(0.07, 0.22, 0.49)
const WHITE = Color(1, 1, 1)
const ORANGE = Color(0.91, 0.71, 0.19)

@onready var player_img = preload("res://assets/supe.png")
@onready var heart_img = preload("res://assets/heart.png")
@onready var brain_img = preload("res://assets/brain.jpg")

# Add this near your other preloads in Main.gd
@onready var dpad_scene = preload("res://d_pad.tscn")

var maze = []
var trail = []
var player_pos = Vector2()
var end_1 = Vector2(1, 1)
var end_2 = Vector2(COLS - 2, 1)
var last_move_time = 0
var move_delay = 0.2
var dpad_width = 100
var dpad_height = 100

# Define these functions first, before calling them

func find_center_sprite(dpad):
	# Try to find a Sprite2D named "center"
	if dpad.has_node("Truecenter"):
		return dpad.get_node("Truecenter")
	
	# Search through immediate children
	for child in dpad.get_children():
		if child.name == "Truecenter" and child is Node2D:
			return child
	
	# Search one level deeper
	for child in dpad.get_children():
		if child.has_node("Truecenter"):
			var potential_center = child.get_node("Truecenter")
			if potential_center is Node2D:
				return potential_center
	
	# If we get here, we couldn't find it
	return null
	
func handle_orientation(dpad):
	var screen_size = DisplayServer.window_get_size()
	var width = screen_size.x
	var height = screen_size.y
	
	print("DEBUG - Screen Width: ", width)
	print("DEBUG - Screen Height: ", height)
	
	if width > height:
		setup_landscape_mode(dpad)
	else:
		setup_portrait_mode(dpad)

func setup_landscape_mode(dpad):
	print("Setting up LANDSCAPE mode")
	# Position the D-pad to the right side of the screen
	var maze_center_y = HEIGHT / 2
	dpad.offset = Vector2(WIDTH + 20, maze_center_y)
	
	var center_sprite = find_center_sprite(dpad)
	if center_sprite:
		print("Found center sprite in D-pad")
		# Calculate how much to adjust to align the center sprite with maze center
		var sprite_pos = center_sprite.position
		var sprite_size = center_sprite.get_rect().size * center_sprite.scale
		var sprite_center_y = sprite_pos.y + (sprite_size.y / 2)
		
		dpad.offset.y = maze_center_y - sprite_center_y
		print("Adjusted D-pad position based on center sprite")
	else:
		print("Could not find center sprite in D-pad")
		
	# Adjust scale as needed
	dpad.scale = Vector2(1.2, 1.2)

func setup_portrait_mode(dpad):
	print("Setting up PORTRAIT mode")
	var maze_center_x = WIDTH / 2
	# Position the D-pad at the bottom of the screen
	dpad.offset = Vector2(maze_center_x - (dpad_width / 2), HEIGHT + 20)
	# Make D-pad bigger for touch in portrait mode
	dpad.scale = Vector2(1.5, 1.5)
	

# Then add this code in your _ready() function
func _ready():
	maze = generate_maze()
	reset_maze()
	set_process(true)
	queue_redraw()

	# Add D-pad to the scene
	var dpad = dpad_scene.instantiate()
	add_child(dpad)
	
	handle_orientation(dpad)
	
	print("D-pad added to scene: ", dpad)
	# Position the D-pad next to the maze
	# Adjust these values based on your maze size and preferred position

   # Connect D-pad signals
	dpad.connect("move_up", _on_dpad_move_up)
	dpad.connect("move_down", _on_dpad_move_down)
	dpad.connect("move_left", _on_dpad_move_left)
	dpad.connect("move_right", _on_dpad_move_right)

	
# Add these handler functions
func _on_dpad_move_up():
	if maze[player_pos.y - 1][player_pos.x] == 0:
		var new_pos = player_pos + Vector2(0, -1)
		process_movement(new_pos)

func _on_dpad_move_down():
	if maze[player_pos.y + 1][player_pos.x] == 0:
		var new_pos = player_pos + Vector2(0, 1)
		process_movement(new_pos)

func _on_dpad_move_left():
	if maze[player_pos.y][player_pos.x - 1] == 0:
		var new_pos = player_pos + Vector2(-1, 0)
		process_movement(new_pos)

func _on_dpad_move_right():
	if maze[player_pos.y][player_pos.x + 1] == 0:
		var new_pos = player_pos + Vector2(1, 0)
		process_movement(new_pos)

# Add a helper function to handle movement logic
func process_movement(new_pos):
	if trail.size() > 1 and new_pos == trail[trail.size() - 2]:
		trail.pop_back()
	else:
		trail.append(new_pos)
	player_pos = new_pos

	if player_pos == end_1:
		show_message("Heart")
		reset_maze()
	elif player_pos == end_2:
		show_message("Brain")
		reset_maze()

func reset_maze():
	var m = generate_maze()
	m[end_1.y][end_1.x] = 0
	m[end_2.y][end_2.x] = 0
	maze = m
	player_pos = Vector2(COLS / 2, ROWS / 2)
	maze[player_pos.y][player_pos.x] = 0
	trail = [player_pos]

func generate_maze():
	var m = []
	var visited = []
	for y in ROWS:
		m.append([])
		visited.append([])
		for x in range(COLS):
			m[y].append(1)
			visited[y].append(false)
	_carve_passages(m, visited, 1, 1)
	return m

func _carve_passages(maze, visited, cx, cy):
	var dirs = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	dirs.shuffle()
	visited[cy][cx] = true
	maze[cy][cx] = 0
	for d in dirs:
		var nx = cx + int(d.x) * 2
		var ny = cy + int(d.y) * 2
		if _is_valid(nx, ny) and not visited[ny][nx]:
			maze[cy + int(d.y)][cx + int(d.x)] = 0
			_carve_passages(maze, visited, nx, ny)

func _is_valid(x, y):
	return x >= 0 and y >= 0 and x < COLS and y < ROWS

func _process(delta):
	last_move_time += delta
	if last_move_time >= move_delay:
		handle_input()
		last_move_time = 0
	queue_redraw()

func handle_input():
	var moved = false
	var new_pos = player_pos
	if Input.is_action_pressed("ui_left") and maze[player_pos.y][player_pos.x - 1] == 0:
		new_pos.x -= 1
		moved = true
	elif Input.is_action_pressed("ui_right") and maze[player_pos.y][player_pos.x + 1] == 0:
		new_pos.x += 1
		moved = true
	elif Input.is_action_pressed("ui_up") and maze[player_pos.y - 1][player_pos.x] == 0:
		new_pos.y -= 1
		moved = true
	elif Input.is_action_pressed("ui_down") and maze[player_pos.y + 1][player_pos.x] == 0:
		new_pos.y += 1
		moved = true

	if moved:
		if trail.size() > 1 and new_pos == trail[trail.size() - 2]:
			trail.pop_back()
		else:
			trail.append(new_pos)
		player_pos = new_pos

		if player_pos == end_1:
			show_message("Heart")
			reset_maze()
		elif player_pos == end_2:
			show_message("Brain")
			reset_maze()

func show_message(text):
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", WHITE)
	label.set_position(Vector2(WIDTH / 2, HEIGHT / 2))
	add_child(label)
	await get_tree().create_timer(2).timeout
	remove_child(label)
	label.queue_free()

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(WIDTH, HEIGHT)), DARK_BLUE)
	for y in range(ROWS):
		for x in range(COLS):
			var color = WHITE if maze[y][x] == 0 else DARK_BLUE
			var rect = Rect2(Vector2((x + BORDER_WIDTH) * CELL_SIZE, (y + BORDER_WIDTH) * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			draw_rect(rect, color)

	for i in range(1, trail.size()):
		var p1 = (trail[i - 1] + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
		var p2 = (trail[i] + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
		draw_line(p1, p2, ORANGE, 2)

	var player_rect = Rect2((player_pos + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE, Vector2(20, 20))
	draw_texture_rect(player_img, player_rect, false)
	var heart_rect = Rect2(((end_1 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE), Vector2(20, 20))
	draw_texture_rect(heart_img, heart_rect, false)
	var brain_rect = Rect2(((end_2 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE), Vector2(20, 20))
	draw_texture_rect(brain_img, brain_rect, false)

	# draw_texture_rect(player_img, player_rect, false)
	# draw_texture(player_img, (player_pos + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)
	# draw_texture(heart_img, (end_1 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)
	# draw_texture(brain_img, (end_2 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)
