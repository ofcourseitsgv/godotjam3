extends Node

var textbox

var clothes = [
	{"name": "Plain Yellow Shirt", "file": "clothing1.png"},
	{"name": "Plain Orange Dress", "file": "clothing2.png"},
	{"name": "Shiny Blue Thingy", "file": "clothing3.png"},
	{"name": "IDK what this is", "file": "clothing4.png"},
	{"name": "Silly Stupid PJs", "file": "clothing5.png"},
]
var clothes_full

var available_clothes = []

var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

	textbox = get_node("BaseCanvas/Text")

	textbox.text = "[center]Let's get it started![/center]"

	clothes_full = clothes.duplicate()
	reset_clothes()

	# Start game

	var new_clothing = clothing_prefab.instantiate()
	new_clothing.clothing_name = "Plain Yellow Shirt"
	new_clothing.file = "clothing1.png"
	new_clothing.cost = 15
	add_child(new_clothing)
	# randomize_clothing(3)


func create_clothing_item(clothing_name, img_path):
	var texture = load("res://assets/tempAssets/" + img_path)
	var button = Button.new()
	button.text = clothing_name
	button.icon = texture
	add_child(button)

func reset_clothes():
	clothes = clothes_full.duplicate()

func randomize_clothing(num_clothes):
	clothes.shuffle()
	for i in num_clothes:
		var random_clothing = clothes.pop_front()
		create_clothing_item(random_clothing["name"], random_clothing["file"])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass
