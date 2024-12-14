extends Node
func _ready() -> void:
	$AudioStreamPlayer.finished.connect(loop)

func play_track(loadname):
	$AudioStreamPlayer.stream = load(loadname)
	$AudioStreamPlayer.play()

func loop():
	$AudioStreamPlayer.play()
