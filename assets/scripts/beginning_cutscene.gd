extends Node2D

var begin_dialogue = false

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
	$CanvasLayer/SpeakerText.text = Player.player_name
	$CanvasLayer/DialogueText.visible_characters = 0
	current_line = 0
	$CanvasLayer/DialogueText.text = dialogue_0[current_line]
	$Ambience.play()
	transition(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Ambience.volume_db = linear_to_db(GlobalOptions.music_volume)
	
	if not begin_dialogue:
		return
	
	if $CanvasLayer/DialogueText.visible_characters < $CanvasLayer/DialogueText.get_total_character_count():
		match GlobalOptions.text_speed:
			GlobalOptions.TextSpeeds.FAST:
				$CanvasLayer/DialogueText.visible_characters = min($CanvasLayer/DialogueText.get_total_character_count(), $CanvasLayer/DialogueText.visible_characters + 2)
			GlobalOptions.TextSpeeds.FASTER:
				$CanvasLayer/DialogueText.visible_characters = min($CanvasLayer/DialogueText.get_total_character_count(), $CanvasLayer/DialogueText.visible_characters + 3)
			GlobalOptions.TextSpeeds.INSTANT:
				$CanvasLayer/DialogueText.visible_characters = $CanvasLayer/DialogueText.get_total_character_count()
			_:
				$CanvasLayer/DialogueText.visible_characters += 1
	
	if Input.is_action_just_pressed("dialogue_key") and not dialogue_0_flag:
		progress_dialogue()
	
func progress_dialogue():
	if $CanvasLayer/DialogueText.visible_characters >= $CanvasLayer/DialogueText.get_total_character_count():
		current_line += 1
		if current_line < dialogue_0.size():
			$CanvasLayer/DialogueText.visible_characters = 0
			$CanvasLayer/DialogueText.text = dialogue_0[current_line]
		else:
			print("finished dialogue_0")
			dialogue_0_flag = true
			$CanvasLayer.visible = false
			#get_tree().change_scene_to_file("res://assets/scenes/play.tscn")
			transition(true)
	else:
		$CanvasLayer/DialogueText.visible_characters = $CanvasLayer/DialogueText.get_total_character_count()
	

func transition(to_black: bool):
	$CrossfadeCanvas.visible = true
	
	if to_black:
		var tween = get_tree().create_tween()
		tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,1), 1)
		tween.play()
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://assets/scenes/play.tscn")
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,0), 1)
	
	tween.play()
	await get_tree().create_timer(1).timeout
	$CrossfadeCanvas.visible = false
	begin_dialogue = true
