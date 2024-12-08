extends Node

# Node references
var textbox
var item_canvas
var item_grid

var clothes = [
	{"name": "Plain Yellow Shirt", "file": "clothing1.png", "cost": 15},
	{"name": "Plain Orange Dress", "file": "clothing2.png", "cost": 30},
	{"name": "Shiny Blue Thingy", "file": "clothing3.png", "cost": 100},
	{"name": "IDK what this is", "file": "clothing4.png", "cost": 69},
	{"name": "Silly Stupid PJs", "file": "clothing5.png", "cost": 22},
]
var clothes_full

var available_clothes = []

var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")
var player = Player.new("")

# Cutscene Flags
var first_play_flag = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

	textbox = get_node("BaseCanvas/Text")
	item_canvas = get_node("ItemCanvas")
	item_grid = get_node("ItemCanvas/HBoxContainer")

	textbox.text = "[center]Let's get it started![/center]"

	clothes_full = clothes.duplicate()
	#reset_clothes()

	var player = Player.new("Name")

	# Start game
	get_node("NameCanvas").visible = false
	$ItemCanvas.visible = false
	#randomize_clothing(3)
	#display_available_clothes()


func create_clothing_item(clothing_name, img_file, cost):
	var clothing_instance: Clothing = clothing_prefab.instantiate()
	clothing_instance.clothing_name = clothing_name
	clothing_instance.file = img_file
	clothing_instance.cost = cost
	# add_child(clothing_instance)
	available_clothes.append(clothing_instance)

func reset_clothes():
	clothes = clothes_full.duplicate()

func randomize_clothing(num_clothes):
	clothes.shuffle()
	for i in num_clothes:
		var random_clothing = clothes.pop_front()
		create_clothing_item(random_clothing["name"], random_clothing["file"], random_clothing["cost"])

func display_available_clothes():
	for n in item_grid.get_children():
		item_grid.remove_child(n)
		n.queue_free()

	for c in available_clothes:
		item_grid.add_child(c)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not first_play_flag):
		first_play()
		first_play_flag = true
	
	$HUD/WalletText.text = "$" + str(player.wallet)

func first_play():
	await _wait(1.5)
	_set_text("Wait... What's your name again?")
	await _wait(2.0)
	var name_canvas = get_node("NameCanvas")
	name_canvas.visible = true
	await $NameCanvas/Button.pressed
	
	if ($NameCanvas/TextEdit.text == ""):
		_set_text("Oh, you're nameless? Well... I'll give you a name! Hey Banksy!")
		player.name = "Banksy"
	else:
		player.name = $NameCanvas/TextEdit.text
		_set_text("Hi " + player.name + "! Let's tutorialize. *dabs*")
	name_canvas.visible = false
	
	await _wait(2.0)
	_set_text("")
	
	reset_clothes()
	randomize_clothing(3)
	display_available_clothes()
	$ItemCanvas.visible = true
	_set_text("Random clothes. Each have stuff. Lol!")

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _set_text(text: String):
	textbox.text = "[center]" + text + "[/center]"
