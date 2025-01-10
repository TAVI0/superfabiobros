extends Area2D
func _ready():
	add_to_group("collectable")
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if GLOBAL.current_state == GLOBAL.PlayerState.SMALL:
			body.become_big()
		else:
			print("thong")
			body.got_thong()
		self.queue_free()
