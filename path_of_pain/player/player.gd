extends CharacterBody2D


const SPEED = 300.0
const DASH_SPEED = 600.0
const CRISTAL_DASH_SPEED = 1200

const JUMP_VELOCITY = -500.0
const DOUBLE_JUMP_VELOCITY = -500.0
const WALL_JUMP_VELOCITY = -500.0
const WALL_SLIDE_VELOCITY = 350

const DASH_DURATION = 0.3
const DASH_COOLDOWN_DURATION = 0.17
const WALL_FIXE_DURATION = 0.1
const WALL_JUMP_DURATION = 0.13
const CHARGE_CRISTAL_DASH_DURATION = 1.5

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var wall_fixe_timer = 0.0
var wall_jump_timer = 0.0
var charge_crystal_dash_timer = 0.0

var can_double_jump = true
var can_dash = true

var is_dashing = false
var is_in_dash_cooldown = false
var is_wall_fixed = false
var is_wall_sliding = false
var hase_quitte_wall = true
var is_wall_jumping = false
var is_charging_crystal_dash = false
var is_cristal_dashing = false

var wall_direction = 0.0
var last_direction = 1.0

var tp_location = Vector2(0, 0)

signal double_jump_signal

func _physics_process(delta: float) -> void:
	
	gravity(delta)
	
	move()
	
	look_at_wall()
	
	if Input.is_action_just_pressed("jump") and not is_charging_crystal_dash and not is_cristal_dashing:
		if is_on_floor() and not is_dashing:
			jump()
			
		elif is_on_wall():
			wall_jump()
			
		elif can_double_jump and not is_dashing:
			double_jump()
	
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and not is_in_dash_cooldown and not is_charging_crystal_dash and not is_cristal_dashing:
		dash()
	
	if Input.is_action_just_pressed("cristal dash") and (is_on_wall() or is_on_floor()) and not is_dashing:
		charge_crystal_dash()
		
	if Input.is_action_just_released("cristal dash") and is_charging_crystal_dash:
		end_charge_crystal_dash()
	
	if (Input.is_action_just_pressed("cristal dash") or Input.is_action_just_pressed("jump")) and is_cristal_dashing:
		end_cristal_dash()
	
	
	if is_wall_fixed:
		process_wall_fixe(delta)
		
	if is_dashing:
		process_dash(delta)
		
	elif is_in_dash_cooldown:
		dash_cooldown(delta)
	
	if is_wall_jumping:
		process_wall_jump(delta)
	
	if is_charging_crystal_dash:
		process_charge_crystal_dash(delta)
		
	move_and_slide()

func gravity(delta):
	# Add the gravity.
	if is_on_floor():
		can_double_jump = true
		can_dash = true
	elif is_dashing or is_wall_fixed or is_charging_crystal_dash or is_cristal_dashing:
		velocity.y = 0
	elif is_wall_sliding:
		velocity.y += WALL_SLIDE_VELOCITY * delta
	else:
		velocity += get_gravity() * delta

func move():
	var direction := Input.get_axis("left", "right")
	if is_wall_jumping:
		direction = last_direction
		
	if is_cristal_dashing:
		velocity.x = DASH_SPEED * last_direction
		
	elif is_charging_crystal_dash:
			velocity.x = 0
			
	elif not is_dashing:
		if direction:
			last_direction = direction
			velocity.x = SPEED * direction
		else:
			velocity.x = 0

func look_at_wall():
	if is_on_wall():
		if is_dashing and wall_direction != last_direction:
			end_dash()
			is_in_dash_cooldown = true
			dash_cooldown_timer = DASH_COOLDOWN_DURATION
		
		if is_cristal_dashing and wall_direction != last_direction:
			end_cristal_dash()
				
		if not is_on_floor():
			wall_direction = sign(get_wall_normal().x)
				
			last_direction = wall_direction
			can_double_jump = true
			can_dash = true
				
			if velocity.y >= 0 and not is_wall_fixed and not is_wall_sliding and hase_quitte_wall:
				hase_quitte_wall = false
				is_wall_fixed = true
				wall_fixe_timer = WALL_FIXE_DURATION
				
			elif velocity.y < 0:
				is_wall_sliding = false
				is_wall_fixed = false
				hase_quitte_wall = true
	else:
		wall_direction = 0.0
		is_wall_sliding = false
		is_wall_fixed = false
		hase_quitte_wall = true

func process_wall_fixe(delta):
	wall_fixe_timer -= delta
	
	if wall_fixe_timer <= 0:
		is_wall_fixed = false
		is_wall_sliding = true

func jump():
	velocity.y = JUMP_VELOCITY
	
	
func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	can_double_jump = false
	emit_signal("double_jump_signal")
	
func wall_jump():
	velocity.y = WALL_JUMP_VELOCITY
	is_wall_sliding = false
	is_wall_fixed = false
	hase_quitte_wall = true
	is_wall_jumping = true
	wall_jump_timer = WALL_JUMP_DURATION

func process_wall_jump(delta):
	wall_jump_timer -= delta
	
	if wall_jump_timer <= 0:
		last_direction = -last_direction
		is_wall_jumping = false

func dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	
	if not is_on_floor() and not is_on_wall():
		can_dash = false

func process_dash(delta):
	dash_timer -= delta
	velocity.x = DASH_SPEED * last_direction
	
	if dash_timer <= 0:
		end_dash()
		is_in_dash_cooldown = true
		dash_cooldown_timer = DASH_COOLDOWN_DURATION

func dash_cooldown(delta):
	dash_cooldown_timer -= delta
	
	if dash_cooldown_timer <= 0:
		end_dash_couldown()
		
func end_dash():
	is_dashing = false

func end_dash_couldown():
	is_in_dash_cooldown = false
	
func charge_crystal_dash():
	is_charging_crystal_dash = true
	charge_crystal_dash_timer = CHARGE_CRISTAL_DASH_DURATION

func process_charge_crystal_dash(delta):
	charge_crystal_dash_timer -= delta
	
	if charge_crystal_dash_timer <= 0:
		end_charge_crystal_dash()
		is_cristal_dashing = true

func end_charge_crystal_dash():
	is_charging_crystal_dash = false

func end_cristal_dash():
	is_cristal_dashing = false
