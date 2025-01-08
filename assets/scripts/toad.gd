extends CharacterBody2D

var SPEED =  25.0
var facing_right = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D   
func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	# Add the gravity.
	velocity.y += gravity * delta
	
	# Set the horizontal velocity to a constant negative value to move left.
	velocity.x = -SPEED
	if $RayCast2D2.is_colliding() && is_on_floor():
		flip()
	update_animation()
	move_and_slide()
	
func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		SPEED = abs(SPEED)
	else:
		SPEED = abs(SPEED) * -1

func update_animation():
	animated_sprite_2d.play("hop")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && !body.damaged:
		queue_free()
	
