extends Node2D

signal dialogue_clicked

var current_day := 1
var my_items: Node
var client_items: Node

var my_items_bag: Array
var client_items_array: Array

var available_rerolls: int

var current_client: Client
var is_popular := false

var new_trendy_chance := 15
var has_trends_updated := false
var has_selected_trendy := false

var master_dialogue: Dictionary
var current_dialogue: Array
var current_dialogue_index: int
var in_dialogue: bool
var player_speaker_text: RichTextLabel
var player_dialogue_text: RichTextLabel
var npc_speaker_text: RichTextLabel
var npc_dialogue_text: RichTextLabel
const NUM_START_DIALOGUES = 2
const NUM_SUCCESS_DIALOGUES = 2
const NUM_OKAY_DIALOGUES = 2
const NUM_FAIL_DIALOGUES = 2

const MAX_DAYS = 60

var prerequest_flag = false
var postrequest_flag = false

var pack_grid_prefab = preload("res://assets/scenes/pack_grid.tscn")
var pack_grid_purchasable_prefab = preload("res://assets/scenes/pack_grid_purchasable.tscn")
var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")

const random_names = ["Jerry", "Sally", "Salt", "Gyle", "Slugon", "Bagel", "Jeremy", "Oswald", "Maria"]
const popular_client_names = ["Benguet", "Angel", "Him", "Hymn"]

var client_base_pay = 15
var client_attribute_bag = [Enums.Attributes.SILLY, Enums.Attributes.CUTE, Enums.Attributes.FORMAL, Enums.Attributes.SIMPLE]
var client_attribute_number = 2
var client_color_bag = [Enums.Colors.BLACK, Enums.Colors.ORANGE, Enums.Colors.BLUE]
var client_color_number = 1

var loading_text_state := 0

var store_items: Node

var fail_flag := false

var showing_tutorial := false

var is_editing_text := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_items = $RequestCanvas/TabletBg/MyItemsBg/ScrollContainer/MasterGrid
	client_items = $RequestCanvas/TabletBg/ClientItemsBg/ScrollContainer/HBoxContainer
	print(Player.player_name + ": $" + str(Player.wallet) + ", " + str(Player.reputation) + " rep")
	print(Shop.shop_name)
	
	$HubCanvas.visible = true
	$HubCanvas/NameEditors/PlayerNameEdit.text = Player.player_name
	$HubCanvas/NameEditors/ShopNameEdit.text = Shop.shop_name
	
	$HUD.visible = true
	$HUD/RewardsText.visible = false
	
	$BgShop.visible = true
	
	$RequestCanvas.visible = false
	$RequestCanvas/CompleteRequestBg.visible = false
	
	$RequestCanvas/WindowOutlines.visible = true
	
	$ApparelStoreCanvas.visible = false
	$ShopUpgradeCanvas.visible = false
	store_items = $ApparelStoreCanvas/PhoneBg/ScrollContainer/MasterGrid
	
	var file = "res://assets/scripts/dialogue.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	master_dialogue = JSON.parse_string(json_as_text)
	in_dialogue = false
	current_dialogue_index = 0
	$DialogueCanvas.visible = false
	$DialogueCanvas/PlayerDialogue.visible = false
	$DialogueCanvas/NpcDialogue.visible = false
	player_speaker_text = $DialogueCanvas/PlayerDialogue/TextureRect/SpeakerText
	player_dialogue_text = $DialogueCanvas/PlayerDialogue/TextureRect2/DialogueText
	npc_speaker_text = $DialogueCanvas/NpcDialogue/TextureRect/SpeakerText
	npc_dialogue_text = $DialogueCanvas/NpcDialogue/TextureRect2/DialogueText
	
	available_rerolls = 0
	
	update_loading_text()
	
	$FailCanvas.visible = false
	var x: AudioStreamPlayer = $Bgm
	$Bgm.play()
	
	update_trends()
	
	transition(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Bgm.playing:
		$Bgm.play()
	update_hud()
	$Bgm.volume_db = linear_to_db(GlobalOptions.music_volume)
	$HoverSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)
	$ClickSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)
	$ChachingSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)
	
	if in_dialogue:
		
		# typewriter effect
		_typewriter_effect()
		
		if Input.is_action_just_pressed("dialogue_key") and not showing_tutorial:
			_progress_dialogue()
	
	# disable other clothes of same type if one is selected
	if client_items_array and client_items.get_child_count() != 0:
		for c: Clothing in client_items.get_children():
			var deselect_flag := false
			for other_clothing: Clothing in client_items.get_children():
				if other_clothing == c:
					continue
				
				if c.type == Enums.Types.ONE_PIECE and (other_clothing.type == Enums.Types.TOP
						or other_clothing.type == Enums.Types.BOTTOM or other_clothing.type == Enums.Types.ONE_PIECE):
					if c.just_deselected:
						deselect_flag = true
						other_clothing.set_enabled()
						#print("re-enabled " + other_clothing.clothing_name)
					elif c.is_selected:
						other_clothing.set_disabled()
				
				if other_clothing.type == c.type and c.type != Enums.Types.ACCESSORY:
					if c.just_deselected:
						deselect_flag = true
						other_clothing.set_enabled()
						#print("re-enabling clothes of type " + str(c.type))
					elif c.is_selected:
						other_clothing.set_disabled()
			c.just_deselected = false
	
	# upgrade store layout
	for g: PackGridPurchasable in store_items.get_children():
		if g.just_purchased:
			g.just_purchased = false
			_display_apparel_store()
	
	if Player.wallet <= 0 or Player.reputation <= 0:
		fail_flag = true
	
	if fail_flag:
		fail_flag = false
		_fail_game()
	
	if Input.is_action_just_pressed("toggle_tutorial") and not is_editing_text:
		if not showing_tutorial:
			var tutorial = preload("res://assets/scenes/tutorial.tscn").instantiate()
			add_child(tutorial)
			showing_tutorial = true
		else:
			showing_tutorial = false

