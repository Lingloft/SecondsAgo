extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

var fire_rate: float = 1.0
var shoot_cooldown: float = 0.0
var dead: bool = false

func _ready() -> void:
	animation.play("show")
	await animation.animation_finished
	animation.play("idle")

func _physics_process(delta: float) -> void:
	if dead or animation.animation == "show": return
	
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(dir * speed, (acceleration if dir else friction) * delta)
	
	animation.play("move" if velocity.length() > 0.1 else "idle")
	animation.flip_h = get_global_mouse_position().x < global_position.x
	
	shoot_cooldown += delta
	if Input.is_action_just_pressed("shoot") and shoot_cooldown >= fire_rate:
		shoot_cooldown = 0.0
		EventBus.shoot.emit(global_position, (get_global_mouse_position() - global_position).normalized())
	
	Global.player_data.get_or_add(Global.loop, {})[Global.time] = {
		"position": global_position, "animation": animation.animation, "flip_h": animation.flip_h
	}
	
	move_and_slide()
	if velocity.length() > 0.1: _spawn_dust()

func _spawn_dust() -> void:
	var dust_files: Array = Array(DirAccess.get_files_at("res://assets/sprites/player/dust/")).filter(func(f): return f.ends_with(".png"))
	if dust_files.is_empty(): return
	
	var dust := Sprite2D.new()
	dust.texture = load("res://assets/sprites/player/dust/" + dust_files.pick_random())
	dust.global_position = global_position + Vector2(randf_range(-5, 5), 3)
	dust.scale = Vector2(0.05, 0.05)
	%Dust.add_child(dust)
	
	create_tween().tween_property(dust, "modulate:a", 0, 0.5).finished.connect(dust.queue_free)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead: return
	if (area.name == "EnemyArea" and area.get_parent().animation.animation != "warn") or \
	   (area.name == "BulletArea" and area.get_parent().birth_time > 0.2):
		dead = true
		%HurtAudio.play()
		animation.play("death")
		EventBus.player_death.emit()
