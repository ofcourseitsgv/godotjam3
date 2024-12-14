extends Node

static var shop_name: String
static var upgrades: Dictionary
static var all_packs: Array
static var owned_packs: Array

static var all_clothes: Array
static var owned_clothes: Array

static var max_rerolls: int
static var max_client_item_number: int

static var reputation_mult: float
static var popular_client_chance: int

func _init() -> void:
	shop_name = "My Shop"
	upgrades = {
		"crates": {"owned": 0, "cost": 105, "cost_mult": 1.75},
		"wardrobe": {"owned": 0, "cost": 85, "cost_mult": 2.5},
		"decor": {"owned": 0, "cost": 130, "cost_mult": 1.3},
		"social_media": {"owned": 0, "cost": 250, "cost_mult": 1.1}
	}
	all_packs = []
	owned_packs = []
	
	max_rerolls = 1
	max_client_item_number = 3
	reputation_mult = 1.0
	popular_client_chance = 1
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

func purchase_pack(pack_name: String):
	for dict in all_packs:
		if dict["pack"] == pack_name and dict["pack"] not in owned_clothes:
			if Player.wallet >= dict["cost"]:
				Player.wallet -= dict["cost"]
				owned_packs.append(dict)
				
				for clothing in dict["clothes"]:
					owned_clothes.append(clothing)

func _update_shop_upgrades():
	max_rerolls = 1 + upgrades["crates"]["owned"]
	max_client_item_number = 3 + upgrades["wardrobe"]["owned"]
	reputation_mult = 1.0 + (0.2 * upgrades["decor"]["owned"])
	popular_client_chance = min(1 + (2 * upgrades["social_media"]["owned"]), 100)

func purchase_upgrade(upg: String):
	if upg not in upgrades:
		print("Error: invalid upgrade")
		return
	
	if Player.wallet < upgrades[upg]["cost"]:
		print("Not enough money")
		return
	
	Player.wallet -= upgrades[upg]["cost"]
	upgrades[upg]["owned"] += 1
	upgrades[upg]["cost"] = int(upgrades[upg]["cost"] * upgrades[upg]["cost_mult"])
	
	_update_shop_upgrades()

func get_upgrade_title(upg: String):
	if upg not in upgrades:
		print("Error: invalid upgade title")
	var str := ""
	match upg:
		"crates":
			str += "Storage Crates"
		"wardrobe":
			str += "Bigger Wardrobe"
		"decor":
			str += "Nicer Decorations"
		"social_media":
			str += "Social Media Post"
	str += " - $" + str(upgrades[upg]["cost"])
	return str

func get_upgrade_description(upg: String):
	if upg not in upgrades:
		print("Error: invalid upgade desc.")
	var str := ""
	var _owned := "\nYou currently have " + str(upgrades[upg]["owned"]) + "."
	match upg:
		"crates":
			str += "Gives 1 more Re-Gather to change clothing options." + _owned
			str += " (" + str(max_rerolls) + " total re-gathers)"
		"wardrobe":
			str += "Adds 1 more clothing option per available selection." + _owned
			str += " (" + str(max_client_item_number) + " total options)"
		"decor":
			str += "+0.2x multiplier to any reputation gained." + _owned
			str += " (" + str(snapped(reputation_mult, 0.1)) + "x reputation mult.)"
		"social_media":
			str += "+2% chance to get a famous client! They'll boost your rep a lot." + _owned
			str += " (" + str(popular_client_chance) + "% chance)"
	
	return str
