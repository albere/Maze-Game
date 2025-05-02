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

	# Try with a fixed width that looks right to you
	# Adjust this value based on visual inspection
	var bg_width = 850  # Try a smaller value than 925
	var bg_height = viewport_size.y

	print("Using fixed background width:", bg_width)

	# Get original texture size
	var texture_size = sprite.texture.get_size()

	# Calculate scale factors
	var scale_x = bg_width / texture_size.x
	var scale_y = bg_height / texture_size.y

	# Apply scale
	sprite.scale = Vector2(scale_x, scale_y)

	# Position sprite
	# Assume the maze width is (viewport width - background width)
	var maze_width = viewport_size.x - bg_width
	sprite.position = Vector2(
		maze_width + (bg_width / 2),
		bg_height / 2
	)

	print("Background positioned at:", sprite.position)
	print("Background scaled to:", sprite.scale)
	print("Final background sizetest:", Vector2(texture_size.x * scale_x, texture_size.y * scale_y))
