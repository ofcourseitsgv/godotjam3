extends Node2D

var dialogue_0 = [
	"Ever since I was little, I've always wanted to design outfits for others.",
	"So, when my dad built this shop for me, I knew it was finally time for me to chase my dreams!",
	"But if I get famous, I won't be able to live a normal life anymore...",
	"I guess I'll just change my appearance on the job!",
]
var dialogue_0_flag = false

var current_line: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/DialogueText.visible_characters = 0
	current_line = 0
	$CanvasLayer/DialogueText.text = dialogue_0[current_line]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if $CanvasLayer/DialogueText.visible_characters < $CanvasLayer/DialogueText.get_total_character_count():
		$CanvasLayer/DialogueText.visible_characters += 1
	
	if Input.is_action_just_pressed("dialogue_key") and not dialogue_0_flag:
		if $CanvasLayer/DialogueText.visible_characters >= $CanvasLayer/DialogueText.get_total_character_count():
			current_line += 1
			if current_line < dialogue_0.size():
				$CanvasLayer/DialogueText.visible_characters = 0
				$CanvasLayer/DialogueText.text = dialogue_0[current_line]
			else:
				print("finished dialogue_0")
				dialogue_0_flag = true
				$CanvasLayer.visible = false
		else:
			$CanvasLayer/DialogueText.visible_characters = $CanvasLayer/DialogueText.get_total_character_count()
	
	