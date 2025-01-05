extends Area2D

var velocity = Vector2(500, 0)
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("thong")
	animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	self.position += velocity * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.queue_free()
		queue_free()
