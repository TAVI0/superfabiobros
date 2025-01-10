extends Node

@onready var player:Player = self.owner
var is_dying = false
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var idle = "idle"
var run = "run"
var jump = "jump"

func _physics_process(delta: float) -> void:
	player.animated_sprite_2d.flip_h = (player.player_direction<0)
	
	match GLOBAL.current_state:
		GLOBAL.PlayerState.SMALL, GLOBAL.PlayerState.BIG:
			idle = "idle"
			run = "run"
			jump = "jump"
		GLOBAL.PlayerState.THONG:
			idle = "thong_idle"
			run = "thong_run"
			jump = "thong_jump"
	
	match GLOBAL.current_move:
		GLOBAL.MOVE_STATE.IDLE:
			player.animated_sprite_2d.play(idle)
			player.velocity.x = 0#move_toward(player.velocity.x, 0, SPEED)
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				GLOBAL.current_move = GLOBAL.MOVE_STATE.RUNNING
			elif Input.is_action_just_pressed("ui_up")  and player.is_on_floor():
				GLOBAL.current_move = GLOBAL.MOVE_STATE.JUMPING
		GLOBAL.MOVE_STATE.RUNNING:
			player.velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
			player.player_direction =  Input.get_axis("ui_left", "ui_right")
			player.animated_sprite_2d.play(run)
			if Input.is_action_just_pressed("ui_up") and player.is_on_floor():
				GLOBAL.current_move = GLOBAL.MOVE_STATE.JUMPING
			elif not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
				GLOBAL.current_move = GLOBAL.MOVE_STATE.IDLE
		GLOBAL.MOVE_STATE.JUMPING:
			if player.is_on_floor() and player.velocity.y >= 0:
				player.animated_sprite_2d.play(jump)
				player.velocity.y = JUMP_VELOCITY
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				GLOBAL.current_move = GLOBAL.MOVE_STATE.RUNNING
			if player.velocity.y > 0:
				GLOBAL.current_move = GLOBAL.MOVE_STATE.FALLING
		GLOBAL.MOVE_STATE.FALLING:
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				GLOBAL.current_move = GLOBAL.MOVE_STATE.RUNNING
			if player.velocity.y >= 0 and player.is_on_floor():
				GLOBAL.current_move = GLOBAL.MOVE_STATE.IDLE
		GLOBAL.MOVE_STATE.DIYING:
			player.animated_sprite_2d.play("die")

	player.move_and_slide()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
