extends Node

@onready var stream : AudioStreamPlaybackInteractive = $AudioStreamPlayer.get_stream_playback()

#func _ready() -> void:
	#$AudioStreamPlayer.finished.connect(loop)

func switch_track(trackname):
	stream.switch_to_clip_by_name(trackname)
#
#func loop():
	#$AudioStreamPlayer.play()
