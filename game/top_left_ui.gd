extends CanvasLayer

var maze_reference = null

# Adjust these margins as needed
var margin_x = 20  # Horizontal margin from the maze
var margin_y = 20  # Vertical margin from the top of the screen

func _ready():
	# Set this layer to be above the background but below other UI
	layer = 5
	
	# Wait a frame to allow Main node to initialize
	call_deferred("find_maze_reference")
	
	# Connect to viewport resize signal
	get_viewport().size_changed.connect(update_position)
	
	# Connect button signals
	var reset_button = $Control/Topleftbuttons/Reset
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
		print("Reset button connected")
		
		# Create bitmap for mask from button texture
		var bitmap = BitMap.new()
		var img = reset_button.texture_normal.get_image()
		bitmap.create_from_image_alpha(img)
		reset_button.texture_click_mask = bitmap
	
	# If you have a New button, connect it too
	var new_button = $Control/Topleftbuttons/Newm  # Adjust path as needed
	if new_button:
		new_button.pressed.connect(_on_new_pressed)
		print("New button connected")
		
		# Create bitmap for mask from button texture if needed
		var bitmap = BitMap.new()
		var img = new_button.texture_normal.get_image()
		bitmap.create_from_image_alpha(img)
		new_button.texture_click_mask = bitmap

func find_maze_reference():
	# Find the maze node (Main node)
	maze_reference = get_tree().get_root().get_node_or_null("Main")
	
	if maze_reference:
		print("TopLeftUI found maze reference")
		update_position()
	else:
		# Try again in the next frame
		print("TopLeftUI couldn't find maze reference, trying again...")
		call_deferred("find_maze_reference")

func update_position():
	# Skip if maze reference isn't available yet
	if !maze_reference:
		return
	
	# Get maze dimensions
	var maze_width = maze_reference.WIDTH
	var maze_height = maze_reference.HEIGHT
	
	# Get screen dimensions for responsive layout
	var screen_size = DisplayServer.window_get_size()
	var is_landscape = screen_size.x > screen_size.y
	
	# Get our UI texture
	var ui_texture = $Control/Topleftbuttons
	if !ui_texture:
		print("ERROR: TopLeftTexture not found!")
		return
		
	# IMPORTANT: Reset the offset to zero to ensure consistent positioning
	self.offset = Vector2.ZERO
	
	if is_landscape:
		# LANDSCAPE MODE
		# Position it at the top-left corner of the right UI area
		var new_position = Vector2(
			maze_width + margin_x,  # To the right of the maze
			margin_y                # At the top of the screen
		)
		
		# Position the texture directly
		ui_texture.global_position = new_position
		
		# Debug information
		print("Maze width:", maze_width)
		print("Positioned TopLeftUI texture at global position:", ui_texture.global_position)

	else:
		# PORTRAIT MODE - placeholder for now
		var new_position = Vector2(20, maze_height + margin_y)
		ui_texture.global_position = new_position
		print("Positioned TopLeftUI at:", new_position, " (portrait mode - placeholder)")
		

# Helper function to add a visible debug marker
func add_debug_marker(pos):
	# Remove any existing debug marker
	if has_node("DebugMarker"):
		var old_marker = get_node("DebugMarker")
		remove_child(old_marker)
		old_marker.queue_free()
	
	# Create a small visible label as a position marker
	var marker = Label.new()
	marker.name = "DebugMarker"
	marker.text = "X"
	marker.add_theme_color_override("font_color", Color(1, 0, 0)) # Red
	marker.add_theme_font_size_override("font_size", 24)
	marker.position = pos - Vector2(5, 5) # Adjust to center the X
	add_child(marker)

# Handler for Reset button - resets player position to center
func _on_reset_pressed():
	print("Reset button pressed!")
	if maze_reference:
		# Reset player position to center of maze
		maze_reference.player_pos = Vector2(maze_reference.COLS / 2, maze_reference.ROWS / 2)
		# Clear trail except for current position
		maze_reference.trail = [maze_reference.player_pos]
		print("Player reset to center position")
	else:
		print("Cannot reset player - maze reference not found")

# Handler for New button - regenerates maze
func _on_new_pressed():
	print("New maze button pressed!")
	if maze_reference:
		# Call the maze's reset function to regenerate it
		maze_reference.reset_maze()
		print("Generated new maze")
	else:
		print("Cannot generate new maze - maze reference not found")
