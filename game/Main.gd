extends Node2D

const CELL_SIZE = 19.285714285714
const ROWS = 31
const COLS = 31
const BORDER_WIDTH = 2
const WIDTH = (COLS + BORDER_WIDTH * 2) * CELL_SIZE
const HEIGHT = (ROWS + BORDER_WIDTH * 2) * CELL_SIZE

const BLACK = Color(0, 0, 0)
const WHITE = Color(1, 1, 1)
const BLUE = Color("#7DF9FF")

@onready var player_img = preload("res://assets/VajraIcon.png")
@onready var heart_img = preload("res://assets/Mental.png")
@onready var brain_img = preload("res://assets/City.png")
@onready var endpoint1_overlay = preload("res://assets/titlecardheart.png")
@onready var endpoint2_overlay = preload("res://assets/titlecardcity.png")
@onready var endpoint2_first_overlay = preload("res://assets/titlecardfail.png")
@onready var win_overlay = preload("res://assets/titlecardwin.png")

# Add this near your other preloads in Main.gd
@onready var dpad_scene = preload("res://d_pad.tscn")
@onready var screen_scene = preload("res://Screen.tscn")
@onready var full_bg_scene = preload("res://background_full.tscn")
@onready var top_left_ui_scene = preload("res://leftside.tscn")

var maze = []
var trail = []
var player_pos = Vector2()
var end_1 = Vector2(1, 1)
var end_2 = Vector2(COLS - 2, 1)
var last_move_time = 0
var move_delay = 0.2
var dpad_width = 100
var dpad_height = 100
var can_move = true
var endpoint1_reached = false
var endpoint2_reached = false
var show_overlay = false
var current_overlay_texture = null

# Define these functions first, before calling them

# Then add this code in your _ready() function
func _ready():
	maze = generate_maze()
	reset_maze()
	set_process(true)
	queue_redraw()

	var screen_border = screen_scene.instantiate()
	add_child(screen_border)
	print("Screen border added to scene:", screen_border)

	var full_bg = full_bg_scene.instantiate()
	add_child(full_bg)
	print("Background added to scene:", full_bg)

	var top_left_ui = top_left_ui_scene.instantiate()
	add_child(top_left_ui)
	print("Top-left UI added to scene:", top_left_ui)


# Position the border sprite to frame the maze
	var border_sprite = screen_border.get_node("Sprite2D")
	if border_sprite:
		print("Border sprite found:", border_sprite)
	# Center the border around the maze
		border_sprite.position = Vector2(WIDTH/2, HEIGHT/2)

		print("Maze WIDTH:", WIDTH)
		print("Maze HEIGHT:", HEIGHT)
		print("Border sprite position set to:", border_sprite.position)

	# Scale the border to fit the maze size
		var scale_factor = max(WIDTH / 1404.0, HEIGHT / 1400.0) + 0.01
		border_sprite.scale = Vector2(scale_factor, scale_factor)
		print("Border scale factor:", scale_factor)
		print("Border sprite scale set to:", border_sprite.scale)

	# Add D-pad to the scene
	var dpad = dpad_scene.instantiate()
	add_child(dpad)

	# Position the D-pad next to the maze
	# Adjust these values based on your maze size and preferred position

	var dpad_control = dpad.get_node("Blanklayer/DPad")
	if dpad_control:
		dpad_control.connect("move_up", Callable(self, "_on_dpad_move_up"))
		dpad_control.connect("move_down", Callable(self, "_on_dpad_move_down"))
		dpad_control.connect("move_left", Callable(self, "_on_dpad_move_left"))
		dpad_control.connect("move_right", Callable(self, "_on_dpad_move_right"))
		print("D-pad signals connected successfully")
	else:
		print("Error: Could not find DPad control node")

# Add these handler functions
func _on_dpad_move_up():
	if can_move and maze[player_pos.y - 1][player_pos.x] == 0:
		var new_pos = player_pos + Vector2(0, -1)
		process_movement(new_pos)
		last_move_time = 0
		can_move = false

func _on_dpad_move_down():
	if can_move and maze[player_pos.y + 1][player_pos.x] == 0:
		var new_pos = player_pos + Vector2(0, 1)
		process_movement(new_pos)
		last_move_time = 0
		can_move = false

func _on_dpad_move_left():
	if can_move and maze[player_pos.y][player_pos.x - 1] == 0:
		var new_pos = player_pos + Vector2(-1, 0)
		process_movement(new_pos)
		last_move_time = 0
		can_move = false

