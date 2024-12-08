class_name Clothing extends Node2D

var clothing_name := "Clothing Name"
var file := "clothing1.png"
var cost := 10

var _clothing_button
var _clothing_text


func _ready() -> void:
	_clothing_button = get_node("Button")
	_clothing_text = get_node("RichTextLabel")

	var texture: Texture = load("res://assets/tempAssets/" + file)

	_clothing_button.icon = texture
	_clothing_text.text = "[center]" + clothing_name + "[/center]"
