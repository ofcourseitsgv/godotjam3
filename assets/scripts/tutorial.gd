extends Control

var pages: Array
var current_page_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pages = [$CanvasLayer/Page0, $CanvasLayer/Page1, $CanvasLayer/Page2, $CanvasLayer/Page3, 
			$CanvasLayer/Page4, $CanvasLayer/Page5, $CanvasLayer/Page6, $CanvasLayer/Page7,
			$CanvasLayer/Page8, $CanvasLayer/Page9]
		
	current_page_index = 0
	
	_display_pages()
	
	$ClickSfx.volume_db = linear_to_db(GlobalOptions.sfx_volume)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_tutorial"):
		self.queue_free()

func _display_pages():
	for p in pages:
		p.visible = false
	
	pages[current_page_index].visible = true

func _on_left_pressed() -> void:
	current_page_index = max(current_page_index - 1, 0)
	_display_pages()
	$ClickSfx.play()


func _on_right_pressed() -> void:
	current_page_index = min(current_page_index + 1, pages.size() - 1)
	_display_pages()
	$ClickSfx.play()
