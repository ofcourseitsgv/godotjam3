class_name PackGridPurchasable extends PackGrid

var cost: int
var pack_name: String
var just_purchased := false

func setup(pack_dict: Dictionary):
	pack_text.text = "\t[color=3f1f16]" + pack_dict["display_name"] + " -- $" + str(pack_dict["cost"]) + "[/color]"
	
	cost = pack_dict["cost"]
	pack_name = pack_dict["pack"]
	
	for n in clothes_grid.get_children():
		clothes_grid.remove_child(n)
		n.queue_free()
	
	for clothing_dict in pack_dict["clothes"]:
		var clothing_instance: Clothing = clothing_prefab.instantiate()
		clothing_instance.init_child_references()
		clothing_instance.setup(clothing_dict["clothing_name"], clothing_dict["file"], 
				clothing_dict["cost"], clothing_dict["attributes"], clothing_dict["colors"], clothing_dict["type"])
		clothing_instance.clothing_button.disabled = true
		clothes_grid.add_child(clothing_instance)
		clothes_dict.append(clothing_dict)


func _on_purchase_button_pressed() -> void:
	Shop.purchase_pack(pack_name)
	$PurchaseButton.visible = false
	just_purchased = true
