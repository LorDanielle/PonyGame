extends KinematicBody2D

#Константы для физики
const WALK_SPEED = 250
const GRAVITY = 1200
const JUMP_FORCE = -100
const FLOOR = Vector2(0,-1)

#Переменные для передвижения и тд
var velocity = Vector2()
var jumping = false
var Proverka = false
onready var playerImage = get_node("AnimatedFluttershy")

#Функция принимающая вводимые клавиши для движения
func get_input():
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += WALK_SPEED
		if is_on_floor():
			$AnimatedFluttershy.play("Walk")
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= WALK_SPEED
		if is_on_floor():
			$AnimatedFluttershy.play("Walk")
	else:
		if is_on_floor():
			$AnimatedFluttershy.play("Idle")
		
	if Proverka == false:
		if Input.is_action_pressed("ui_up"):
			jumping = true
			velocity.y += JUMP_FORCE
			$AnimatedFluttershy.play("Jump")
			if velocity.y <= -600:
				Proverka = true
		elif not is_on_floor(): #Для предотвращения возможности прыжка после падения с платформы 
			#(так как предыдущая функция позволяет совершить прыжок после падения с плафтормы, 
			#если ранее не была нажата клавиша прыжка)
			Proverka = true
		
#Функция обрабатывающая движение
func _physics_process(delta):
	get_input()
	
	#Отвечает за поворот персонажа по горизонтали
	if velocity.x > 0:
		playerImage.flip_h = false
	elif velocity.x < 0:
		playerImage.flip_h = true
	
	velocity.y += GRAVITY * delta #Действие гравитации
	
	if jumping and is_on_floor() and Proverka == true:
		jumping = false
		Proverka = false
		Input.action_release("ui_up")
	elif not jumping and is_on_floor() and Proverka == true:
		Proverka = false
		
	velocity = move_and_slide(velocity, FLOOR) #можно и без записи в velocity, 
	#но тогда персонаж будет резко слетать с платформ, а не плавно
	
	velocity.x = lerp(velocity.x, 0, 1)
