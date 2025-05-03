extends Control

# Define signals for maze movement
signal move_up
signal move_down
signal move_left
signal move_right

var up_held = false
var down_held = false
var left_held = false
var right_held = false

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
		
	set_process(true)

	# Connect signals if they're not already connected
	if up_btn:
		up_btn.pressed.connect(_on_up_pressed)
		up_btn.released.connect(_on_up_released)

	if down_btn:
		down_btn.pressed.connect(_on_down_pressed)
		down_btn.released.connect(_on_down_released)

	if left_btn:
		left_btn.pressed.connect(_on_left_pressed)
		left_btn.released.connect(_on_left_released)

	if right_btn:
		right_btn.pressed.connect(_on_right_pressed)
		right_btn.released.connect(_on_right_released)

# Button handlers
func _on_up_pressed():
	print("Up pressed - starting continuous movement")
	up_held = true
	emit_signal("move_up")  # Immediate first move

func _on_up_released():
	print("Up released - stopping movement")
	up_held = false

func _on_down_pressed():
	print("Down pressed - starting continuous movement")
	down_held = true
	emit_signal("move_down")

func _on_down_released():
	print("Down released - stopping movement")
	down_held = false

func _on_left_pressed():
	print("Left pressed - starting continuous movement")
	left_held = true
	emit_signal("move_left")

func _on_left_released():
	print("Left released - stopping movement")
	left_held = false

func _on_right_pressed():
	print("Right pressed - starting continuous movement")
	right_held = true
	emit_signal("move_right")

func _on_right_released():
	print("Right released - stopping movement")
	right_held = false

func _process(delta):
	if up_held:
		emit_signal("move_up")
	if down_held:
		emit_signal("move_down")
	if left_held:
		emit_signal("move_left")
	if right_held:
		emit_signal("move_right")
