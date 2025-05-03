extends CanvasLayer

signal overlay_closed

@onready var video_player = $Control/VideoStreamPlayer
@onready var color_rect = $Control/ColorRect
@onready var skip_button = $Control/Button

func _ready():
	skip_button.pressed.connect(_on_skip_pressed)
	video_player.finished.connect(_on_video_finished)
	
	# Make the overlay cover the full screen
	var control = $Control
	control.anchors_preset = Control.PRESET_FULL_RECT
	control.anchor_left = 0
	control.anchor_top = 0
	control.anchor_right = 1
	control.anchor_bottom = 1
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0
	
	# Make the color rect semi-transparent and full screen
	color_rect.color = Color(0, 0, 0, 0.7)
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	color_rect.anchor_left = 0
	color_rect.anchor_top = 0
	color_rect.anchor_right = 1
	color_rect.anchor_bottom = 1
	color_rect.offset_left = 0
	color_rect.offset_top = 0
	color_rect.offset_right = 0
	color_rect.offset_bottom = 0
	
	# Constrain the video player to viewport size
	video_player.anchors_preset = Control.PRESET_FULL_RECT
	video_player.anchor_left = 0
	video_player.anchor_top = 0
	video_player.anchor_right = 1
	video_player.anchor_bottom = 1
	video_player.offset_left = 0
	video_player.offset_top = 0
	video_player.offset_right = 0
	video_player.offset_bottom = 0
	
	# Ensure video stretches to fit while maintaining aspect ratio
	video_player.expand = true
	
	# Style the skip button and position it at the top-right
	skip_button.text = "Skip"
	skip_button.position = Vector2(DisplayServer.window_get_size().x - 80, 10)
	skip_button.size = Vector2(70, 30)
	skip_button.custom_minimum_size = Vector2(70, 30)

func show_video(video_path):
	var video_stream = VideoStreamTheora.new()
	video_stream.file = video_path
	video_player.stream = video_stream
	video_player.play()
	show()

func _on_skip_pressed():
	video_player.stop()
	hide()
	overlay_closed.emit()

func _on_video_finished():
	hide()
	overlay_closed.emit()
