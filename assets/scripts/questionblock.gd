extends Area2D

enum STATE { UNBUPED, BUMPED }
var state: int = STATE.UNBUPED
var original_position: Vector2

func _ready() -> void:
	original_position=position

func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and state == STATE.UNBUPED:
		bump_block()

func bump_block():
	state = STATE.BUMPED
	$Sprite2D.frame=1
	
	match GLOBAL.current_state:
		GLOBAL.PlayerState.SMALL:
			GLOBAL.spawn_beer_bottle(self.global_position + Vector2(0,-30))
		GLOBAL.PlayerState.BIG, GLOBAL.PlayerState.THONG:
			GLOBAL.spawn_thong_power_up(self.global_position + Vector2(0,-30))
	
	bump_upwards()
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	return_to_original_position()
	
func bump_upwards():
	position.y -= 10

func return_to_original_position():
	position = original_position
