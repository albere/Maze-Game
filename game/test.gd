extends Node2D

# Define signals for maze movement
signal move_up
signal move_down
signal move_left
signal move_right

func _ready():
	# Ensure connections exist
	if !$Up.is_connected("pressed", _on_up_pressed):
		$Up.pressed.connect(_on_up_pressed)
	if !$Down.is_connected("pressed", _on_down_pressed):
		$Down.pressed.connect(_on_down_pressed)
	if !$Left.is_connected("pressed", _on_left_pressed):
		$Left.pressed.connect(_on_left_pressed)
	if !$Right.is_connected("pressed", _on_right_pressed):
		$Right.pressed.connect(_on_right_pressed)

func _on_up_pressed() -> void:
	print("Up pressed")
	emit_signal("move_up")

func _on_down_pressed() -> void:
	print("Down pressed")
	emit_signal("move_down")

func _on_left_pressed() -> void:
	print("Left pressed")
	emit_signal("move_left")

func _on_right_pressed() -> void:
	print("Right pressed")
	emit_signal("move_right")