func _fail_game():
	$FailCanvas.visible = true
	var x = await transition(1, [], [], 2)
	x.change_scene_to_file("res://assets/scenes/main_menu.tscn")

func _input(event):
	if event.is_action_pressed("dialogue_key"):
		dialogue_clicked.emit()

func _on_shop_upgrade_button_pressed() -> void:
	click_sfx()
	_display_shop_upgrades()
	await transition(2, [$HubCanvas], [$ShopUpgradeCanvas, $HUD], 0.25)

func _on_clothes_upgrade_button_pressed() -> void:
	click_sfx()
	_display_apparel_store()
	await transition(2, [$HubCanvas], [$ApparelStoreCanvas, $HUD], 0.25)

func _on_start_button_pressed() -> void:
	click_sfx()
	await transition(2, [$HubCanvas, $HubCanvas/NameEditors], [$HUD, $DialogueCanvas, $RequestCanvas/TabletBg], 0.5)
	
	# progression
	_update_progression()
	
	has_selected_trendy = false
	var popular_roll = randi_range(1, 100)
	if popular_roll <= Shop.popular_client_chance:
		print("POPULAR CLIENT!")
		is_popular = true
	var att_num = randi_range(1, client_attribute_number)
	var col_num = randi_range(1, client_color_number)
	generate_random_client(client_base_pay, client_attribute_bag, att_num, client_color_bag, col_num)
	if current_day == 1:
		start_dialogue("begin_dialogue")
	else:
		var random_start = randi_range(0, NUM_START_DIALOGUES - 1)
		var start = "generic_start_" + str(random_start)
		start_dialogue(start)
	prerequest_flag = true

func start_request():
	_display_my_items()
	
	reset_item_bag()
	generate_client_items()
	_display_client_items()
	available_rerolls = Shop.max_rerolls
	$RequestCanvas/TabletBg/ClientItemsBg/Buttons/RerollButton.visible = true
	
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
		if my_items_bag.is_empty():
			reset_item_bag()
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
	$HUD/WalletText.text = "$" + str(Player.wallet) + " -- " + str(Player.reputation) + " rep."
	$HUD/DayText.text = "Day " + str(current_day)

