# background.gd
extends CanvasLayer

func _ready():
	# Initial setup
	adjust_background()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(adjust_background)

func adjust_background():
	var sprite = $Indentation_Layer
	if not sprite:
		print("ERROR: Indentation_Layer not found")
		return
	
	var viewport_size = get_viewport().size
	var maze_width = 675  # Based on your maze dimensions
	
	# Position the background to the right of the maze in landscape mode
	# or below the maze in portrait mode
	if viewport_size.x > viewport_size.y:
		# Landscape mode
		sprite.position = Vector2(maze_width + (viewport_size.x - maze_width) / 2, viewport_size.y / 2)
		
		# Scale to fill the remaining width while maintaining aspect ratio
		var available_width = viewport_size.x - maze_width
		var scale_factor = available_width / sprite.texture.get_width()
		sprite.scale = Vector2(scale_factor, scale_factor)
	else:
		# Portrait mode
		sprite.position = Vector2(viewport_size.x / 2, maze_width + (viewport_size.y - maze_width) / 2)
		
		# Scale to fill the remaining height while maintaining aspect ratio
		var available_height = viewport_size.y - maze_width
		var scale_factor = available_height / sprite.texture.get_height()
		sprite.scale = Vector2(scale_factor, scale_factor)
	
	print("Background adjusted - Position:", sprite.position, " Scale:", sprite.scale)
