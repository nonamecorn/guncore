extends Control


var dills0 = [
	"Youre the first one with money this week.",
	"I was corporate agent and now im selling crap to junkies.",
	"Im glad youre not one of those purple fuckers.",
	"What people up there are even cooking? Cant smell this shit anymore...",
	"This shop is booby trapped, so dont try anything stupid.",
]
var dills1 = [
	"You know, with that ammount of bullet holes, that suit wont save you?",
	"I heard corps are here. Thats not good",
	"I hope you wont get shot",
	"If you going up could you please kill more of these fuckers. Which ones? Doesnt matter.",
	"More people are buying guns. Saying that guy in yellow busting their operations. Thanks dude.",
]
var dills2 = [
	"I miss the sun...",
	"I was deployed in Africa once. Heard birds, can you believe this?",
	"You better watch out. Corps deploying heavy units",
	"Hard to believe that you came in one piece. With gun you had at first i thought youre some kind of suicide shooter. I stand corrected",
	"Why are you doing this? Just curious.",
]
var greetings = [
	"Now... Dont make any sudden moves.",
	"Oh its you again. Hii.",
	"Hello, how are you? Hurt again?"
]
var dills = []

func _ready() -> void:
	if GlobalVars.loop <= 2:
		dills = get("dills"+str(GlobalVars.loop))
		$RichTextLabel.text = "Bella:
			" + greetings[GlobalVars.loop]
	else:
		dills = [
			"Nice job! 
			New levels is under connstruction 
			so that\'s it. Thank you for
			playing!"
		]
		$RichTextLabel.text = "Bella:
	" + dills[0]

func _on_talk_button_pressed() -> void:
	dills.shuffle()
	$RichTextLabel.text = "Bella:
" + dills[0]