func generate_client(client_name = "", client_base_price = 0, client_attributes = [], client_colors = []):
	current_client = Client.new(client_name, client_base_price, client_attributes, client_colors)

func generate_random_client(base_price = 20, attribute_bag = [], num_attributes = 0, color_bag = [], num_colors = 0):
	var random_name: String
	if is_popular:
		random_name = popular_client_names.pick_random()
	else:
		random_name = random_names.pick_random()
	
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
	
	var selected_price = base_price
	for _i in range(num_attributes + num_colors):
		selected_price += randi_range(1, 6) * (num_attributes + num_colors)

	generate_client(random_name, selected_price, selected_atts, selected_cols)

func update_client_display(client: Client):
	#var tooltip := ""
	var needs_text := ""
	
	#tooltip += client.name
	#tooltip += "\nWants: "
	needs_text += "Attributes: "
	for _a: Enums.Attributes in client.attribute_needs:
		#tooltip += Enums.attribute_to_string(_a) + ", "
		needs_text += Enums.attribute_to_string(_a) + ", "
	if is_popular:
		needs_text += "trendy--"
	needs_text = needs_text.left(-2)
	needs_text += "\nColors: "
	for _c: Enums.Colors in client.color_needs:
		#tooltip += Enums.color_to_string(_c) + ", "
		needs_text += Enums.color_to_string(_c)+ ", "
	needs_text = needs_text.left(-2)
	#tooltip = tooltip.left(-2)
	
	#$RequestCanvas/Client.tooltip_text = tooltip
	
	$RequestCanvas/ClientName.text = _centered_text(_format_popular_client_text(client.name)) if is_popular else _centered_text(client.name)
	$RequestCanvas/ClientNeeds.text = needs_text

func client_check():
	var remaining_atts = current_client.attribute_needs.duplicate()
	var remaining_cols = current_client.color_needs.duplicate()
	
	var chosen_atts = []
	var chosen_cols = []
	
	var chosen_clothes = []
	for clothing: Clothing in client_items.get_children():
		if clothing.is_selected:
			chosen_clothes.append(clothing)
			for a in clothing.attributes:
				chosen_atts.append(a)
			for c in clothing.colors:
				chosen_cols.append(c)
	
	for trend: Dictionary in Shop.trendy_clothes:
		for c: Clothing in chosen_clothes:
			if trend["clothing_name"] == c.clothing_name:
				has_selected_trendy = true
				print("trendy clothes!")
	
	update_check_display(chosen_atts, chosen_cols)
	
	for chosen_att: Enums.Attributes in chosen_atts:
		if chosen_att in remaining_atts:
			var index = remaining_atts.find(chosen_att)
			remaining_atts.remove_at(index)
	
	for chosen_col: Enums.Colors in chosen_cols:
		if chosen_col in remaining_cols:
			var index = remaining_cols.find(chosen_col)
			remaining_cols.remove_at(index)
	
	var error_mark = 1
	if has_selected_trendy:
		error_mark += 1
	
	var num_mistakes = _get_number_mistakes(remaining_atts, remaining_cols)
	
	if is_popular and not has_selected_trendy:
		num_mistakes = 999
	
	if num_mistakes < error_mark:
		current_client.satisfied()
	elif num_mistakes <= error_mark:
		current_client.okay()
	else:
		current_client.dissatisfied()
	print("Remaining properties: " + str(remaining_atts) + " " + str(remaining_cols))

func _get_number_mistakes(atts: Array, cols: Array):
	var num_mistakes = 0
	for a in atts:
		num_mistakes += 1
	for c in cols:
		num_mistakes += 1
	return num_mistakes

