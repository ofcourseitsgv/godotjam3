class_name Client

var name: String
var base_price: int

var attribute_needs = []
var color_needs = []

func _init(c_name: String, c_base_price: int, attributes: Array, colors: Array):
	name = c_name
	base_price = c_base_price
	_set_attribute_needs(attributes)
	_set_color_needs(colors)

func _set_attribute_needs(attributes: Array):
	attribute_needs.clear()
	for a in attributes:
		attribute_needs.append(a)

func _set_color_needs(colors: Array):
	color_needs.clear()
	for c in colors:
		color_needs.append(c)
