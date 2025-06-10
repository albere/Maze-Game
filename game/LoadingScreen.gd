extends CanvasLayer

@onready var progress_bar = $LoadingUI/ProgressContainer/ProgressBar
@onready var progress_label = $LoadingUI/ProgressContainer/ProgressLabel
@onready var overlay_texture = $LoadingUI/OverlayTexture
@onready var continue_button = $LoadingUI/ContinueButton

var current_progress = 0.0
var target_progress = 0.0
var loading_complete = false
var can_continue = false

signal loading_finished

func _ready():
	# Set this layer to be on top of everything
	layer = 100
	
	# Initially hide the continue button
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Initialize progress bar
	progress_bar.value = 0
	progress_label.text = "Loading... 0%"
	
	# Start the loading process
	start_loading()

func start_loading():
	# Reset values
	current_progress = 0.0
	target_progress = 0.0
	loading_complete = false
	can_continue = false
	continue_button.visible = false
	
	# Simulate loading steps
	simulate_loading_steps()

func simulate_loading_steps():
	# Simulate various loading steps with delays
	await get_tree().create_timer(0.5).timeout
	set_progress(20.0, "Loading assets...")
	
	await get_tree().create_timer(0.8).timeout
	set_progress(40.0, "Generating maze...")
	
	await get_tree().create_timer(0.6).timeout
	set_progress(60.0, "Loading UI components...")
	
	await get_tree().create_timer(0.7).timeout
	set_progress(80.0, "Initializing game...")
	
	await get_tree().create_timer(0.5).timeout
	set_progress(100.0, "Ready to play!")
	
	# Wait a moment then show continue option
	await get_tree().create_timer(0.5).timeout
	loading_complete = true
	show_continue_option()

func set_progress(value: float, text: String = ""):
	target_progress = clamp(value, 0.0, 100.0)
	if text != "":
		progress_label.text = text

func show_continue_option():
	can_continue = true
	continue_button.visible = true
	progress_label.text = "Press Continue to start the game!"

func _process(delta):
	# Smooth progress bar animation
	if current_progress < target_progress:
		current_progress = move_toward(current_progress, target_progress, 50.0 * delta)
		progress_bar.value = current_progress
		
		# Update percentage display
		if progress_label.text.begins_with("Loading..."):
			progress_label.text = "Loading... " + str(int(current_progress)) + "%"

func _on_continue_pressed():
	if can_continue and loading_complete:
		hide_loading_screen()

func hide_loading_screen():
	# Emit signal to notify that loading is finished
	loading_finished.emit()
	
	# Remove the loading screen
	queue_free()

# Public function to manually complete loading
func complete_loading():
	set_progress(100.0, "Ready to play!")
	loading_complete = true
	show_continue_option()

# Public function to force hide (if needed)
func force_hide():
	hide_loading_screen()