func update_check_display(chosen_atts: Array, chosen_cols: Array):
	$RequestCanvas/TabletBg.visible = false
	$RequestCanvas/CompleteRequestBg.visible = true
	$RequestCanvas/WindowOutlines.visible = false
	
	var properties_text = ""
	
	properties_text += "Attributes: "
	for a in chosen_atts:
		properties_text += Enums.attribute_to_string(a) + ", "
	if has_selected_trendy:
		properties_text += "trendy--"
	if chosen_atts.is_empty():
		properties_text += "none--"
	properties_text = properties_text.left(-2)
	properties_text += "\nColors: "
	for c in chosen_cols:
		properties_text += Enums.color_to_string(c)+ ", "
	if chosen_cols.is_empty():
		properties_text += "none--"
	properties_text = properties_text.left(-2)
	#$RequestCanvas/CompleteRequestBg/Screen/SelectedPropertiesName.text = _format_dialogue_text(_centered_text("Selected Properties"))
	$RequestCanvas/CompleteRequestBg/Screen/SelectedProperties.text = _format_dialogue_text(properties_text)

func update_loading_text():
	var loading_text = $RequestCanvas/CompleteRequestBg/Screen/LoadingText
	await _wait(0.2)
	loading_text_state = (loading_text_state + 1) % 4
	var temp: String
	match loading_text_state:
		0:
			temp = "Processing Order"
		1:
			temp = "Processing Order."
		2:
			temp = "Processing Order.."
		3:
			temp = "Processing Order..."
	
	loading_text.text = _centered_text(_format_dialogue_text(temp))
	update_loading_text()

func _on_reroll_button_pressed() -> void:
	click_sfx()
	available_rerolls -= 1
	generate_client_items()
	_display_client_items()
	if available_rerolls <= 0:
		#print("No more rerolls!")
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
	click_sfx()
	client_check()
	await _wait(3.0)
	await transition(2, [$RequestCanvas], [$BgShop, $DialogueCanvas])
	var ind: int
	var d: String
	match current_client.satisfied_val:
		Client.SatisfactionValue.SATISFIED:
			ind = randi_range(0, NUM_SUCCESS_DIALOGUES - 1)
			d = "success_" + str(ind)
		Client.SatisfactionValue.OKAY:
			ind = randi_range(0, NUM_OKAY_DIALOGUES - 1)
			d = "okay_" + str(ind)
		_:
			ind = randi_range(0, NUM_FAIL_DIALOGUES - 1)
			d = "fail_" + str(ind)
	
	start_dialogue(d)
	
	postrequest_flag = true

func _centered_text(s: String):
	return "[center]" + s + "[/center]"

func _wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func transition(mode: int, from_canvases = [], to_canvases = [], fadetime = 1.0):
	$CrossfadeCanvas.visible = true
	
	var tween = get_tree().create_tween()
	match mode:
		0:
			# beginning / from black
			tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,0), fadetime)
			tween.play()
			await _wait(fadetime)
			$CrossfadeCanvas.visible = false
			return
		1:
			# end / to black
			tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,1), fadetime)
			tween.play()
			await _wait(fadetime + 3)
			
			return get_tree()
		2:
			tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,1), fadetime)
			tween.play()
			await _wait(fadetime + 0.2)
			for c in from_canvases:
				c.visible = false
			for c in to_canvases:
				c.visible = true
			var to_tween = get_tree().create_tween()
			to_tween.tween_property($CrossfadeCanvas/Crossfade, "modulate", Color(1,1,1,0), fadetime)
			to_tween.play()
			await _wait(fadetime + 0.2)
			$CrossfadeCanvas.visible = false
			return
		_:
			return

func _progress_dialogue():
	var dialogue_box
	if _current_speaker() == "player":
		dialogue_box = player_dialogue_text
	else:
		dialogue_box = npc_dialogue_text
		
	if dialogue_box.visible_characters >= dialogue_box.get_total_character_count():
		# go to next line, or end dialogue
		current_dialogue_index += 1
		if current_dialogue_index < current_dialogue.size():
			if _current_speaker() == "player":
				$DialogueCanvas/NpcDialogue.visible = false
				$DialogueCanvas/PlayerDialogue.visible = true
				player_dialogue_text.visible_characters = 0
				player_dialogue_text.text = current_dialogue[current_dialogue_index]["text"]
				player_speaker_text.text = Player.player_name
			elif _current_speaker() == "client":
				$DialogueCanvas/PlayerDialogue.visible = false
				$DialogueCanvas/NpcDialogue.visible = true
				npc_dialogue_text.visible_characters = 0
				npc_dialogue_text.text = current_dialogue[current_dialogue_index]["text"]
				npc_speaker_text.text = current_client.name if not is_popular else _format_popular_client_text(current_client.name)
		else:
			#print("finish dialogue")
			in_dialogue = false
			_resolve_dialogue()
	else:
		# insta-fill
		dialogue_box.visible_characters = dialogue_box.get_total_character_count()

