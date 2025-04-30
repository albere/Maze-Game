extends CanvasLayer

func _ready():
	print("Background script _ready called")
	
	# Force the layer to be visible on top for debugging
	layer = 10
	
	# Get the sprite
	var sprite = $Indentation_Layer
	if sprite:
		print("Sprite found in background")
		
		# Force visibility
		sprite.visible = true
		
		# Position in the center of the screen for now
		var viewport_size = get_viewport().size
		sprite.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		
		# Use a small fixed scale to ensure it's not too large or small
		sprite.scale = Vector2(0.5, 0.5)
		
		# Make it very visible with a bright color
		sprite.modulate = Color(2.0, 0.0, 0.0)  # Very bright red
		
		print("Sprite positioned at:", sprite.position)
		print("Sprite scale:", sprite.scale)
		print("Sprite modulate:", sprite.modulate)
	else:
		print("ERROR: Indentation_Layer not found")
