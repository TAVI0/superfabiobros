extends CharacterBody2D

var is_dying = false
var is_jumping = false
var is_big = false
var is_firing_thong = false
var can_fire_thong = false
var player_direction = 1

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var thong_fire_timer =	$ThongFireTimer
#@onready var deathTimer = $deathTimer
func _ready():
	add_to_group("Player")
	thong_fire_timer.connect("timeout", Callable(self, "_on_ThongFireTimer_timeout"))
	#deathTimer.connect("timeout", Callable(self, "_on_death_timer_timeout"))

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false

	if GLOBAL.current_state == GLOBAL.PlayerState.THONG and Input.is_action_just_pressed("fire"):
		fire_thong()
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		player_direction = direction  # Update player_direction here
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


	update_animation(direction)
	move_and_slide()
	
func update_animation(direction):
	if is_dying or is_firing_thong:
		return
	match GLOBAL.current_state:
		GLOBAL.PlayerState.SMALL, GLOBAL.PlayerState.BIG:
			if is_jumping:
				animated_sprite_2d.play("jump")
			elif direction != 0:
				animated_sprite_2d.flip_h = (direction<0)
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")
		GLOBAL.PlayerState.THONG:
			if is_jumping:
				animated_sprite_2d.play("thong_jump")
			elif direction != 0:
				animated_sprite_2d.flip_h = (direction<0)
				animated_sprite_2d.play("thong_run")
			else:
				animated_sprite_2d.play("thong_idle")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		match GLOBAL.current_state:
			GLOBAL.PlayerState.SMALL:
				die()
			GLOBAL.PlayerState.BIG:
				GLOBAL.current_state = GLOBAL.PlayerState.SMALL
				become_small()
			GLOBAL.PlayerState.THONG:
				GLOBAL.current_state = GLOBAL.PlayerState.BIG	

func die():
	if is_dying:
		return
	is_dying = true
	animated_sprite_2d.play("die")
	await move_player_up_and_down()
	GLOBAL.lives -= 1
	become_small()
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

func become_big():
	GLOBAL.current_state= GLOBAL.PlayerState.BIG
	self.scale = Vector2(1.5, 1.5)

func become_small():
	GLOBAL.current_state= GLOBAL.PlayerState.SMALL
	self.scale = Vector2(1,1)
	
func got_thong():
	GLOBAL.current_state = GLOBAL.PlayerState.THONG

func fire_thong():
	var direction := 1
	if Input.get_axis("ui_left", "ui_right") != 0:
		direction = Input.get_axis("ui_left", "ui_right")
	print(direction)
	is_firing_thong = true
	print("firing thong")
	var thong = load("res://scene/thonge.tscn").instantiate()
	thong.global_position = Vector2(self.global_position.x, self.global_position.y - 15)
	thong.set("velocity", Vector2(500 * player_direction, 0))
	print("Thong fired")
	get_parent().add_child(thong)
	$AnimatedSprite2D.play("thong_fire")
	thong_fire_timer.start(0.5)
	is_firing_thong = false
