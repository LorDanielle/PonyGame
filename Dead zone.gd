extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _physics_process(delta):
	if "Fluttershy" in "Пики":
		print('gi')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Dead_zone_area_entered(area):
	print('go')
	pass # Replace with function body.


func _on_Dead_zone_body_entered(body):
	if body.name=="Fluttershy":
		body.dead()
