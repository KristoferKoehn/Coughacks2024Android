extends Sprite2D


func _ready():
	var t = get_tree().create_tween()
	t.tween_property(self, "modulate:a", 0, 0.1)
	t.tween_callback(queue_free)
