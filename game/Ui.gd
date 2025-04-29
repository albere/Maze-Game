# Create a new script ui.gd for your UI scene
extends CanvasLayer

func _ready():
	# Scale the UI to match the game viewport
	scale_ui()
	
	# Listen for window resize events to adjust UI scale when needed
	get_tree().get_root().size_changed.connect(scale_ui)

func scale_ui():
	# Get viewport size
	var viewport_size = get_viewport().size
	
	# Calculate scale factor (adjust these values as needed)
	var scale_factor = 0.3
	
	# Apply scale to children
	$Dpad.scale = Vector2(scale_factor, scale_factor)
	$Buttons.scale = Vector2(scale_factor, scale_factor)
	$Background.scale = Vector2(scale_factor, scale_factor)
	$Screen.scale = Vector2(scale_factor, scale_factor)
	
	# Position UI elements relative to viewport
	if viewport_size.x > viewport_size.y:
		# Landscape mode
		$Dpad.offset = Vector2(viewport_size.x * 0.6, viewport_size.y * 0.5)
		$Background.position = Vector2(viewport_size.x * 0.7, viewport_size.y * 0.5)
	else:
		# Portrait mode
		$Dpad.offset = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.7)
		$Background.position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.8)
