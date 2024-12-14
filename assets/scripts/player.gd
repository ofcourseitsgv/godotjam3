extends Node

static var player_name: String
static var wallet: int
static var reputation: int

func _init():
	player_name = "Mira G."
	wallet = 40777
	reputation = 10

func _reset():
	_init()
