extends KinematicBody2D

#перечисление состояний положение персонажа
enum States {
	ON_FLOOR,
	IN_AIR,
	ON_WALL
}

#Константы для физики
#const MAX_SPEED = 250
const ACCELERATION = 500
const AIR_RESISTANCE = 0.02
#const GRAVITY = 1000
const JUMP_FORCE = -400
const JUMP_WALL_X = -300
const JUMP_WALL_Y = -400
const FLOOR = Vector2(0,-1)
const extraSlide = 1

#Переменные для передвижения и тд
var current_state
var velocity = Vector2()
var second_jump = true
var wall_jump = true
var jump_counter = 0
var first_slide = true
var jump_costyl = false
var jump_costyl2 = false
var slide_count = 0
onready var playerImage = get_node("AnimatedFluttershy")
var GRAVITY = 1000
var MAX_SPEED = 250

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
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if direction != 0:
			
		if $Timer2.is_stopped():
			velocity.x += direction * ACCELERATION
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		if current_state == States.ON_FLOOR:
			$AnimatedFluttershy.play("Walk")
	if direction == 0:
		if current_state == States.ON_FLOOR:
			$AnimatedFluttershy.play("Idle")
			velocity.x = lerp(velocity.x, 0, 0.3)
		else:
			velocity.x = lerp(velocity.x, 0, AIR_RESISTANCE)

#Функция определяющая близость к стене
func nextToWall():
	return nextToRightWall() or nextToLeftWall()

#Функция определяющая близость к правой стене
func nextToRightWall():
	#playerImage.flip_h = true
	if Input.is_action_just_pressed("ui_left"):
				$Timer5.start()
	return $RightWall.is_colliding()
	
#Функция определяющая близость к левой стене
func nextToLeftWall():
	#playerImage.flip_h = false
	if Input.is_action_just_pressed("ui_right"):
				$Timer5.start()
	return $LeftWall.is_colliding()
	
#Функция скольжения по стене
func wallslide():
	if nextToWall():
		$AnimatedFluttershy.play("WallSlide")
		$Timer.set_paused(false)
		if first_slide == true:
			$Timer.start()
			first_slide = false
		
		if nextToWall() and velocity.y > 50:
			velocity.y = 50

#Таймер волл слайда
func _on_Timer_timeout():
	$RightWall.enabled = false
	$LeftWall.enabled = false
	$AnimatedFluttershy.play("Jump")
	
#Таймер анимации после волл джампа
func _on_Timer5_timeout():
	$AnimatedFluttershy.play("Jump")
#Функция прыжка
func jump():
	if current_state == States.ON_FLOOR:
		if Input.is_action_just_pressed("ui_up"):
			$Timer5.start()
			jump_costyl = true
			velocity.y = JUMP_FORCE
	elif nextToWall() and wall_jump == true:
		if Input.is_action_just_pressed("ui_up"):
			$Timer5.start()
			jump_costyl2 = true
			$Timer2.start()
			wall_jump = false
			if nextToRightWall():
				velocity.x = JUMP_WALL_X
				velocity.y = JUMP_WALL_Y
			if nextToLeftWall():
				velocity.x = -JUMP_WALL_X
				velocity.y = JUMP_WALL_Y
	elif current_state == States.IN_AIR and nextToWall() == false and second_jump == true:
		if Input.is_action_just_pressed("ui_up"):
			if jump_counter > 0:
				$AnimatedFluttershy.play("DoubleJump")
			velocity.y = JUMP_FORCE
			jump_costyl = true
		if Input.is_action_just_released("ui_up") and jump_costyl == true:
			jump_costyl = false
			jump_counter+=1
			if jump_counter >1:
				second_jump = false
			if velocity.y < JUMP_FORCE/2:
				velocity.y = JUMP_FORCE/2
	if Input.is_action_just_released("ui_up") and jump_costyl2 == true:
		jump_costyl2 = false
		if velocity.x < JUMP_WALL_X/2:
			velocity.x = JUMP_WALL_X/2
			
#Функция скольжения
func slide():
	MAX_SPEED = 350
	GRAVITY = 700
	$Timer3.start()
	$Timer4.start()
	
func _on_Timer3_timeout():
	MAX_SPEED = 250

func _on_Timer4_timeout():
	GRAVITY = 1000
	slide_count = 0
	
#Функция обрабатывающая движение
func _physics_process(delta):
	#Сопоставление допустимых функций для определенных состояний
	match(current_state):
		States.ON_FLOOR:
			
			if Input.is_action_just_pressed("ui_accept") and slide_count < extraSlide:
				slide()
				slide_count+=1
				
			wall_jump = true
			jump_counter = 0
			first_slide = true
			second_jump = true
			$RightWall.enabled = true
			$LeftWall.enabled = true
			move()
			jump()
		States.IN_AIR:
			$Timer.set_paused(true)
			move()
			jump()
			wallslide()
		States.ON_WALL:
			move()
			jump()
			wallslide()
	if nextToWall() == false:
		#Отвечает за поворот персонажа по горизонтали
		if velocity.x > 0:
			playerImage.flip_h = false
		elif velocity.x < 0:
			playerImage.flip_h = true
		
	update_state()
	
	velocity.y += GRAVITY * delta #Действие гравитации
	
	velocity = move_and_slide(velocity, FLOOR) #можно и без записи в velocity, 
	#но тогда персонаж будет резко слетать с платформ, а не плавно
