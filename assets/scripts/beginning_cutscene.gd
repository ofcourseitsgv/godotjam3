extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/DialogueText.visible_characters = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $CanvasLayer/DialogueText.visible_characters < $CanvasLayer/DialogueText.get_total_character_count():
		$CanvasLayer/DialogueText.visible_characters += 1
	if Input.is_action_just_pressed("dialogue_skip"):
		if $CanvasLayer/DialogueText.visible_characters >= $CanvasLayer/DialogueText.get_total_character_count():
			$CanvasLayer/DialogueText.visible_characters = 0
		else:
			$CanvasLayer/DialogueText.visible_characters = $CanvasLayer/DialogueText.get_total_character_count()
