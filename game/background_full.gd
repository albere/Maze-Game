extends CanvasLayer

# Set this to whatever color you want
var background_color = Color(0.07, 0.22, 0.49)  # Dark blue color

func _ready():
	# Set layer to be behind everything else
	layer = -10
	
	# Create a color rectangle
	var bg_rect = ColorRect.new()
	bg_rect.color = Color("#888585")
	add_child(bg_rect)
	
	# Set size to cover the entire viewport
	resize_background()
	
	# Connect to resize signal to keep it full-screen
	get_viewport().size_changed.connect(resize_background)

func resize_background():
	var bg_rect = get_child(0)
	if bg_rect and bg_rect is ColorRect:
		# Make it slightly larger than the viewport to account for any rounding
		var viewport_size = Vector2(get_viewport().size)  # Convert to Vector2
		bg_rect.size = viewport_size + Vector2(10, 10)
		bg_rect.position = Vector2(-5, -5)
		print("Background rect resized to cover:", viewport_size)
