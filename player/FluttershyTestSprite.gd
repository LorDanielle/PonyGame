extends KinematicBody2D

#перечисление состояний положение персонажа
enum States {
	ON_FLOOR,
	IN_AIR,
	ON_WALL
}

#Константы для физики
const WALK_SPEED = 250
const GRAVITY = 1000
const JUMP_FORCE = -100
const FLOOR = Vector2(0,-1)

#Переменные для передвижения и тд
var current_state
var velocity = Vector2()
var jump_cont = true
var second_jump = true
var jump_counter = 0
var jump_costyl = false
onready var playerImage = get_node("AnimatedFluttershy")

#Функция обновления состояния
func update_state():
	if is_on_floor():
		current_state = States.ON_FLOOR
	elif is_on_wall() and is_on_floor():
		current_state = States.ON_WALL
	elif is_on_wall() and !is_on_floor():
		current_state = States.ON_WALL
	else:
		current_state = States.IN_AIR

#Функция перемещения персонажа
func move():
	if Input.is_action_pressed("ui_right"):
		velocity.x += WALK_SPEED
		if current_state == States.ON_FLOOR:
			$AnimatedFluttershy.play("Walk")
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= WALK_SPEED
		if current_state == States.ON_FLOOR:
			$AnimatedFluttershy.play("Walk")
	else:
		if current_state == States.ON_FLOOR:
			$AnimatedFluttershy.play("Idle")

#Функция прыжка
func jump():
	if ((current_state == States.IN_AIR or current_state == States.ON_WALL) and second_jump == true) or current_state == States.ON_FLOOR:
		if Input.is_action_just_pressed("ui_up"):
			jump_costyl = true
			if jump_counter < 2:
				jump_cont = false
		elif Input.is_action_pressed("ui_up") and jump_costyl == true:
			if jump_cont == false:
				velocity.y += JUMP_FORCE
				if velocity.y <= -400:
					jump_cont = true
					jump_costyl = false
					if jump_counter >= 2:
						second_jump = false
		elif Input.is_action_just_released("ui_up"):
			jump_counter+=1
			jump_cont = true
			jump_costyl = false
			if jump_counter >= 2:
				second_jump = false

#Функция обрабатывающая движение
func _physics_process(delta):
	#Сопоставление допустимых функций для определенных состояний
	match(current_state):
		States.ON_FLOOR:
			second_jump = true
			jump_counter = 0
			move()
			jump()
		States.IN_AIR:
			move()
			jump()
			$AnimatedFluttershy.play("Jump")
		States.ON_WALL:
			move()
			jump()
	
	update_state()
	
	#Отвечает за поворот персонажа по горизонтали
	if velocity.x > 0:
		playerImage.flip_h = false
	elif velocity.x < 0:
		playerImage.flip_h = true
	
	velocity.y += GRAVITY * delta #Действие гравитации
	
	velocity = move_and_slide(velocity, FLOOR) #можно и без записи в velocity, 
	#но тогда персонаж будет резко слетать с платформ, а не плавно
	
	velocity.x = lerp(velocity.x, 0, 1)
