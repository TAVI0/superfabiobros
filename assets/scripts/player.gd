extends CharacterBody2D

var is_jumping = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	move_and_slide()

func update_animation(direction):
	if is_jumping:
		animated_sprite_2d.play("jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction<0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		queue_free()
