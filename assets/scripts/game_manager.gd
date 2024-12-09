extends Node2D

var current_day := 0
var my_items: Node
var client_items: Node

var pack_grid_prefab = preload("res://assets/scenes/pack_grid.tscn")

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
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_hud()


func _on_player_name_confirm_pressed() -> void:
	var new_name = $HubCanvas/NameEditors/PlayerNameEdit.text
	if (new_name == ""):
		$HubCanvas/NameEditors/PlayerNameEdit.text = Player.player_name
		return
	Player.player_name = new_name


func _on_shop_name_confirm_pressed() -> void:
	var new_name = $HubCanvas/NameEditors/ShopNameEdit.text
	if (new_name == ""):
		$HubCanvas/NameEditors/ShopNameEdit.text = Player.player_name
		return
	Shop.shop_name = new_name


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
	# clear tablet
	for n in my_items.get_children():
		my_items.remove_child(n)
		n.queue_free()
	
	for n in client_items.get_children():
		client_items.remove_child(n)
		n.queue_free()
	
	_display_my_items()

func _display_my_items():
	var file = "res://assets/scripts/clothes.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var master_dict = JSON.parse_string(json_as_text)
	if (master_dict):
		for dict in master_dict["all_packs"]:
			print("Parsing:" + str(dict))
			var new_pack_grid: PackGrid = pack_grid_prefab.instantiate()
			new_pack_grid.init_child_references()
			new_pack_grid.setup(dict)
			my_items.add_child(new_pack_grid)

func update_hud() -> void:
	$HUD/PlayerName.text = Player.player_name
	$HUD/ShopName.text = Shop.shop_name
	$HUD/WalletText.text = "$" + str(Player.wallet)
	$HUD/DayText.text = "Day " + str(current_day)
