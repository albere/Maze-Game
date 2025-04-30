extends CanvasLayer

# Define signals
signal move_up
signal move_down
signal move_left
signal move_right

func _ready():
	# Connect button presses to signal emissions
	$Up.pressed.connect(func(): move_up.emit())
	$Down.pressed.connect(func(): move_down.emit()) 
	$Left.pressed.connect(func(): move_left.emit())
	$Right.pressed.connect(func(): move_right.emit())
	
