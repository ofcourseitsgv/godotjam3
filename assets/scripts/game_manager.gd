extends Node2D

var current_day := 0
var my_items: Node
var client_items: Node

var my_items_bag: Array
var client_items_array: Array

var available_rerolls: int

var current_client: Client

var pack_grid_prefab = preload("res://assets/scenes/pack_grid.tscn")
var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")

const random_names = ["Jerry", "Sally", "Salt", "Gyle", "Slugon"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_items = $RequestCanvas/TabletBg/MyItemsBg/ScrollContainer/MasterGrid
	client_items = $RequestCanvas/TabletBg/ClientItemsBg/ScrollContainer/HBoxContainer
	print(Player.player_name + ": $" + str(Player.wallet) + ", " + str(Player.reputation) + " rep")
	print(Shop.shop_name)
	
	$HubCanvas.visible = true
	$HubCanvas/NameEditors/PlayerNameEdit.text = Player.player_name
	$HubCanvas/NameEditors/ShopNameEdit.text = Shop.shop_name
	
	$HUD.visible = false
	
	$BgShop.visible = true
	
	$RequestCanvas.visible = false
	
	available_rerolls = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_hud()


func _on_shop_upgrade_button_pressed() -> void:
	print("TODO: shop upgrade")


func _on_clothes_upgrade_button_pressed() -> void:
	print("TODO: clothes upgrade")


func _on_start_button_pressed() -> void:
	$HubCanvas.visible = false
	$HUD.visible = true
	$BgShop.visible = false
	$RequestCanvas.visible = true
	
	start_request()

func start_request():
	_display_my_items()
	
	reset_item_bag()
	generate_client_items()
	_display_client_items()
	available_rerolls = Shop.max_rerolls
	
	generate_random_client(20, [Enums.Attributes.SIMPLE, Enums.Attributes.CUTE, Enums.Attributes.SILLY], 2, [Enums.Colors.ORANGE, Enums.Colors.YELLOW], 1)
	update_client_display(current_client)


func _display_my_items():
	# clear items
	for n in my_items.get_children():
		my_items.remove_child(n)
		n.queue_free()
	
	# add items
	for dict in Shop.owned_packs:
		var new_pack_grid: PackGrid = pack_grid_prefab.instantiate()
		new_pack_grid.init_child_references()
		new_pack_grid.setup(dict)
		my_items.add_child(new_pack_grid)

func reset_item_bag():
	my_items_bag.clear()
	for clothing in Shop.owned_clothes:
		my_items_bag.append(clothing)
	
	my_items_bag.shuffle()

func generate_client_items():
	client_items_array.clear()
	for i in Shop.max_client_item_number:
		var rand_clothing = my_items_bag.pop_front()
		if rand_clothing:
			client_items_array.append(rand_clothing)
	

func _display_client_items():
	# clear items
	for n in client_items.get_children():
		client_items.remove_child(n)
		n.queue_free()
	
	# add items
	for clothing in client_items_array:
		var clothing_instance: Clothing = clothing_prefab.instantiate()
		clothing_instance.init_child_references()
		clothing_instance.setup(clothing["clothing_name"], clothing["file"], clothing["cost"], 
				clothing["attributes"], clothing["colors"], clothing["type"])
		
		client_items.add_child(clothing_instance)

func update_hud() -> void:
	$HUD/PlayerName.text = Player.player_name
	$HUD/ShopName.text = Shop.shop_name
	$HUD/WalletText.text = "$" + str(Player.wallet)
	$HUD/DayText.text = "Day " + str(current_day)

func generate_client(client_name = "", client_base_price = 0, client_attributes = [], client_colors = []):
	current_client = Client.new(client_name, client_base_price, client_attributes, client_colors)

func generate_random_client(base_price = 20, attribute_bag = [], num_attributes = 0, color_bag = [], num_colors = 0):
	var random_name = random_names.pick_random()
	
	var att_bag_duplicate = attribute_bag.duplicate()
	var col_bag_duplicate = color_bag.duplicate()
	
	att_bag_duplicate.shuffle()
	col_bag_duplicate.shuffle()
	
	var selected_atts = []
	for i in num_attributes:
		selected_atts.append(att_bag_duplicate.pop_front())
	
	var selected_cols = []
	for i in num_colors:
		selected_cols.append(col_bag_duplicate.pop_front())
	
	var selected_price = base_price + (randi_range(0, 5) * 5)

	generate_client(random_name, base_price, selected_atts, selected_cols)
	

func update_client_display(client: Client):
	var tooltip := ""
	tooltip += client.name
	tooltip += "\nWants: "
	for a in client.attribute_needs:
		tooltip += Enums.attribute_to_string(a) + ", "
	for c in client.color_needs:
		tooltip += Enums.color_to_string(c) + ", "
	tooltip = tooltip.left(-2)
	
	$RequestCanvas/Client.tooltip_text = tooltip
	
	$RequestCanvas/ClientName.text = "[center]" + client.name + "[/center]"

func _on_reroll_button_pressed() -> void:
	available_rerolls -= 1
	generate_client_items()
	_display_client_items()
	if available_rerolls <= 0:
		print("No more rerolls!")
		$RequestCanvas/TabletBg/ClientItemsBg/Buttons/RerollButton.visible = false


func _on_player_name_edit_text_changed() -> void:
	var new_name = $HubCanvas/NameEditors/PlayerNameEdit.text
	if (new_name == ""):
		Player.player_name = "Mira"
		return
	Player.player_name = new_name


func _on_shop_name_edit_text_changed() -> void:
	var new_name = $HubCanvas/NameEditors/ShopNameEdit.text
	if (new_name == ""):
		Shop.shop_name = "My Shop"
		return
	Shop.shop_name = new_name


func _on_submit_button_pressed() -> void:
	pass # Replace with function body.
