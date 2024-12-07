extends Control


var dills = [
	"You're the first one with money this week",
	"I was corporate agent and now i'm selling crap to junkies.",
	"I'm glad you're not one of those purple fuckers.",
	"What people up there are even cooking? Can't smell this shit anymore...",
	"This shop is booby trapped, so don't try anything stupid.",
]
func _on_talk_button_pressed() -> void:
	dills.shuffle()
	$RichTextLabel.text = 'Bella:
' + dills[0]
