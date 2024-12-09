extends Node

static var shop_name: String
static var upgrades: Array
static var all_packs: Array
static var owned_packs: Array

static var all_clothes: Array
static var owned_clothes: Array

static var max_rerolls: int
static var max_client_item_number: int

func _init() -> void:
	shop_name = "My Own Shop"
	upgrades = []
	all_packs = []
	owned_packs = []
	
	max_rerolls = 1
	max_client_item_number = 3
	
	_init_parse()

func _init_parse():
	var file = "res://assets/scripts/clothes.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var master_dict = JSON.parse_string(json_as_text)
	if (master_dict):
		for pack in master_dict["all_packs"]:
			print("Parsing " + pack["pack"] + " pack: \"" + pack["display_name"] + "\"")
			all_packs.append(pack)
			if pack["owned_by_default"] == 1:
				owned_packs.append(pack)
			
			for clothing in pack["clothes"]:
				all_clothes.append(clothing)
				if pack["owned_by_default"] == 1:
					owned_clothes.append(clothing)
