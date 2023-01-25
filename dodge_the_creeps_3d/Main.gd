extends Node

export(PackedScene) var mob_scene


func _ready():
	randomize()
	$UserInterface/Retry.hide()


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()

	# Choose a random location on the SpawnPath.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.unit_offset = randf()

	# Communicate the spawn location and the player's location to the mob.
	var player_position = $Player.transform.origin
	mob.initialize(mob_spawn_location.translation, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	# We connect the mob to the score label to update the score upon squashing a mob.
	mob.connect("squashed", $UserInterface/HBoxContainer/ScoreLabel, "_on_Mob_squashed")
	
	# Speed up gradually
	var currentWaitTime = $MobTimer.get_wait_time()
	if (currentWaitTime >= 0.10):
		var newWaitTime = currentWaitTime - currentWaitTime * 0.02 + 0.0025
		$MobTimer.set_wait_time(newWaitTime)


func _on_Player_hit():
	$MobTimer.stop()
	if ($UserInterface/HBoxContainer/ScoreLabel).has_method("stop_timer"):
		$UserInterface/HBoxContainer/ScoreLabel.stop_timer()
	yield(get_tree().create_timer(0.8), "timeout")
	$UserInterface/Retry.show()
	$UserInterface/Retry/AnimationPlayer.play("FadeIn")
