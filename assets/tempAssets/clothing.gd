class_name Clothing extends Control

@export 

var clothing_name := "Clothing Name"
var file := "clothing1.png"
var cost := 10
var attributes: Array
var colors: Array

var clothing_button
var clothing_text

func _init(c_name: String, c_file: String, c_cost: int) -> void:
	clothing_name = c_name
	file = c_file
	cost = c_cost
	attributes = []
	colors = []

func _ready() -> void:
	clothing_button = get_node("Button")
	clothing_text = get_node("RichTextLabel")

	var texture: Texture = load("res://assets/tempAssets/" + file)

	clothing_button.icon = texture
	clothing_text.text = "[center]" + clothing_name + "\n$" + str(cost) + "[/center]"

func set_attributes(attributes: Array):
	attributes.clear()
	for a in attributes:
		attributes.append(a)

func set_colors(colors: Array):
	colors.clear()
	for c in colors:
		colors.append(c)

func _on_button_pressed() -> void:
	print("clicked on " + clothing_name)
