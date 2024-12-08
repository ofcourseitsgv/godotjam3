class_name Clothing extends Control

@export 

var clothing_name := "Clothing Name"
var file := "clothing1.png"
var cost := 10
var attributes: Array
var colors: Array
var is_selected: bool

var clothing_button
var clothing_text

#func _init(c_name: String, c_file: String, c_cost: int) -> void:
	#clothing_name = c_name
	#file = c_file
	#cost = c_cost
	#attributes = []
	#colors = []

func _ready() -> void:
	clothing_button = get_node("Button")
	clothing_text = get_node("RichTextLabel")

	var texture: Texture = load("res://assets/tempAssets/" + file)

	clothing_button.icon = texture
	clothing_text.text = "[center]" + clothing_name + "\n$" + str(cost) + "[/center]"

func setup(c_name: String, c_file: String, c_cost: int, c_attributes: Array, c_colors: Array) -> void:
	clothing_name = c_name
	file = c_file
	cost = c_cost
	attributes = []
	colors = []
	_set_attributes(c_attributes)
	_set_colors(c_colors)
	is_selected = false

func _set_attributes(c_attributes: Array):
	attributes.clear()
	for a in c_attributes:
		attributes.append(a)

func _set_colors(c_colors: Array):
	colors.clear()
	for c in c_colors:
		colors.append(c)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		#print("Selected ", clothing_name, ", attributes: ", attributes, ", colors: ", colors)
		is_selected = true
	else:
		print("Deselected ", clothing_name)
		is_selected = false

func has_attribute(att: Enums.Attributes) -> bool:
	return att in attributes

func has_color(col: Enums.Colors) -> bool:
	return col in colors
