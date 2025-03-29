extends Area2D
var direction = Vector2.ZERO
var speed = 700

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta


func _on_body_entered(body):
	if body.is_in_group("World"):
		self.queue_free()
	elif body.is_in_group("enemies") or body.is_in_group("speeders"):
		if body.alive:
			body.die()
			self.queue_free()
			
