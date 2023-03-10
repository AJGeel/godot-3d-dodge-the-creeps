extends KinematicBody

signal hit
signal multiplier_changed(multiplier)

# How fast the player moves in meters per second.
export var speed = 14
# Vertical impulse applied to the character upon jumping in meters per second.
export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in meters per second.
export var bounce_impulse = 16
# The downward acceleration when in the air, in meters per second per second.
export var fall_acceleration = 75

var lastCollision = null
var velocity = Vector3.ZERO
var isOnFloor = true
var isDead = false
var multiplier = 1

#onready var GroundNode = get_parent().get_node("Ground/CollisionShape")


func _physics_process(delta):	
	if (!isDead):
		# Update last collision ID
		#if (lastCollision):
		#	print(lastCollision.get_collider())
		#	print(GroundNode)
			#if (lastCollision.get_collider() != GroundNode):
			#	isOnFloor = false
			#else:
			#	isOnFloor = true
		
		#print(isOnFloor)
		
		var direction = Vector3.ZERO
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_back"):
			direction.z += 1
		if Input.is_action_pressed("move_forward"):
			direction.z -= 1

		if direction != Vector3.ZERO:
			# In the lines below, we turn the character when moving and make the animation play faster.
			direction = direction.normalized()
			$Pivot.look_at(translation + direction, Vector3.UP)
			$AnimationPlayer.playback_speed = 4
		else:
			$AnimationPlayer.playback_speed = 1

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# Jumping.
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y += jump_impulse

		# We apply gravity every frame so the character always collides with the ground when moving.
		# This is necessary for the is_on_floor() function to work as a body can always detect
		# the floor, walls, etc. when a collision happens the same frame.
		velocity.y -= fall_acceleration * delta
		velocity = move_and_slide(velocity, Vector3.UP)

		# Here, we check if we landed on top of a mob and if so, we kill it and bounce.
		# With move_and_slide(), Godot makes the body move sometimes multiple times in a row to
		# smooth out the character's motion. So we have to loop over all collisions that may have
		# happened.
		# If there are no "slides" this frame, the loop below won't run.
		for index in range(get_slide_count()):
			var collision = get_slide_collision(index)
			if collision.collider.is_in_group("mob"):
				# Add exponentially increasing points for bouncing on mobs
				multiplier *= 2
				emit_signal("multiplier_changed", multiplier)
				var mob = collision.collider
				if Vector3.UP.dot(collision.normal) > 0.1:
					mob.squash()
					velocity.y = bounce_impulse
			else:
				emit_signal("multiplier_changed", multiplier)
				multiplier = 1

		# This makes the character follow a nice arc when jumping
		$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


func die():
	emit_signal("hit")
	isDead = true
	$AnimationPlayer.playback_speed = 1
	$AnimationPlayer.play("die")
	$CollisionShape.set_disabled(true)
	$MobDetector/CollisionShape.set_disabled(true)


func _on_MobDetector_body_entered(_body):
	die()
