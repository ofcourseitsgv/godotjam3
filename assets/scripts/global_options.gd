extends Node

var music_volume := 1.0
var sfx_volume := 1.0

enum TextSpeeds {
	DEFAULT,
	FAST,
	FASTER,
	INSTANT,
}

var text_speed := TextSpeeds.DEFAULT
