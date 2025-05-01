extends CanvasLayer

func _ready():
	print("Background script _ready called")
	
	# Set to appear behind other elements
	layer = -1
	
	# Initial setup
	adjust_background()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(adjust_background)

func adjust_background():
	# Get the sprite
	var sprite = $Indentation_Layer
	if not sprite:
		print("ERROR: Indentation_Layer not found")
		return
	
	# Get viewport size
	var viewport_size = get_viewport().size
	print("Viewport size:", viewport_size)
	
	# Find the maze node
	var maze_node = get_node("/root/Main")  # Adjust this path to your maze
	
	# Maze dimensions - use constants if maze_node is found, otherwise fallback values
	var maze_width = 675
	var maze_height = 675
	
	if maze_node:
		if "WIDTH" in maze_node and "HEIGHT" in maze_node:
			maze_width = maze_node.WIDTH
			maze_height = maze_node.HEIGHT
			print("Using maze dimensions from node - WIDTH:", maze_width, " HEIGHT:", maze_height)
	
	# Since we know the stretch mode is "viewport", calculate the scale factor manually
	# Use a safe division to avoid dividing by zero
	var scale_factor = 0.0
	if maze_height > 0:  # Avoid division by zero
		scale_factor = float(viewport_size.y) / float(maze_height)
		print("Safe scale factor calculation:", viewport_size.y, " / ", maze_height, " = ", scale_factor)
	else:
		scale_factor = 0.79  # Fallback scale (533/675 ≈ 0.79)
		print("Using fallback scale factor:", scale_factor)
	
	# Calculate actual displayed maze dimensions
	var actual_maze_x = maze_width * scale_factor
	var actual_maze_y = maze_height * scale_factor
	print("Calculated actual maze dimensions - x:", actual_maze_x, " y:", actual_maze_y)
	
	# Get original texture size
	var texture_size = sprite.texture.get_size()
	print("Original texture size:", texture_size)
	
	# Calculate dimensions for the background
	var target_x = viewport_size.x - actual_maze_x
	var target_y = actual_maze_y
	print("Target dimensions - x:", target_x, " y:", target_y)
	
	# Ensure target dimensions are positive
	if target_x <= 0:
		target_x = 100  # Fallback value
	if target_y <= 0:
		target_y = 100  # Fallback value
	
	# Calculate scale factors
	var scale_x = target_x / texture_size.x
	var scale_y = target_y / texture_size.y
	
	# Apply scale
	sprite.scale = Vector2(scale_x, scale_y)
	
	# Position sprite
	sprite.position = Vector2(
		actual_maze_x + (target_x / 2),
		target_y / 2
	)
	
	print("Background adjusted - Position:", sprite.position)
	print("Background adjusted - Scale:", sprite.scale)
	print("Final background size:", Vector2(texture_size.x * scale_x, texture_size.y * scale_y))
