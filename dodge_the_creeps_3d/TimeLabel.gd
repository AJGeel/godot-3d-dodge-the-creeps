extends Label

var startTime = 0
var totalTime = 0
var timerActive: bool = true

func _ready():
	startTime = OS.get_unix_time()

func _process(_delta):
	total_time_changed()

func total_time_changed():
	if (timerActive):
		var currentTime = OS.get_unix_time()
		totalTime = currentTime - startTime
		update_display(totalTime)

# Returns a string with the format "MM:SS"
func format_time(totalTime):
	var seconds = totalTime % 60
	var minutes = (totalTime / 60) % 60
	
	return "%02d:%02d" % [minutes, seconds]

func update_display(totalTime):
	var formattedTime = format_time(totalTime)
	text = str(formattedTime)

func stop_timer():
	timerActive = false
