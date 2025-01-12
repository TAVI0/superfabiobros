class_name Player
extends CharacterBody2D

var is_dying = false
var is_jumping = false
var is_big = false
var is_firing_thong = false
var can_fire_thong = false
var player_direction = 1
var invulnerable = false
var damaged = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var thong_fire_timer =	$ThongFireTimer

func _ready():
	add_to_group("Player")
	thong_fire_timer.connect("timeout", Callable(self, "_on_ThongFireTimer_timeout"))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and !invulnerable:
		match GLOBAL.current_state:
			GLOBAL.PlayerState.SMALL:
				die()
			GLOBAL.PlayerState.BIG:
				become_small()
			GLOBAL.PlayerState.THONG:
				GLOBAL.current_state = GLOBAL.PlayerState.BIG
		damaged = true
		if(!is_dying):
			await make_invulnerable(2)
		damaged =false

func make_invulnerable(duration):
	invulnerable = true
	$hitbox.set_collision_mask_value(3, !invulnerable)
	$".".set_collision_mask_value(3, !invulnerable)
	animation_blink()  # Inicia el parpadeo
	await get_tree().create_timer(duration).timeout  # Espera el tiempo de invulnerabilidad
	invulnerable = false  # Termina el estado de invulnerabilidad
	$hitbox.set_collision_mask_value(3, !invulnerable)
	$".".set_collision_mask_value(3, !invulnerable)
	$AnimatedSprite2D.visible = true  # Asegura que el sprite sea visible al final
	
func animation_blink():
	while invulnerable:
		$AnimatedSprite2D.visible = false  # Oculta el spriteS
		await get_tree().create_timer(0.05).timeout  # Espera 0.05 segundos
		$AnimatedSprite2D.visible = true  # Muestra el sprite
		await get_tree().create_timer(0.05).timeout  # Espera 0.05 segundos

func die():
	if is_dying:
		return
	is_dying = true
	GLOBAL.current_move = GLOBAL.MOVE_STATE.DIYING
	await move_player_up_and_down()
	print("MOVIDO")
	GLOBAL.lives -= 1
	become_small()
	var collectables = get_tree().get_nodes_in_group("collectable")  # Obtiene todos los nodos del grupo
	for node in collectables:
		if node:  # Verifica que el nodo no sea nulo
			node.queue_free()  # Libera el nodo
	if GLOBAL.lives > 0:
		print("RECARGANDO ESCENA")
		GLOBAL.current_move = GLOBAL.MOVE_STATE.IDLE
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scene/gameover.tscn")

func move_player_up_and_down():
	# Desactivar colisiones para evitar interacciones durante la animación
	$CollisionShape2D.disabled = true
	$hitbox/CollisionShape2D.disabled = true
	$hitbox.set_collision_mask_value(1, false)
	$".".set_collision_mask_value(1, false)
	# Desactivar la física del nodo (si es necesario)
	set_physics_process(false)
	
	# Guardar la posición inicial
	var start_position = position
	var up_distance = 100  # Distancia que sube el personaje
	var fall_distance = 600  # Distancia que cae el personaje

	# Calcular las posiciones objetivo
	var up_position = start_position + Vector2(0, -up_distance)
	var down_position = start_position + Vector2(0, fall_distance)

	# Movimiento hacia arriba
	while position.y > up_position.y:
		position.y -= 5
		await get_tree().create_timer(0.01).timeout

	# Movimiento hacia abajo (fuera de la pantalla)
	while position.y < down_position.y:
		position.y += 8
		await get_tree().create_timer(0.01).timeout

	# Reactivar la física y las colisiones
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$hitbox/CollisionShape2D.disabled = false
	$hitbox.set_collision_mask_value(1, true)
	$".".set_collision_mask_value(1, true)
	

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
