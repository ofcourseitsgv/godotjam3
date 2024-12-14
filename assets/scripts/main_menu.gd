extends Node2D

var logo_start_pos
var amplitude := 16.0
var frequency := 1.75
var time := 0.0

var is_transitioning = false

var showing_tutorial := false

const beginning_cutscene = preload("res://assets/scenes/beginning_cutscene.tscn")
const tutorial = preload("res://assets/scenes/tutorial.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logo_start_pos = $Logo.position
	$BGM.volume_db = linear_to_db(GlobalOptions.music_volume)
	$BGM.play()
	$CreditsScreen.visible = false
	$CrossfadeCanvas.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta * frequency
	$Logo.position = logo_start_pos + Vector2(0, sin(time) * amplitude)
	
	if not is_transitioning:
		$BGM.volume_db = linear_to_db(GlobalOptions.music_volume)
		$HoverSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)
		$ClickSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)
	
	if not $BGM.playing:
		$BGM.play()
	
	if Input.is_action_just_pressed("toggle_tutorial"):
		if not showing_tutorial:
			var t = tutorial.instantiate()
			add_child(t)
			showing_tutorial = true
		else:
			showing_tutorial = false

func _on_options_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://assets/scenes/options.tscn")
	var options_screen = preload("res://assets/scenes/options.tscn").instantiate()
	add_child(options_screen)
	_click_sfx()


func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://assets/scenes/beginning_cutscene.tscn")
	_click_sfx()
	Player._reset()
	Shop._reset()
	transition()

func _hover_sfx():
	$HoverSfx.play()

func _click_sfx():
	$ClickSfx.play()

func transition():
	$CrossfadeCanvas.visible = true
	is_transitioning = true
	var tween = get_tree().create_tween()
	var music_tween = get_tree().create_tween()
	tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,1), 1)
	music_tween.tween_property($BGM, "volume_db", linear_to_db(0.01), 1)
	
	tween.play()
	music_tween.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(beginning_cutscene)


func _on_credits_button_mouse_entered() -> void:
	_hover_sfx()


func _on_options_button_mouse_entered() -> void:
	_hover_sfx()


func _on_start_button_mouse_entered() -> void:
	_hover_sfx()


func _on_credits_button_pressed() -> void:
	$CreditsScreen.visible = true


func _on_return_from_credits_button_pressed() -> void:
	$CreditsScreen.visible = false