func _on_dpad_move_right():
	if can_move and maze[player_pos.y][player_pos.x + 1] == 0:
		var new_pos = player_pos + Vector2(1, 0)
		process_movement(new_pos)
		last_move_time = 0
		can_move = false

# Add a helper function to handle movement logic
func process_movement(new_pos):
	if trail.size() > 1 and new_pos == trail[trail.size() - 2]:
		trail.pop_back()
	else:
		trail.append(new_pos)
	player_pos = new_pos

	if player_pos == end_1:
		if not endpoint1_reached:
			endpoint1_reached = true
			show_overlay = true
			current_overlay_texture = endpoint1_overlay
		show_message("Heart")
	elif player_pos == end_2:
		if not endpoint2_reached:
			endpoint2_reached = true

			# Check if this is the first endpoint reached
			if not endpoint1_reached:
				show_overlay = true
				current_overlay_texture = endpoint2_first_overlay
			else:
				# Both endpoints reached in correct order - show endpoint2 overlay first
				show_overlay = true
				current_overlay_texture = endpoint2_overlay

func reset_maze():
	var m = generate_maze()
	m[end_1.y][end_1.x] = 0
	m[end_2.y][end_2.x] = 0
	maze = m
	player_pos = Vector2(COLS / 2, ROWS / 2)
	maze[player_pos.y][player_pos.x] = 0
	trail = [player_pos]

	# Reset overlay state
	endpoint1_reached = false
	endpoint2_reached = false
	show_overlay = false
	current_overlay_texture = null

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
		can_move = true
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
			if not endpoint1_reached:
				endpoint1_reached = true
				show_overlay = true
				current_overlay_texture = endpoint1_overlay
			show_message("Heart")
		elif player_pos == end_2:
			if not endpoint2_reached:
				endpoint2_reached = true

				# Check if this is the first endpoint reached
				if not endpoint1_reached:
					show_overlay = true
					current_overlay_texture = endpoint2_first_overlay
				else:
					# Both endpoints reached in correct order - show endpoint2 overlay first
					show_overlay = true
					current_overlay_texture = endpoint2_overlay
			show_message("Brain")

func _input(event):
	if show_overlay and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		# Check if we just dismissed the first endpoint overlay and both endpoints are reached
		if current_overlay_texture == endpoint2_overlay and endpoint1_reached and endpoint2_reached:
			# Show the win overlay
			current_overlay_texture = win_overlay
		else:
			# Dismiss overlay completely
			show_overlay = false
			current_overlay_texture = null

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
	draw_rect(Rect2(Vector2(0, 0), Vector2(WIDTH, HEIGHT)), BLACK)
	for y in range(ROWS):
		for x in range(COLS):
			var color = WHITE if maze[y][x] == 0 else BLACK
			var rect = Rect2(Vector2((x + BORDER_WIDTH) * CELL_SIZE, (y + BORDER_WIDTH) * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			draw_rect(rect, color)

	for i in range(1, trail.size()):
		var p1 = (trail[i - 1] + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
		var p2 = (trail[i] + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
		draw_line(p1, p2, BLUE, 2)

	var player_rect = Rect2((player_pos + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE, Vector2(20, 20))
	draw_texture_rect(player_img, player_rect, false)

	var heart_pos = end_1 + Vector2(BORDER_WIDTH - 1, BORDER_WIDTH - 1)  # Subtract 1 from both x and y
	var heart_rect = Rect2(heart_pos * CELL_SIZE, Vector2(45, 45))
	draw_texture_rect(heart_img, heart_rect, false)

	# Brain icon - shift one square up and left
	var brain_pos = end_2 + Vector2(BORDER_WIDTH - 1, BORDER_WIDTH - 1)  # Subtract 1 from both x and y
	var brain_rect = Rect2(brain_pos * CELL_SIZE, Vector2(45, 45))
	draw_texture_rect(brain_img, brain_rect, false)

	# Draw overlay if needed
	if show_overlay and current_overlay_texture:
		var overlay_rect = Rect2(Vector2(0, 0), Vector2(WIDTH, HEIGHT))
		draw_texture_rect(current_overlay_texture, overlay_rect, false)


	# draw_texture_rect(player_img, player_rect, false)
	# draw_texture(player_img, (player_pos + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)
	# draw_texture(heart_img, (end_1 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)
	# draw_texture(brain_img, (end_2 + Vector2(BORDER_WIDTH, BORDER_WIDTH)) * CELL_SIZE)