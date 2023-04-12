extends CharacterBody2D
#перечисление состояний положения персонажа
enum States {
	ON_FLOOR,
	IN_AIR,
	ON_WALL
}
#Константы для физики
const AIR_RESISTANCE = 0.05
const JUMP_FORCE = -400
const JUMP_WALL_X = -400
const JUMP_WALL_Y = -400
const FLOOR = Vector2(0,-1)
const extraSlide = 1

#Переменные для передвижения и тд
var ACCELERATION = 500
var current_state
#var velocity = Vector2()
var second_jump = true
var wall_jump = true
var first_slide = true
var slide_count = 0
@onready var playerImage = get_node("AnimatedFluttershy")
var GRAVITY = 1000###Гравитаааация большая

var WALL_SLIDE_GRAVITY = 1000
var MAX_SPEED = 250
var can_slide = false
var can_dash = false
var MAX_FALL_SPEED = 500
var MAX_FALL_SPEED_WALL_SLIDE = 80
var dash_count = 0
var extra_dash = 1

var x_speed = 0
var y_speed = 0

#Переменные определяющие выполняемое действие
var is_sliding = false
var is_jumping = false
var is_doubleJumping = false
var is_wallsliding = false
var is_moving = false
var is_dashing = false
var is_walljumping = false

var is_dead=false
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
var pozition_dead=Vector2()
#Функция перемещения персонажа
func move(delta):
	if is_dead==true:
		self.position=pozition_dead
		if Input.is_action_pressed("ui_accept"):
			is_dead=false
			#set_physics_process(true)
			$DeadScrin.visible=false
			self.position=Vect_chek
	else:
		var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		if direction != 0:
			is_moving = true
			if $Timer2.is_stopped():
				x_speed += direction * ACCELERATION * delta
				x_speed = clamp(x_speed, -MAX_SPEED, MAX_SPEED)
		if direction == 0:
			is_moving = false
			if current_state == States.ON_FLOOR:
				if is_sliding:
					x_speed = lerp(x_speed, 0, 0.01)
				else:
					x_speed = lerp(x_speed, 0, 1)
			else:
				x_speed = lerp(x_speed, 0, AIR_RESISTANCE)

#Функция определяющая близость к стене
func nextToWall():
	return nextToRightWall() or nextToLeftWall()

#Функция определяющая близость к правой стене
func nextToRightWall():
	#playerImage.flip_h = true
	return ($RightWall.is_colliding() or $RightWall2.is_colliding())

#Функция определяющая близость к левой стене
func nextToLeftWall():
	#playerImage.flip_h = false
	return ($LeftWall.is_colliding() or $LeftWall2.is_colliding())

#Функция скольжения по стене
func wallslide():
	if nextToWall():
		if (nextToRightWall() and Input.is_action_pressed("ui_right")) or (nextToLeftWall() and Input.is_action_pressed("ui_left")):
			is_wallsliding = true
			$Timer.set_paused(false)
			if first_slide == true:
				$Timer.start()
				first_slide = false
		elif (nextToRightWall() and Input.is_action_just_pressed("ui_left")) or (nextToLeftWall() and Input.is_action_just_pressed("ui_right")):
			is_wallsliding = false
	else:
		is_wallsliding = false

#Таймер волл слайда
func _on_Timer_timeout():
	is_wallsliding = false
	$RightWall.enabled = false
	$RightWall2.enabled = false
	$LeftWall.enabled = false
	$LeftWall2.enabled = false

#Функция прыжка
func jump():
	if current_state == States.ON_FLOOR:
		if Input.is_action_just_pressed("ui_up") and !is_jumping:
			is_jumping = true
			y_speed = JUMP_FORCE
			second_jump = true

	elif current_state == States.IN_AIR and !is_wallsliding:
		if Input.is_action_just_pressed("ui_up") and second_jump == true:
			is_doubleJumping = true
			second_jump = false
			#$AnimatedFluttershy.play("DoubleJump")
			y_speed = JUMP_FORCE
		if Input.is_action_just_released("ui_up"):
			is_doubleJumping = false
			if y_speed < JUMP_FORCE/2:
				y_speed = JUMP_FORCE/2
	
	if is_wallsliding:
			is_doubleJumping = false

	if Input.is_action_just_pressed("ui_up") and wall_jump == true and is_wallsliding:
		is_walljumping = true
		wall_jump = false
		is_doubleJumping = false
		if nextToRightWall():
			x_speed = JUMP_WALL_X
			y_speed = JUMP_WALL_Y
		if nextToLeftWall():
			x_speed = -JUMP_WALL_X
			y_speed = JUMP_WALL_Y

	if Input.is_action_just_released("ui_up") and is_walljumping:
		is_walljumping = false
		if x_speed < JUMP_WALL_X/2:
			x_speed = JUMP_WALL_X/2

func nextToRoof():
	return ($roof.is_colliding() or $roof2.is_colliding())

