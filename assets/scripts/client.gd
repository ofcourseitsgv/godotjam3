class_name Client

var name: String
var base_price: int

var attribute_needs = []
var color_needs = []

enum SatisfactionValue {
	SATISFIED,
	OKAY,
	DISSATISFIED,
}

var satisfied_val: SatisfactionValue

func _init(c_name: String, c_base_price: int, attributes: Array, colors: Array):
	name = c_name
	base_price = c_base_price
	_set_attribute_needs(attributes)
	_set_color_needs(colors)
	
	satisfied_val = SatisfactionValue.OKAY

func _set_attribute_needs(attributes: Array):
	attribute_needs.clear()
	for a: Enums.Attributes in attributes:
		attribute_needs.append(a)

func _set_color_needs(colors: Array):
	color_needs.clear()
	for c: Enums.Colors in colors:
		color_needs.append(c)

func satisfied():
	satisfied_val = SatisfactionValue.SATISFIED

func okay():
	satisfied_val = SatisfactionValue.OKAY

func dissatisfied():
	satisfied_val = SatisfactionValue.DISSATISFIED
