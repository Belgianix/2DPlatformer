extends Area2D

func _ready() -> void:
	$AnimationPlayer.play("Idle")

func _on_End_Goal_body_entered(body: Node) -> void:
	$Label.percent_visible = 1.0
	$Sprite.queue_free()
	$AnimationPlayer.queue_free()
	$CollisionShape2D.queue_free()
