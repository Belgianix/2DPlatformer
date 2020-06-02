extends Node2D

var player = preload("res://Player/Player.tscn")
var player_is_dead = false

signal player_died()
signal player_respawned()

onready var player_position = $Player.global_position

func _process(_delta: float) -> void:
	if player_is_dead:
		emit_signal("player_died")
		if Input.is_action_pressed("respawn"):
			var Player = player.instance()
			get_parent().add_child(Player)
			print(player_position)
			Player.global_position = player_position
			player_is_dead = false
			print("respawn")
			Player.connect("tree_exited", self, "_on_Player_tree_exiting")
			emit_signal("player_respawned")

func _on_Player_tree_exiting() -> void:
	player_is_dead = true
	print ("dead")
