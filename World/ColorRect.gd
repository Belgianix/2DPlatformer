extends ColorRect

func _ready() -> void:
	self.color = Color(0,0,0,0)

func _on_World_player_died() -> void:
	self.color = Color(0.3,0,0,0.8)

func _on_World_player_respawned() -> void:
	self.color = Color(0,0,0,0)
