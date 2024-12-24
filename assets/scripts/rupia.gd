extends Node2D

var is_collected = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_collected:
		is_collected= true
		$Area2D/AudioStreamPlayer2D.play()
		GLOBAL.total_coins+=1
		hide()
