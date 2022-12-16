extends Area2D
#var not_start

signal monetka
func _on_Area2D_body_entered(body):
	if body.name=="Fluttershy":
		#emit_signal("monetka")
		print("МОНЕТКА ЗАБРАНА")
		#$AudioStreamPlayer.play()
		#$Timer.start(0.3)
		#not_start=true
		emit_signal("monetka")
		queue_free()
		
			
		
		#Signal $Timer.timeout
		#var scene_tree_timer = get_tree().create_timer(4)
		#AudioStreamPlayer.PAUSE_MODE_STOP=false
		#print("МОНЕТКА ЗАБРАНА")
		#print(Timer)
		#if $Timer.is_stopped():
		#if $AudioStreamPlayer.finished():
			#pass	
		


#func _physics_process(delta):
		#print($Timer.get_time_left())
		#if not_start==true and $Timer.is_stopped ( ):
				
#func _on_Timer_timeout():
	#queue_free()
