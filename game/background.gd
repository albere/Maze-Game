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
	
	# Maze dimensions
	var maze_width = 675
	var maze_height = 675
	
	# Return to normal color
	sprite.modulate = Color(1.0, 1.0, 1.0)
	
	if viewport_size.x > viewport_size.y:
		# Landscape mode - position to the right of the maze
		print("Landscape mode detected")
		
		# Calculate available space to the right of the maze
		var available_width = viewport_size.x - maze_width
		var available_height = viewport_size.y
		
		# Set position to center of available space
		sprite.position = Vector2(
			maze_width + (available_width / 2),
			available_height / 2
		)
		
		# Calculate the texture dimensions from your AtlasTexture
		var sprite_width = 1184.0  # Width from your texture
		var sprite_height = 1400.0  # Height from your texture
		
		# Stretch to fill the available space, but reduce the scale
		var scale_x = (available_width / sprite_width) * 0.5  # Reduce by 50%
		var scale_y = (available_height / sprite_height) * 0.5  # Reduce by 50%
		
		# Apply scales for X and Y (reduced)
		sprite.scale = Vector2(scale_x, scale_y)
		
	else:
		# Portrait mode - position below the maze
		print("Portrait mode detected")
		
		# Calculate available space below the maze
		var available_width = viewport_size.x
		var available_height = viewport_size.y - maze_height
		
		# Set position to center of available space
		sprite.position = Vector2(
			available_width / 2,
			maze_height + (available_height / 2)
		)
		
		# Calculate the texture dimensions
		var sprite_width = 1184.0  # Width from your texture
		var sprite_height = 1400.0  # Height from your texture
		
		# Stretch to fill the available space, but reduce the scale
		var scale_x = (available_width / sprite_width) * 0.5  # Reduce by 50%
		var scale_y = (available_height / sprite_height) * 0.5  # Reduce by 50%
		
		# Apply scales for X and Y (reduced)
		sprite.scale = Vector2(scale_x, scale_y)
	
	print("Background adjusted - Position:", sprite.position, " Scale:", sprite.scale)
