class_name Client

var name: String
var base_price: int

var attribute_needs = []
var color_needs = []

func _init(name: String, base_price: int):
	pass

func set_attribute_needs(attributes: Array):
	attribute_needs.clear()
	for a in attributes:
		attribute_needs.append(a)

func set_color_needs(colors: Array):
	color_needs.clear()
	for c in colors:
		color_needs.append(c)
