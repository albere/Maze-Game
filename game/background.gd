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
	
	if viewport_size.x > viewport_size.y:
		# Landscape mode - fill the right side
		print("Landscape mode detected")
		
		# Calculate the background dimensions directly
		var bg_width = viewport_size.x - maze_width
		var bg_height = maze_height  # Same height as maze
		
		# Calculate scale based on original texture size
		var sprite_width = 1184.0
		var sprite_height = 1400.0
		
		var scale_x = bg_width / sprite_width
		var scale_y = bg_height / sprite_height
		
		sprite.scale = Vector2(scale_x, scale_y)
		
		# Position exactly to the right of the maze
		sprite.position = Vector2(
			maze_width + (bg_width / 2),
			bg_height / 2
		)
		
	else:
		# Portrait mode - fill the bottom
		print("Portrait mode detected")
		
		# Calculate the background dimensions directly
		var bg_width = maze_width  # Same width as maze
		var bg_height = viewport_size.y - maze_height
		
		# Calculate scale based on original texture size
		var sprite_width = 1184.0
		var sprite_height = 1400.0
		
		var scale_x = bg_width / sprite_width
		var scale_y = bg_height / sprite_height
		
		sprite.scale = Vector2(scale_x, scale_y)
		
		# Position exactly below the maze
		sprite.position = Vector2(
			bg_width / 2,
			maze_height + (bg_height / 2)
		)
	
	print("Background adjusted - Position:", sprite.position, " Scale:", sprite.scale)