func start_dialogue(dialogue_name: String):
	current_dialogue = master_dialogue[dialogue_name]
	current_dialogue_index = 0
	in_dialogue = true
	if _current_speaker() == "player":
		$DialogueCanvas/NpcDialogue.visible = false
		$DialogueCanvas/PlayerDialogue.visible = true
		player_dialogue_text.visible_characters = 0
		player_dialogue_text.text = current_dialogue[current_dialogue_index]["text"]
		player_speaker_text.text = Player.player_name
	elif _current_speaker() == "client":
		$DialogueCanvas/PlayerDialogue.visible = false
		$DialogueCanvas/NpcDialogue.visible = true
		npc_dialogue_text.visible_characters = 0
		npc_dialogue_text.text = current_dialogue[current_dialogue_index]["text"]
		npc_speaker_text.text = current_client.name if not is_popular else _format_popular_client_text(current_client.name)

func _typewriter_effect():
	var visible_characters
	var total_characters
	var dialogue_box
	if _current_speaker() == "player":
		visible_characters = player_dialogue_text.visible_characters
		total_characters = player_dialogue_text.get_total_character_count()
		dialogue_box = player_dialogue_text
	else:
		visible_characters = npc_dialogue_text.visible_characters
		total_characters = npc_dialogue_text.get_total_character_count()
		dialogue_box = npc_dialogue_text
	
	if visible_characters < total_characters:
		match GlobalOptions.text_speed:
			GlobalOptions.TextSpeeds.FAST:
				dialogue_box.visible_characters = min(total_characters, visible_characters + 2)
			GlobalOptions.TextSpeeds.FASTER:
				dialogue_box.visible_characters = min(total_characters, visible_characters + 3)
			GlobalOptions.TextSpeeds.INSTANT:
				dialogue_box.visible_characters = total_characters
			_:
				dialogue_box.visible_characters += 1

func _format_popular_client_text(s: String):
	return "[color=ffcf40]" + s + "[/color]"

func _format_dialogue_text(s: String):
	return "[color=4c2b21]" + s + "[/color]"

func _current_speaker():
	return current_dialogue[current_dialogue_index]["speaker"]

func _resolve_dialogue():
	if in_dialogue:
		return
	
	if prerequest_flag:
		prerequest_flag = false
		start_request()
		await transition(2, [$DialogueCanvas, $DialogueCanvas/PlayerDialogue, $DialogueCanvas/NpcDialogue, $BgShop], [$RequestCanvas], 0.5)
		#start_request()
	elif postrequest_flag:
		postrequest_flag = false
		var money_gained := 0
		var rep_gained := 0
		match current_client.satisfied_val:
			Client.SatisfactionValue.SATISFIED:
				money_gained += current_client.base_price + (randi_range(2, 6) * 5)
				rep_gained += int(randi_range(5,10) * Shop.reputation_mult)
				if is_popular:
					rep_gained += int(randi_range(50,100) * Shop.reputation_mult)
					money_gained += randi_range(25, 50)
			Client.SatisfactionValue.OKAY:
				money_gained += current_client.base_price
				rep_gained += int(randi_range(0, 4) * Shop.reputation_mult)
				if is_popular:
					rep_gained += int(randi_range(10,40) * Shop.reputation_mult)
					money_gained += randi_range(10, 25)
			_:
				money_gained += int(current_client.base_price / 2)
				var err = client_attribute_number + client_color_number
				for _i in err:
					rep_gained -= int(randi_range(0, 4) * Shop.reputation_mult)
				if is_popular:
					rep_gained -= int(randi_range(10, 10 + err * 3) * Shop.reputation_mult)
		await transition(2, [$DialogueCanvas, $RequestCanvas, $RequestCanvas/CompleteRequestBg, $DialogueCanvas/PlayerDialogue, $DialogueCanvas/NpcDialogue], [$HubCanvas], 0.5)
		var trendy_roll = randi_range(1, 100)
		if trendy_roll <= new_trendy_chance:
			update_trends()
			has_trends_updated = true
		else:
			has_trends_updated = false
		_display_rewards_text(money_gained, rep_gained)
		Player.wallet += money_gained
		Player.reputation += rep_gained
		
		
		current_day += 1
		chaching_sfx()

