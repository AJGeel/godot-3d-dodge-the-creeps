extends Label

var startTime = 0
var millis = 0
var timerActive: bool = true
var kills = 0
var POINTS_PER_KILL = 25
var POINTS_PER_SECOND = 10
var points = 0
var localMultiplier = 1

func _on_Mob_squashed():
	kills += 1 * localMultiplier
	$AnimationPlayer.play('Idle')
	$AnimationPlayer.play('ScoreUp')

func _ready():
	startTime = OS.get_ticks_msec()

func _process(_delta):
	if (timerActive):
		var currentTime = OS.get_ticks_msec()
		millis = currentTime - startTime
		
		calc_points()
		update_display()

func calc_points():
	
	points = (kills * POINTS_PER_KILL) + (millis * POINTS_PER_SECOND / 500)

func update_display():
	text = str(points)

func stop_timer():
	timerActive = false

# Returns a string with the format "MM:SS"
#func format_time(totalTime):
#	var seconds = totalTime % 60
#	var minutes = (totalTime / 60) % 60
#	
#	return "%02d:%02d" % [minutes, seconds]


func _on_Player_multiplier_changed(multiplier):
	localMultiplier = multiplier
	# print(multiplier)
	#pass # Replace with function body.
