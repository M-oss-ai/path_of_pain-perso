extends Area2D

@export var tp_location = Vector2(0, 0)


func _ready() -> void:
	tp_location.y -= 16


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.tp_location = tp_location
