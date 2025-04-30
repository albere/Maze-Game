extends CanvasLayer

func _ready():
	# Initial setup
	adjust_ui()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(adjust_ui)

func adjust_ui():
	var viewport_size = get_viewport().size
	
	# Apply uniform scaling to the entire UI
	var scale_factor = 0.25  # Adjust as needed
	
	# Get the entire UI to scale together
	# Instead of positioning individual elements, we'll position the entire UI
	
	if viewport_size.x > viewport_size.y:
		# Landscape orientation
		# Position UI to the right of the maze
		offset = Vector2(viewport_size.x * 0.55 - 200, viewport_size.y * 0.5)
	else:
		# Portrait orientation
		# Position UI below the maze
		offset = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.75)
	
	# Apply scaling to the ENTIRE UI as one unit
	scale = Vector2(scale_factor, scale_factor)
	
	# IMPORTANT: Don't set any positions or scales on child nodes
	# Let them maintain their original relative positions
