extends Label

func _ready() -> void:
	percent_visible = 0.0

func _on_World_player_died() -> void:
	percent_visible = 1.0


func _on_World_player_respawned() -> void:
	percent_visible = 0.0
