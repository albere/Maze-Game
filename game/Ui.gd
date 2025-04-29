extends CanvasLayer

func _ready():
	# Initial setup
	adjust_ui()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(adjust_ui)

func adjust_ui():
	var viewport_size = get_viewport().size
	
	# Apply uniform scaling to entire UI
	var scale_factor = 0.25
	scale = Vector2(scale_factor, scale_factor)
	
	# Center UI based on orientation
	if viewport_size.x > viewport_size.y:
		# Landscape orientation
		offset = Vector2(viewport_size.x * 0.55, viewport_size.y * 0.5)
	else:
		# Portrait orientation
		offset = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.55)
		print("Portrait")
