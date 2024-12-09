extends Node2D

var logo_start_pos
var amplitude := 50.0
var frequency := 4.5
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

# FIXME: figure out moving BG based on mouse position
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#print("mouse:", event.position)
		#$Camera2D.position = -event.position
		#print("camera:", $Camera2D.position)
		


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/options.tscn")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/beginning_cutscene.tscn")
