extends CanvasLayer

func _ready():
	
	layer = 1
	
	print("Screen border initialized with layer:", layer)
	
	# Initialize the border
	adjust_border()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(adjust_border)

func adjust_border():
	# Get the sprite node
	var sprite = $Sprite2D
	if not sprite:
		print("ERROR: Sprite2D not found in screen border!")
		return
	
	# Get the current viewport size
	var viewport_size = get_viewport().size
	print("Viewport size:", viewport_size)
	
	# Handle positioning based on the game layout
	# We want to center the border around the maze area
	# Assuming the maze is positioned at the left side
	var maze_width = 675  # Based on project settings
	var maze_height = 675
	
	# Center the border on the maze area
	sprite.position = Vector2(maze_width/2, maze_height/2)
	print("Border sprite positioned at:", sprite.position)
	
	# We don't need to adjust scale here as it's handled in Main.gd
	# The main script will scale the border based on the maze size
