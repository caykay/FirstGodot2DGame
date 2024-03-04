extends Area2D

signal hit # signal that handles being hit by the enemy

@export var speed = 400 # speed in pixes/sec
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if velocity.length() > 0:
		# if diagonal the speed would be higher than if it just moved horizontally or vertically only
		# so normalizing the velocity vector ensures it moves by 1 unit length
		velocity = velocity.normalized() * speed

	# update animation
	update_animation(velocity)
		
	position += velocity * delta
	# ensure player is within viewport bounds (game window viewport)
	position = position.clamp(Vector2.ZERO, screen_size)


func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func update_animation(velocity: Vector2):
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y !=0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		$AnimatedSprite2D.flip_h = false
	else:
		# stop the animation if we dont have any movement
		$AnimatedSprite2D.stop()
		return
	# play the animation
	$AnimatedSprite2D.play()


func _on_body_entered(body):
	hide() # player dies
	hit.emit() # notify observers, or basically whatever's connected to hit signal
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)	
