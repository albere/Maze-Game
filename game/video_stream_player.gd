extends VideoStreamPlayer

func _ready():
	# Force the video to maintain landscape orientation
	# by setting a fixed size ratio
	var video_size = Vector2(16, 9)  # Use your video's actual ratio
	set_custom_minimum_size(video_size * 20)  # Scale as needed
	expand = true
