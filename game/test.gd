extends Control

# Define signals for maze movement
signal move_up
signal move_down
signal move_left
signal move_right

func _ready():
	# Get parent references
	var parent = get_parent()

	# The buttons should be direct children of this node
	# Make sure connections exist and are properly set up
	var up_btn = get_node_or_null("Up")
	var down_btn = get_node_or_null("Down")
	var left_btn = get_node_or_null("Left")
	var right_btn = get_node_or_null("Right")

	# Debug output
	print("DPad found buttons - Up:", up_btn != null,
		  "Down:", down_btn != null,
		  "Left:", left_btn != null,
		  "Right:", right_btn != null)

	# Connect signals if they're not already connected
	if up_btn and !up_btn.is_connected("pressed", _on_up_pressed):
		up_btn.pressed.connect(_on_up_pressed)

	if down_btn and !down_btn.is_connected("pressed", _on_down_pressed):
		down_btn.pressed.connect(_on_down_pressed)

	if left_btn and !left_btn.is_connected("pressed", _on_left_pressed):
		left_btn.pressed.connect(_on_left_pressed)

	if right_btn and !right_btn.is_connected("pressed", _on_right_pressed):
		right_btn.pressed.connect(_on_right_pressed)

func _on_up_pressed() -> void:
	print("Up pressed - emitting move_up signal")
	emit_signal("move_up")

func _on_down_pressed() -> void:
	print("Down pressed - emitting move_down signal")
	emit_signal("move_down")

func _on_left_pressed() -> void:
	print("Left pressed - emitting move_left signal")
	emit_signal("move_left")  # Fixed - was emitting "move_right"

func _on_right_pressed() -> void:
	print("Right pressed - emitting move_right signal")
	emit_signal("move_right")
