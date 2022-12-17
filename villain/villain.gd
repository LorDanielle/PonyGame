extends KinematicBody2D

var speed = 20
var stands = true
var destination = Vector2()
var velocity = Vector2()
onready var villain = get_node("villain")
func _ready():
	var speed = 20
	

func _process(delta):
	if velocity:
		move_and_slide(velocity)
		#position.x = clamp(position.x, 0, 1000)
		#position.y = clamp(position.y, 0, 1000)
		
	wander()

func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false
	
func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$Timer.start(2)

func wander():
	var pos = position
	if stands:
		#randomize()
		var x = int(rand_range(pos.x - 50, pos.x + 50))
		if pos.x + 50 - pos.x - 50 >= 0:
			villain.flip_h = false
		else:
			villain.flip_h = true
		var y = int(rand_range(pos.y, pos.y))
		
		
		x = clamp(x, 0, 10000)
		#y = clamp(y, 0, 10000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()


func _physics_process(delta):
	if "Fluttershy" in "villain":
		print('gi')

func _body_entered(body):
	if body.name=="Fluttershy":
		body.dead()

func _on_Timer_timeout():
	stands = true
	pass 
