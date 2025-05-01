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
	print("Viewport size - x:", viewport_size.x, " y:", viewport_size.y)
	
	# Maze dimensions
	var maze_x = 675  # Maze width (x dimension)
	var maze_y = 675  # Maze height (y dimension)
	
	# Get original texture size
	var original_texture_x = sprite.texture.get_width()
	var original_texture_y = sprite.texture.get_height()
	print("Original texture - x:", original_texture_x, " y:", original_texture_y)
	
	# LANDSCAPE MODE ONLY
	
	# Calculate target dimensions for the background
	var target_x = viewport_size.x - maze_x  # Background width
	var target_y = maze_y                    # Background height
	
	print("Target dimensions - x:", target_x, " y:", target_y)
	
	# Calculate scale factors
	var scale_x = target_x / original_texture_x
	var scale_y = target_y / original_texture_y
	
	# Apply scale
	sprite.scale = Vector2(scale_x, scale_y)
	
	# Position sprite
	sprite.position = Vector2(
		maze_x + (target_x / 2),  # Center of area to right of maze
		target_y / 2              # Center of background height
	)
	
	print("Background adjusted - Position x:", sprite.position.x, " y:", sprite.position.y)
	print("Background adjusted - Scale x:", sprite.scale.x, " y:", sprite.scale.y)
	print("Final size - x:", original_texture_x * sprite.scale.x, " y:", original_texture_y * sprite.scale.y)