#Проверка логики слайдов
func sliding_logic():
	if abs(x_speed) > MAX_SPEED - 1 and current_state == States.ON_FLOOR and !nextToWall():
		if !is_sliding:
			can_slide = true
		else:
			can_slide = false
	if can_slide and Input.is_action_just_pressed("ui_accept"):
		$Timer6.start()
		$roof.enabled = true
		$roof2.enabled = true
		is_sliding = true
		can_slide = false
	if $Timer6.is_stopped() and !nextToRoof():
		is_sliding = false
		$roof.enabled = false
		$roof2.enabled = false
	if is_sliding and current_state == States.ON_FLOOR:
		MAX_SPEED = 150
		#$AnimatedFluttershy.play("Slide")
	else:
		MAX_SPEED = 250
		is_sliding = false

func dash():
	if current_state == States.ON_FLOOR:
		dash_count = 0
	if current_state == States.IN_AIR:
		can_dash = true
	if can_dash and Input.is_action_just_pressed("ui_accept") and dash_count < extra_dash:
		dash_count+=1
		$Timer7.start()
		is_dashing = true
		is_doubleJumping = false
		can_dash = false
	if $Timer7.is_stopped():
		is_dashing = false
	if is_dashing and current_state == States.IN_AIR:
		MAX_SPEED = 400
		x_speed = 400 * sign(x_speed)
		GRAVITY = 400
	else:
		MAX_SPEED = 250
		is_dashing = false
		GRAVITY = 1000

func collision_shape_change():
	if $SlideShape.disabled == true and is_sliding:
		$SlideShape.disabled = false
		$CollisionShape2D.disabled = true
	elif $CollisionShape2D.disabled == true and !is_sliding:
		$SlideShape.disabled = true
		$CollisionShape2D.disabled = false

#Логика включения анимации для конкретных действий
func anim():
	if is_sliding:
		$AnimatedFluttershy.play("Slide")
	elif is_jumping:
		$AnimatedFluttershy.play("Jump")
	elif is_dashing:
		$AnimatedFluttershy.play("Dash")
	elif is_doubleJumping:
		$AnimatedFluttershy.play("DoubleJump")
	elif is_wallsliding:
		$AnimatedFluttershy.play("WallSlide")
	elif current_state == States.IN_AIR and !is_doubleJumping and !is_dashing:
		$AnimatedFluttershy.play("Jump")
	elif is_moving and current_state != States.IN_AIR:
		$AnimatedFluttershy.play("Walk")
	elif is_walljumping:
		$AnimatedFluttershy.play("Jump")
	elif current_state != States.IN_AIR:
		$AnimatedFluttershy.play("Idle")
func dead():
	#set_physics_process(false)
	
	is_dead=true
	pozition_dead=self.position
	print($DeadScrin)
	$DeadScrin.visible=true
	
	#velocity=Vector2(0,0)
	#velocity=velocity.move_toward((0,0),1000)
	#velocity=Vector2(0,0)
	#print($FluttershyAnimated.)
	#$FluttershyAnimated.position.y=746

	#velocity = move_and_slide(velocity)
var Vect_chek=Vector2(0,0)
func chekpoint():
	Vect_chek=self.position
	print("chekpoint")
#Функция обрабатывающая движение
func _physics_process(delta):

	#Сопоставление допустимых функций для определенных состояний
	
	match(current_state):
		States.ON_FLOOR:
			is_wallsliding = false
			is_walljumping = false
			is_jumping = false
			wall_jump = true
			first_slide = true
			second_jump = true
			$RightWall.enabled = true
			$RightWall2.enabled = true
			$LeftWall.enabled = true
			$LeftWall2.enabled = true
			move(delta)
			jump()
		States.IN_AIR:
			$Timer.set_paused(true)
			move(delta)
			jump()
			wallslide()
		States.ON_WALL:
			move(delta)
			jump()
			wallslide()
	if nextToWall() == false:
		#Отвечает за поворот персонажа по горизонтали
		if x_speed > 0:
			playerImage.flip_h = false
		elif x_speed < 0:
			playerImage.flip_h = true

	#print(is_jumping, " jumping")
	#print(is_doubleJumping, " Doublejumping")
	#print(is_moving, " Moving")
	#print(is_wallsliding, " Wallsliding")
	#print(is_sliding, " sliding")
	#print(is_walljumping, " Walljumping")
	#print(is_dashing, " dashing")
	
	
	anim()
	
	update_state()
	sliding_logic()
	dash()
	collision_shape_change()
	
	if is_on_ceiling():
		y_speed = 10
	
	if !is_wallsliding:
		y_speed += GRAVITY * delta #Действие гравитации
		y_speed = min(y_speed, MAX_FALL_SPEED)
	else:
		y_speed += WALL_SLIDE_GRAVITY * delta #Действие гравитации
		y_speed = min(y_speed, MAX_FALL_SPEED_WALL_SLIDE)
		
	velocity.x = x_speed
	velocity.y = y_speed
	
	set_velocity(velocity)
	set_up_direction(FLOOR)
	move_and_slide()
	velocity = velocity #можно и без записи в velocity, 
	#но тогда персонаж будет резко слетать с платформ, а не плавно



func _on__monetka():
	#$звук_монетки.play()
	pass


func _on_coin_monetka():
	$AudioStreamPlayer.play()
