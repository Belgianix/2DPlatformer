extends TextureProgress

func _ready() -> void:
	set_value(100)
	
func _on_Player_stamina_changed(stamina, max_stamina) -> void:
	set_value(stamina * 100/max_stamina)

func _on_Player_stamina_refilled() -> void:
	set_value(100)
