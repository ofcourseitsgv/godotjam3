class_name Clothing extends Control

@export 

var clothing_name := "Clothing Name"
var file := "clothing1.png"
var cost := 10
var attributes: Array
var colors: Array
var type: Enums.Types
var is_selected: bool

var clothing_button
var clothing_text

func _ready() -> void:
	init_child_references()

	var texture: Texture = load("res://assets/art/" + file)
	if (not texture):
		texture = load("")

	clothing_button.icon = texture
	clothing_text.text = "[center][color=3f1f16]" + clothing_name + "[/color][/center]"

func init_child_references():
	clothing_button = get_node("Button")
	clothing_text = get_node("RichTextLabel")
	
func _process(delta: float) -> void:
	pass

func setup(c_name: String, c_file: String, c_cost: int, c_attributes: Array, c_colors: Array, c_type: Enums.Types) -> void:
	clothing_name = c_name
	file = c_file
	cost = c_cost
	attributes = []
	colors = []
	type = c_type
	_set_attributes(c_attributes)
	_set_colors(c_colors)
	_update_tooltip()
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

func _update_tooltip():
	var tooltip := ""
	tooltip += "Type: " + Enums.type_to_string(type)
	tooltip += "\nAttributes: "
	for a in attributes:
		tooltip += Enums.attribute_to_string(a) + ", "
	tooltip = tooltip.left(-2)
	tooltip += "\nColors: "
	for c in colors:
		tooltip += Enums.color_to_string(c) + ", "
	tooltip = tooltip.left(-2)
	clothing_button.tooltip_text = tooltip
