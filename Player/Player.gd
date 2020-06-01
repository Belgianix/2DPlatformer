extends KinematicBody2D

const TARGET_FPS = 60

export var GRAVITY = 6
export var MAX_SPEED = 110
export var ACCELERATION = 10
export var FRICTION = 15
export var AIR_RESISTANCE = 1.5
export var JUMP_FORCE = 150
export var WALL_JUMP_FORCE = 120
export var WALL_JUMP_ACCELERATION = 55
export var dash_velocity = 200
export var dash_factor = 1
export var MAX_DASH_SPEED = 250
export var SLIDE_FRICTION = 0.85
export var crouch_speed_reduction = 1
export var stamina = 3

var velocity = Vector2.ZERO
var dashing = false
var can_jump = true
var jump_was_pressed = false
var can_dash = true
var dash_cooldown_over = true
var is_sliding = false

onready var sprite = $Sprite
onready var collisionShape = $CollisionShape2D

signal stamina_changed(stamina)
signal stamina_refilled(stamina)

func _physics_process(delta: float) -> void:
	var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_move(x_input, delta)
	_jump(x_input, delta)
	_wall_jump(delta)
	_wall_slide(delta)
	_dash(x_input)
	_crouch_n_slide(x_input)

	velocity = move_and_slide(velocity, Vector2.UP)

func _move(x_input,delta):
	if x_input != 0:
		if is_sliding:
			velocity.x = lerp(velocity.x, 0, SLIDE_FRICTION * delta)
		else:
			velocity.x += x_input * ACCELERATION * delta * TARGET_FPS * dash_factor

		if dashing:
			velocity.x = clamp(velocity.x, -MAX_DASH_SPEED, MAX_DASH_SPEED)
		else:
			velocity.x = clamp(velocity.x, -MAX_SPEED * crouch_speed_reduction, MAX_SPEED * crouch_speed_reduction)
		sprite.flip_h = x_input < 0
		
	if is_on_floor() and x_input == 0:
			velocity.x = lerp(velocity.x, 0, FRICTION * delta)

func _jump(x_input, delta):
			
	if Input.is_action_just_pressed("jump"):
		jump_was_pressed = true
		remember_jump_time()
		if can_jump:
			velocity.y = -JUMP_FORCE

	else:
		if x_input == 0 and not dashing:
			velocity.x = lerp(velocity.x, 0, AIR_RESISTANCE * delta)
	if is_on_floor() or is_next_to_wall():
		can_dash = true
	if is_on_floor():
		stamina = 3
		emit_signal("stamina_refilled", stamina)
		can_jump = true
		if jump_was_pressed:
			velocity.y = -JUMP_FORCE

	if not is_on_floor() and not is_next_to_wall():
		coyote_time()

func _gravity(delta):
	if not dashing:
		velocity.y += GRAVITY * delta * TARGET_FPS

func _wall_jump(delta):
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		if is_next_to_right_wall() and stamina > 0:
			velocity = lerp(velocity, Vector2(-WALL_JUMP_FORCE, -WALL_JUMP_FORCE -50), WALL_JUMP_ACCELERATION * delta)
			sprite.flip_h = true

		if is_next_to_left_wall() and stamina > 0:
			velocity = lerp(velocity, Vector2(WALL_JUMP_FORCE, -WALL_JUMP_FORCE -50), WALL_JUMP_ACCELERATION * delta)
			sprite.flip_h = false
			
		if is_next_to_wall():
			stamina -= 1
			emit_signal("stamina_changed", stamina)

func _wall_slide(delta):
	if is_next_to_wall() and velocity.y >= 0:
		velocity.y = lerp(velocity.y, 50, 0.1)

	else:
		_gravity(delta)

func _dash(x_input):
	if Input.is_action_pressed("dash") and can_dash:
		if x_input != 0 and dash_cooldown_over:
			dash_cooldown()
			can_dash = false
			dash_factor = 5
			velocity.y = 0
			dashing = true
			yield(get_tree().create_timer(0.2),"timeout")
			dash_factor = 1
			velocity.y = 0
			dashing = false

func _crouch_n_slide(x_input):
	if Input.is_action_pressed("crouch") and is_on_floor():
		collisionShape.get_shape().set_extents(Vector2(3.113,5))
		collisionShape.set_position(Vector2(0,2.75))
		if x_input != 0:
			if -90 > velocity.x or velocity.x > 90:
				is_sliding = true
		else:
			crouch_speed_reduction = 0.5
				
	else:
		crouch_speed_reduction = 1
		is_sliding = false
		collisionShape.get_shape().set_extents(Vector2(3.113,7.755))
		collisionShape.set_position(Vector2(0,0))
	
	if -20 < velocity.x and velocity.x < 20:
		is_sliding = false

func coyote_time():
	yield(get_tree().create_timer(0.1), "timeout")
	can_jump = false

func remember_jump_time():
	yield(get_tree().create_timer(0.1), "timeout")
	jump_was_pressed = false

func dash_cooldown():
	dash_cooldown_over = false
	yield(get_tree().create_timer(0.5), "timeout")
	dash_cooldown_over = true

func is_next_to_right_wall():
	return $RayCastTopRight.is_colliding() or $RayCastBottomRight.is_colliding()
	
func is_next_to_left_wall():
	return $RayCastTopLeft.is_colliding() or $RayCastBottomLeft.is_colliding()
	
func is_next_to_wall():
	return is_next_to_left_wall() or is_next_to_right_wall()
