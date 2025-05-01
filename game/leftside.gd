extends CanvasLayer

var maze_reference = null

# Adjust these margins as needed
var margin_x = 40
var margin_y = 20

func _ready():
	# Set this layer to be above the background but below other UI if needed
	layer = -5
	
	# Wait a frame to allow Main node to initialize
	call_deferred("find_maze_reference")
	
	# Connect to viewport resize signal
	get_viewport().size_changed.connect(update_position)

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
	var ui_texture = $TopLeftTexture
	if !ui_texture:
		print("ERROR: TopLeftTexture not found!")
		return
	
	if is_landscape:
		# LANDSCAPE MODE
		# Position to the right side of the maze
		var new_position = Vector2(
			maze_width + margin_x,
			margin_y
		)
		
		ui_texture.position = new_position
		print("Positioned TopLeftUI at:", new_position, " (landscape mode)")
	else:
		# PORTRAIT MODE - placeholder for now
		var new_position = Vector2(20, maze_height + margin_y)
		ui_texture.position = new_position
		print("Positioned TopLeftUI at:", new_position, " (portrait mode - placeholder)")
