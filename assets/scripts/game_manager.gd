extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Player.player_name + ": $" + str(Player.wallet) + ", " + str(Player.reputation) + " rep")
	print(Shop.shop_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
