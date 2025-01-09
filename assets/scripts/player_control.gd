extends Node

enum STATE {
	IDLE,
	RUNNING,
	JUMPING,
}
var current_state:STATE = STATE.IDLE

@onready var player:Player = self.owner
var is_dying = false
var is_jumping = false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:

	match current_state:
		STATE.IDLE:
			player.velocity.x = 0#move_toward(player.velocity.x, 0, SPEED)
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				print("runing")
				current_state = STATE.RUNNING
			elif Input.is_action_just_pressed("ui_up")  and player.is_on_floor():
				current_state = STATE.JUMPING
		STATE.RUNNING:
			player.velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
			player.player_direction =  Input.get_axis("ui_left", "ui_right")
			if Input.is_action_just_pressed("ui_up") and player.is_on_floor():
				print("jump")
				current_state = STATE.JUMPING
			elif not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
				print("idle")
				current_state = STATE.IDLE
		STATE.JUMPING:
			player.velocity.y = JUMP_VELOCITY  # Update player_direction here
			if player.is_on_floor():
				print("idle")
				current_state = STATE.IDLE
	
	
	#if is_dying:
		#return
	#
	## Add the gravity.
	#if not player.is_on_floor():
		#player.velocity += player.get_gravity() * delta
	#else:
		#is_jumping = false
#
	#if GLOBAL.current_state == GLOBAL.PlayerState.THONG and Input.is_action_just_pressed("fire"):
		#player.fire_thong()
	## Handle jump.
	#if Input.is_action_just_pressed("ui_up") and player.is_on_floor():
		#player.velocity.y = JUMP_VELOCITY
		#is_jumping = true
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#player.velocity.x = direction * SPEED
		#player.player_direction = direction  # Update player_direction here
	#else:
		#player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
#

	#player.update_animation(player.player_direction)
	player.move_and_slide()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