func _display_rewards_text(money: int, rep: int):
	var rewards = "[center]"
	if money > 0:
		rewards += "+$" + str(money) + ",  "
	rewards += "+" if rep >= 0 else ""
	rewards += str(rep) + " rep"
	if current_day % 5 == 0:
		rewards += "\nNew apparel pack available!"
	if has_trends_updated:
		rewards += "\n\nThe current trends have changed!"
	rewards += "[/center]"
	$HUD/RewardsText.text = rewards
	$HUD/RewardsText.modulate = Color(1,1,1,1)
	$HUD/RewardsText.visible = true
	await _wait(2)
	
	var tween = get_tree().create_tween()
	tween.tween_property($HUD/RewardsText, "modulate", Color(1,1,1,0), 3)
	tween.play()
	await _wait(3.1)
	$HUD/RewardsText.visible = false

func _update_progression():
	# every 3 days, add new attribute
	if current_day % 3 == 0:
		client_base_pay += 5
		var all_atts = Enums.get_attributes()
		var new_att = all_atts.pick_random()
		client_attribute_bag.append(new_att)
		print("new attribute: " + str(new_att))
	
	# every 4 days, add new color
	if current_day % 4 == 0:
		client_base_pay += 5
		var all_cols = Enums.get_colors()
		var new_col = all_cols.pick_random()
		client_color_bag.append(new_col)
		print("new color: " + str(new_col))
	
	# every 5 days, add new pack
	if current_day % 5 == 0:
		var packs = Shop.all_packs.duplicate()
		packs.shuffle()
		var picked_pack
		for _i in packs.size():
			if (packs[_i] not in Shop.buyable_packs) and (packs[_i] not in Shop.owned_packs):
				picked_pack = packs[_i]
				break
		if not picked_pack:
			print("No new packs available")
		elif Shop.make_pack_buyable(picked_pack):
			print("new pack: " + picked_pack["pack"])
		else:
			print("Error: invalid pack")
	
	# every 6 days, increase max colors/attributes
	if current_day % 6 == 0:
		client_base_pay += 10
		var c = randi_range(0, 5)
		if c >= 0 and c <= 1:
			client_color_number += 1
			print("+1 color")
		else:
			client_attribute_number += 1
			print("+1 attribute")
	
	if current_day % 7 == 0:
		print("Bills Day!")
		# pay rent each week?
	
	if current_day >= MAX_DAYS:
		print("LAST DAY!")
		fail_flag = true

func _display_apparel_store():
	# clear items
	for n in store_items.get_children():
		store_items.remove_child(n)
		n.queue_free()
	
	# add items
	for dict in Shop.buyable_packs:
		var new_pack_grid: PackGridPurchasable = pack_grid_purchasable_prefab.instantiate()
		new_pack_grid.init_child_references()
		new_pack_grid.setup(dict)
		store_items.add_child(new_pack_grid)
		

func update_trends():
	var trends = Shop.generate_trendy()
	var trendy_box = $HubCanvas/TrendyButton/TrendyPopup/TrendyContainer
	for n in trendy_box.get_children():
		trendy_box.remove_child(n)
		n.queue_free()
	
	for clothing in trends:
		var clothing_instance: Clothing = clothing_prefab.instantiate()
		clothing_instance.init_child_references()
		clothing_instance.setup(clothing["clothing_name"], clothing["file"], clothing["cost"], 
				clothing["attributes"], clothing["colors"], clothing["type"])
		
		trendy_box.add_child(clothing_instance)

