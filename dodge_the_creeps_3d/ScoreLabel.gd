extends Label

var score = 0

func _on_Mob_squashed():
	score += 1
	text = "Kills: %s" % score
	$AnimationPlayer.play('Idle')
	$AnimationPlayer.play('ScoreUp')
