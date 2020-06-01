extends ProgressBar

func _ready() -> void:
	set_value(100)
func _on_Player_stamina_changed(stamina) -> void:
	set_value(stamina * 33.333)
	print(stamina * 33.333)


func _on_Player_stamina_refilled(stamina) -> void:
	set_value(100)