func _display_shop_upgrades():
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade1.text = Shop.get_upgrade_title("crates")
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade1/Desc1.text = Shop.get_upgrade_description("crates")
	
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade2.text = Shop.get_upgrade_title("wardrobe")
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade2/Desc2.text = Shop.get_upgrade_description("wardrobe")
	
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade3.text = Shop.get_upgrade_title("decor")
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade3/Desc3.text = Shop.get_upgrade_description("decor")
	
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade4.text = Shop.get_upgrade_title("social_media")
	$ShopUpgradeCanvas/ShopUpgradeBg/VBoxContainer/Upgrade4/Desc4.text = Shop.get_upgrade_description("social_media")

func _on_return_button_pressed() -> void:
	click_sfx()
	transition(2, [$ApparelStoreCanvas, $ShopUpgradeCanvas], [$HubCanvas], 0.25)


func _on_purchase_1_pressed() -> void:
	if Shop.purchase_upgrade("crates"):
		chaching_sfx()
	_display_shop_upgrades()
	click_sfx()

func _on_purchase_2_pressed() -> void:
	if Shop.purchase_upgrade("wardrobe"):
		chaching_sfx()
	_display_shop_upgrades()
	click_sfx()

func _on_purchase_3_pressed() -> void:
	if Shop.purchase_upgrade("decor"):
		chaching_sfx()
	_display_shop_upgrades()
	click_sfx()

func _on_purchase_4_pressed() -> void:
	if Shop.purchase_upgrade("social_media"):
		chaching_sfx()
	_display_shop_upgrades()
	click_sfx()

func hover_sfx():
	$HoverSfx.play()

func click_sfx():
	$ClickSfx.play()

func chaching_sfx():
	$ChachingSfx.play()


func _on_start_button_mouse_entered() -> void:
	hover_sfx()


func _on_shop_upgrade_button_mouse_entered() -> void:
	hover_sfx()


func _on_clothes_upgrade_button_mouse_entered() -> void:
	hover_sfx()


func _on_reroll_button_mouse_entered() -> void:
	hover_sfx()


func _on_submit_button_mouse_entered() -> void:
	hover_sfx()


func _on_return_button_mouse_entered() -> void:
	hover_sfx()


func _on_purchase_1_mouse_entered() -> void:
	hover_sfx()


func _on_purchase_2_mouse_entered() -> void:
	hover_sfx()


func _on_purchase_3_mouse_entered() -> void:
	hover_sfx()


func _on_purchase_4_mouse_entered() -> void:
	hover_sfx()


func _on_return_button_2_mouse_entered() -> void:
	hover_sfx()


func _on_trendy_button_toggled(toggled_on: bool) -> void:
	click_sfx()
	if toggled_on:
		$HubCanvas/TrendyButton/TrendyPopup.popup()
	else:
		$HubCanvas/TrendyButton/TrendyPopup.hide()


func _on_request_trendy_button_toggled(toggled_on: bool) -> void:
	click_sfx()
	if toggled_on:
		$HubCanvas/TrendyButton/TrendyPopup.popup()
	else:
		$HubCanvas/TrendyButton/TrendyPopup.hide()


func _on_trendy_button_mouse_entered() -> void:
	hover_sfx()


func _on_request_trendy_button_mouse_entered() -> void:
	hover_sfx()


func _on_player_name_edit_focus_entered() -> void:
	is_editing_text = true
	click_sfx()


func _on_player_name_edit_focus_exited() -> void:
	is_editing_text = false
	hover_sfx()


func _on_shop_name_edit_focus_entered() -> void:
	is_editing_text = true
	click_sfx()


func _on_shop_name_edit_focus_exited() -> void:
	is_editing_text = false
	hover_sfx()
