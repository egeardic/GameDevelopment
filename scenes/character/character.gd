extends CharacterBody2D

const animation_offset: float = 8
const gravity: float = 2000

@export var health: int = 100
@export var mana: int = 100

@export var speed: int = 15
@export var dash_speed: int = 15
@export var jump_power: int = 1200

@export var damage: int = 10
@export var defence: int = 0

var is_alive: bool = true

var is_crouching: bool = false
var is_dashing: bool = false
var is_hurting: bool = false
var is_attacking: bool = false

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

signal death_signal(character: Node2D)

func _ready() -> void:
	sprite.offset.x = animation_offset
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

func _process(_delta: float) -> void:
	move_and_slide()
	if is_alive:
		if not check_movement():
			movement_with_animation()
		elif not is_on_floor():
			movement_without_animation()

func _input(event: InputEvent) -> void:
	if is_alive and is_on_floor():
		if event.is_action("jump"):
			jump()
		elif event.is_action("attack"):
			is_attacking = true
			attack_animation()

func _on_texture_button_pressed() -> void:
	attack()

func attack() -> void:
	if is_alive:
		self.health -= self.damage
		is_hurting = true
		sprite.play("hurt")
		if health <= 0:
			death()
		print(health)
	
func death() -> void:
	print("died")
	is_alive = false
	death_signal.emit(self)
	sprite.play("death")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation != "death":
		if sprite.animation == "hurt":
			is_hurting = false
		elif sprite.animation == "attack1" or sprite.animation == "attack2":
			is_attacking = false
		sprite.play("idle")

### MOVEMENT ###
func move_right() -> void:
	if sprite.flip_h:
		sprite.flip_h = false
	sprite.offset.x = animation_offset
	move_and_collide(Vector2(speed, 0))

func move_left() -> void:
	if not sprite.flip_h:
		sprite.flip_h = true
	sprite.offset.x = -animation_offset
	move_and_collide(Vector2(-speed, 0))

func dash_right() -> void:
	if sprite.flip_h:
		sprite.flip_h = false
	sprite.offset.x = animation_offset
	move_and_collide(Vector2(dash_speed, 0))

func dash_left() -> void:
	if not sprite.flip_h:
		sprite.flip_h = true
	sprite.offset.x = -animation_offset
	move_and_collide(Vector2(-dash_speed, 0))

func jump() -> void:
	velocity.y = -jump_power
	sprite.play("jump")

### ANIMATIONS ###
func move_animation() -> void:
	sprite.play("move_right")

func dash_animation() -> void:
	sprite.play("dash")

func crouch_animation() -> void:
	sprite.play("crouch")

func attack_animation() -> void:
	var version: int = randi()
	if version % 2 == 0:
		sprite.play("attack1")
	else:
		sprite.play("attack2")

func check_movement() -> bool:
	if not is_on_floor() or is_crouching or is_dashing or is_hurting or is_attacking:
		return true
	else:
		return false


func movement_with_animation() -> void:
	if Input.is_action_pressed("move_right"):
		if Input.is_action_pressed("dash"):
			dash_right()
			move_animation()
		else:
			move_right()
			move_animation()
	elif Input.is_action_pressed("move_left"):
		if Input.is_action_pressed("dash"):
			dash_left()
			move_animation()
		else:
			move_left()
			move_animation()
	elif Input.is_action_pressed("crouch"):
		crouch_animation()
	else:
		sprite.play("idle")

func movement_without_animation() -> void:
	if Input.is_action_pressed("move_right"):
		move_right()
	elif Input.is_action_pressed("move_left"):
		move_left()	
