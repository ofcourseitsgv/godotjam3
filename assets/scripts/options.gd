extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/TextSpeedDropdown.select(GlobalOptions.text_speed)
	$CanvasLayer/MusicVol.value = GlobalOptions.music_volume
	$CanvasLayer/SfxVol.value = GlobalOptions.sfx_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GlobalOptions.text_speed = $CanvasLayer/TextSpeedDropdown.selected
	GlobalOptions.music_volume = $CanvasLayer/MusicVol.value
	GlobalOptions.sfx_volume = $CanvasLayer/SfxVol.value
	
	if Input.is_action_just_pressed("ui_cancel"):
		self.queue_free()


func _on_return_button_pressed() -> void:
	self.queue_free()
