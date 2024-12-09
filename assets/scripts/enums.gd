extends Node

enum Attributes {
	CUTE,
	SEXY,
	SIMPLE,
	ELEGANT,
	SILLY,
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
}

func attribute_to_string(att: Attributes):
	var output := ""
	match att:
		Attributes.CUTE:
			output = "cute"
		Attributes.SEXY:
			output = "sexy"
		Attributes.SIMPLE:
			output = "simple"
		Attributes.ELEGANT:
			output = "elegant"
		Attributes.SILLY:
			output = "silly"
	
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
	
	return output
