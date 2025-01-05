extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GLOBAL.current_state = GLOBAL.PlayerState.THONG
		self.queue_free()
