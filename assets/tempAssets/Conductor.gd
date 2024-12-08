extends Node

# Node references
var textbox
var item_canvas
var item_grid

#TODO: add colors and attributes to each clothing
var clothes = [
	{"name": "Plain Yellow Shirt", "file": "clothing1.png", "cost": 15, "attributes": [Enums.Attributes.SIMPLE], "colors": [Enums.Colors.YELLOW]},
	{"name": "Plain Orange Dress", "file": "clothing2.png", "cost": 30, "attributes": [Enums.Attributes.CUTE, Enums.Attributes.SIMPLE], "colors": [Enums.Colors.ORANGE]},
	{"name": "Shiny Blue Thingy", "file": "clothing3.png", "cost": 100, "attributes": [Enums.Attributes.ELEGANT], "colors": [Enums.Colors.BLUE]},
	{"name": "IDK what this is", "file": "clothing4.png", "cost": 69, "attributes": [Enums.Attributes.SILLY], "colors": [Enums.Colors.RED, Enums.Colors.BLUE]},
	{"name": "Silly Stupid PJs", "file": "clothing5.png", "cost": 22, "attributes": [Enums.Attributes.SILLY], "colors": [Enums.Colors.BLUE]},
]
var clothes_full

var available_clothes = []
var selected_clothes = []
var remaining_attributes = []
var remaining_colors = []

var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")
var player = Player.new("")

var current_cost: int
var current_client: Client

# Cutscene Flags
var first_play_flag = false
var is_player_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

	textbox = get_node("BaseCanvas/Text")
	item_canvas = get_node("ItemCanvas")
	item_grid = get_node("ItemCanvas/HBoxContainer")

	textbox.text = "[center]Let's get it started![/center]"

	clothes_full = clothes.duplicate()

	var player = Player.new("Name")

	# Start game
	get_node("NameCanvas").visible = false
	$ItemCanvas.visible = false
	$HUD.visible = false


func create_clothing_item(clothing_name: String, img_file: String, cost: int, attributes: Array, colors: Array):
	var clothing_instance: Clothing = clothing_prefab.instantiate()
	clothing_instance.setup(clothing_name, img_file, cost, attributes, colors)
	available_clothes.append(clothing_instance)

func reset_clothes():
	clothes = clothes_full.duplicate()

func randomize_clothing(num_clothes):
	clothes.shuffle()
	for i in num_clothes:
		var random_clothing = clothes.pop_front()
		create_clothing_item(random_clothing["name"], random_clothing["file"], random_clothing["cost"], random_clothing["attributes"], random_clothing["colors"])

func display_available_clothes():
	for n in item_grid.get_children():
		item_grid.remove_child(n)
		n.queue_free()

	for c in available_clothes:
		item_grid.add_child(c)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not first_play_flag:
		first_play()
		first_play_flag = true
	
	$HUD/WalletText.text = "$" + str(player.wallet)
	
	calculate_current_cost()
	$HUD/WalletText.text += "\nCurrent Cost: $" + str(current_cost)
	
	if is_player_turn:
		play_game()
		is_player_turn = false

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
	
	setup_game()
	$ItemCanvas.visible = true
	_set_text("Random clothes. Each have stuff. Lol!")

func setup_game():
	reset_clothes()
	randomize_clothing(3)
	display_available_clothes()
	
	current_client = Client.new("Bagel", 30, [Enums.Attributes.SILLY, Enums.Attributes.CUTE], [Enums.Colors.BLUE])
	remaining_attributes.clear()
	remaining_attributes = current_client.attribute_needs.duplicate()
	remaining_colors.clear()
	remaining_colors = current_client.color_needs.duplicate()
	
	is_player_turn = true
	current_cost = 0
	$HUD.visible = true

func play_game():
	await $HUD/ConfirmButton.pressed
	
	if current_cost > player.wallet:
		_set_text("bruh u dont have enough money L!!!! TRY AGAIN!")
		play_game()
		return
	
	_set_text("ok u have enough money. cha-ching!")
	player.wallet -= current_cost
	$ItemCanvas.visible = false
	for c in available_clothes:
		if c.is_selected:
			selected_clothes.append(c)
	
	for att: Enums.Attributes in current_client.attribute_needs:
		for c: Clothing in selected_clothes:
			if c.has_attribute(att) and att in remaining_attributes:
				remaining_attributes.remove_at(remaining_attributes.find(att))
				#print("found attribute!")
				break
	
	for col: Enums.Colors in current_client.color_needs:
		for c: Clothing in selected_clothes:
			if c.has_color(col) and col in remaining_colors:
				remaining_colors.remove_at(remaining_colors.find(col))
				#print("found color!")
				break
	
	var is_satisfied = remaining_attributes.is_empty() and remaining_colors.is_empty()
	await _wait(2.0)
	if (is_satisfied):
		_set_text(current_client.name + ": \"omg i love these ty!\"")
	else:
		_set_text(current_client.name + ": \"GRRRR u did not satisfy me. perish\"")
	

func calculate_current_cost():
	current_cost = 0
	for c in available_clothes:
		if c.is_selected:
			current_cost += c.cost

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _set_text(text: String):
	textbox.text = "[center]" + text + "[/center]"
