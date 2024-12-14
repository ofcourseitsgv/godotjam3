extends Node

enum Attributes {
	SIMPLE,
	SILLY,
	CUTE,
	FORMAL,
	COMFORTABLE,
	SUMMER,
	COSPLAY,
	OUTDOORSY,
	UNIFORM,
}

enum Colors {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	PURPLE,
	WHITE,
	BLACK,
	BROWN,
	PINK,
}

enum Types {
	TOP,
	BOTTOM,
	ONE_PIECE,
	FOOTWEAR,
	HEADWEAR,
	ACCESSORY,
}

func get_attributes():
	var arr = []
	for i in Attributes.size():
		arr.append(i)
	return arr

func get_colors():
	var arr = []
	for i in Colors.size():
		arr.append(i)
	return arr

func attribute_to_string(att: Attributes):
	var output := ""
	match att:
		Attributes.SIMPLE:
			output = "simple"
		Attributes.SILLY:
			output = "silly"
		Attributes.CUTE:
			output = "cute"
		Attributes.FORMAL:
			output = "formal"
		Attributes.COMFORTABLE:
			output = "comfortable"
		Attributes.SUMMER:
			output = "summer"
		Attributes.COSPLAY:
			output = "cosplay"
		Attributes.OUTDOORSY:
			output = "outdoorsy"
		Attributes.UNIFORM:
			output = "uniform"
	
	return output

func color_to_string(col: Colors):
	var output := ""
	match col:
		Colors.RED:
			output = "red"
		Colors.ORANGE:
			output = "orange"
		Colors.YELLOW:
			output = "yellow"
		Colors.GREEN:
			output = "green"
		Colors.BLUE:
			output = "blue"
		Colors.PURPLE:
			output = "purple"
		Colors.WHITE:
			output = "white"
		Colors.BLACK:
			output = "black"
		Colors.BROWN:
			output = "brown"
		Colors.PINK:
			output = "pink"
	
	return output

func type_to_string(typ: Types):
	var output := ""
	match typ:
		Types.TOP:
			output = "top"
		Types.BOTTOM:
			output = "bottom"
		Types.ONE_PIECE:
			output = "one-piece"
		Types.FOOTWEAR:
			output = "footwear"
		Types.HEADWEAR:
			output = "headwear"
		Types.ACCESSORY:
			output = "accessory"
	
	return output
