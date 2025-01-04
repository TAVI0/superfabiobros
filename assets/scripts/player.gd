extends CharacterBody2D

var is_dying = false
var is_jumping = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
#@onready var deathTimer = $deathTimer
func _ready():
	add_to_group("Player")
	#deathTimer.connect("timeout", Callable(self, "_on_death_timer_timeout"))

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
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
	if is_dying:
		return
		
	if is_jumping:
		animated_sprite_2d.play("jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction<0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		die()

func die():
	if is_dying:
		return
	is_dying = true
	animated_sprite_2d.play("die")
	await move_player_up_and_down()
	GLOBAL.lives -= 1
	if GLOBAL.lives > 0:
		print("RELOAD SCENE")
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scene/gameover.tscn")

func move_player_up_and_down():
	$CollisionShape2D.free()
	$hitbox/CollisionShape2D.free()
	var start_position = position
	var up_position = start_position + Vector2(0,-100)
	var down_position = start_position + Vector2(0, 600)
	
	while position.y > up_position.y:
		position.y -=4
		await  get_tree().create_timer(0.01).timeout
	while position.y < down_position.y:
		position.y +=4
		await  get_tree().create_timer(0.01).timeout


func _on_pitfall_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		die()
