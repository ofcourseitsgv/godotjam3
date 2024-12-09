extends Node2D

var logo_start_pos
var amplitude := 25.0
var frequency := 2.5
var time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logo_start_pos = $Logo.position
	$BGM.volume_db = linear_to_db(GlobalOptions.music_volume)
	$BGM.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta * frequency
	$Logo.position = logo_start_pos + Vector2(0, sin(time) * amplitude)
	
	$BGM.volume_db = linear_to_db(GlobalOptions.music_volume)

func _on_options_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://assets/scenes/options.tscn")
	var options_screen = preload("res://assets/scenes/options.tscn").instantiate()
	add_child(options_screen)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/beginning_cutscene.tscn")
