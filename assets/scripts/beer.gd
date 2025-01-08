extends CharacterBody2D

var speed = 30
var direction = -1
var facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("Beer")
	add_to_group("collectable")

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity.y += gravity * delta
	velocity.x = speed * direction
	
	if $RayCast2D.is_colliding() && is_on_floor():
		flip()

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.become_big()
		queue_free()
	direction *= -1
