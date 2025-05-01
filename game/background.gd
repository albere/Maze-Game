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
	
	# Find the maze node
	var maze_node = get_node("/root/Main")  # Adjust this path to where your maze is
	if maze_node:
		# Print the constants
		print("Maze CONSTANTS - WIDTH:", maze_node.WIDTH, " HEIGHT:", maze_node.HEIGHT)
		
		# Print the actual render size
		var viewport_size = get_viewport().size
		print("Viewport size:", viewport_size)
		
		# Get the actual maze size after any scaling
		print("Maze scale:", maze_node.scale)
		print("Calculated maze size from scale - WIDTH:", maze_node.WIDTH * maze_node.scale.x, 
			  " HEIGHT:", maze_node.HEIGHT * maze_node.scale.y)
		
		# Try to access bounding box
		print("Maze position:", maze_node.position)
		if "get_rect" in maze_node:
			var rect = maze_node.get_rect()
			print("Maze get_rect() size:", rect.size)
		
		# Debug important info
		print("--------- IMPORTANT DEBUG INFO ---------")
		print("Viewport height:", viewport_size.y)
		print("Maze constant HEIGHT:", maze_node.HEIGHT)
		print("Maze parent:", maze_node.get_parent().name, " class:", maze_node.get_parent().get_class())
		var root = get_tree().get_root()
		print("Root window size:", root.size)
		print("Root content scale factor:", root.content_scale_factor)
		print("Stretch mode:", ProjectSettings.get_setting("display/window/stretch/mode"))
		print("Stretch aspect:", ProjectSettings.get_setting("display/window/stretch/aspect"))
		
		# Calculate the actual scale factor being applied by the viewport stretching
		var scale_factor = min(viewport_size.x / maze_node.WIDTH, viewport_size.y / maze_node.HEIGHT)
		var actual_maze_x = maze_node.WIDTH * scale_factor
		var actual_maze_y = maze_node.HEIGHT * scale_factor
		
		print("Calculated viewport scale factor:", scale_factor)
		print("Actual displayed maze dimensions - x:", actual_maze_x, " y:", actual_maze_y)
		
		# Get original texture size
		var original_texture_x = sprite.texture.get_width()
		var original_texture_y = sprite.texture.get_height()
		print("Original texture - x:", original_texture_x, " y:", original_texture_y)
		
		# Calculate using actual maze size (for landscape mode)
		var target_x = viewport_size.x - actual_maze_x  # Background width
		var target_y = actual_maze_y                    # Background height
		
		print("Target dimensions - x:", target_x, " y:", target_y)
		
		# Calculate scale factors
		var scale_x = target_x / original_texture_x
		var scale_y = target_y / original_texture_y
		
		# Apply scale
		sprite.scale = Vector2(scale_x, scale_y)
		
		# Position sprite
		sprite.position = Vector2(
			actual_maze_x + (target_x / 2),  # Center of area to right of maze
			target_y / 2                     # Center of background height
		)
		
		print("Background adjusted - Position x:", sprite.position.x, " y:", sprite.position.y)
		print("Background adjusted - Scale x:", sprite.scale.x, " y:", sprite.scale.y)
		print("Final background size - x:", original_texture_x * sprite.scale.x, " y:", original_texture_y * sprite.scale.y)
	else:
		print("Could not find maze node at /root/Main")
		
		# Fallback to fixed values if maze node not found
		var viewport_size = get_viewport().size
		var maze_x = 675  # Fixed maze width
		var maze_y = 675  # Fixed maze height
		
		# Calculate scale factor based on viewport size
		var scale_factor = min(viewport_size.x / maze_x, viewport_size.y / maze_y)
		var actual_maze_x = maze_x * scale_factor
		var actual_maze_y = maze_y * scale_factor
		
		# Calculate target dimensions for the background
		var target_x = viewport_size.x - actual_maze_x  # Background width
		var target_y = actual_maze_y                    # Background height
		
		# Get original texture size
		var original_texture_x = sprite.texture.get_width()
		var original_texture_y = sprite.texture.get_height()
		
		# Calculate scale factors
		var scale_x = target_x / original_texture_x
		var scale_y = target_y / original_texture_y
		
		# Apply scale
		sprite.scale = Vector2(scale_x, scale_y)
		
		# Position sprite
		sprite.position = Vector2(
			actual_maze_x + (target_x / 2),  # Center of area to right of maze
			target_y / 2                     # Center of background height
		)
