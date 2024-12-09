extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Player.player_name + ": $" + str(Player.wallet) + ", " + str(Player.reputation) + " rep")
	print(Shop.shop_name)
	
	$HubCanvas/NameEditors/PlayerNameEdit.text = Player.player_name
	$HubCanvas/NameEditors/ShopNameEdit.text = Shop.shop_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
