extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if GLOBAL.current_state == GLOBAL.PlayerState.SMALL:
			body.become_big()
		else:
			body.got_thong()
		self.queue_free()
