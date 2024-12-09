class_name PackGrid extends GridContainer

@export

var pack_text: RichTextLabel
var clothes_grid: GridContainer
var clothing_prefab = preload("res://assets/tempAssets/clothing.tscn")
var clothes_dict: Array
var owned: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owned = false

func init_child_references():
	pack_text = get_node("PackText")
	clothes_grid = get_node("GridContainer")

func setup(pack_dict: Dictionary):
	pack_text.text = "\t" + pack_dict["display_name"]
	
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

func get_clothes_dict():
	return clothes_dict
