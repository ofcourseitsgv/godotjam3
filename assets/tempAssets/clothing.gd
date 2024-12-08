class_name Clothing extends Control

const my_scene: PackedScene = preload("res://assets/tempAssets/clothing.tscn")

var clothing_name := "Clothing Name"
var file := "clothing1.png"
var cost := 10

var clothing_button
var clothing_text

func _ready() -> void:
	clothing_button = get_node("Button")
	clothing_text = get_node("RichTextLabel")

	var texture: Texture = load("res://assets/tempAssets/" + file)

	clothing_button.icon = texture
	clothing_text.text = "[center]" + clothing_name + "[/center]"


func _on_button_pressed() -> void:
	print("clicked on " + clothing_name)
