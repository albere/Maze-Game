# VideoOverlay.gd
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
	
	# Make the color rect semi-transparent
	color_rect.color = Color(0, 0, 0, 0.7)
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	
	# Position the video player
	video_player.anchors_preset = Control.PRESET_CENTER
	
	# Style the skip button
	skip_button.text = "Skip"
	skip_button.position = Vector2(10, 10)

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
