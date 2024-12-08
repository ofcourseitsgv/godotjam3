extends Node

var itemlist
var textbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itemlist = get_node("BaseCanvas/ItemCanvas/ItemList")
	textbox = get_node("BaseCanvas/Text")

	textbox.text = "[center]Let's get it started![/center]"
	reset_clothes()

	Object.new()


func reset_clothes() -> void:
	itemlist.clear()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
