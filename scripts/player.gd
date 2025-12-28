extends CharacterBody2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0
@export var bullet: RigidBody2D
@export var fire_rate: float = 1.0

var shoot_cooldown: float = 1.0
var is_dead: bool = false

signal hit
signal restart
signal shoot

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	_update_movement(delta)
	_update_animation()
	_update_shooting(delta)
	_record_data()
	
	move_and_slide()
	create_dust()

func _update_movement(delta: float) -> void:
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity = move_direction * speed
	
	# 处理加速度和摩擦力
	velocity.x = move_toward(velocity.x, target_velocity.x, (acceleration if move_direction.x != 0 else friction) * delta)
	velocity.y = move_toward(velocity.y, target_velocity.y, (acceleration if move_direction.y != 0 else friction) * delta)

func _update_animation() -> void:
	var is_moving = velocity.length() > 0.1
	animation.play("move" if is_moving else "idle")
	animation.flip_h = get_global_mouse_position().x < global_position.x

func _update_shooting(delta: float) -> void:
	shoot_cooldown += delta
	
	if Input.is_action_just_pressed("shoot") and shoot_cooldown >= fire_rate:
		shoot.emit()
		# 创建并配置子弹
		var bullet_clone = bullet.duplicate()
		bullet_clone.is_clone = true
		bullet_clone.visible = true
		bullet_clone.global_position = global_position
		
		# 设置射击方向
		var shoot_dir = (get_global_mouse_position() - global_position).normalized()
		bullet_clone.direction = shoot_dir
		
		# 添加到子弹容器
		# await get_tree().create_timer(0.2).timeout
		%Bullets.add_child(bullet_clone)
		
		shoot_cooldown = 0.0
		
		# 记录子弹数据
		Global.bullet_data[Global.time] = {
			"position": bullet_clone.global_position,
			"direction": bullet_clone.direction
		}

func _record_data() -> void:
	# 确保玩家数据结构存在
	if not Global.player_data.has(Global.loop):
		Global.player_data[Global.loop] = {}
	
	# 记录玩家当前状态
	Global.player_data[Global.loop][Global.time] = {
		"position": global_position,
		"animation": animation.animation,
		"flip_h": animation.flip_h
	}

# 角色移动的时候创建脚步烟尘，通过随机在角色脚底创建一个小的烟雾贴图，在dust文件夹里随机选择一个
func create_dust() -> void:
	# 如果角色正在移动，才创建烟雾
	if velocity.length() > 0.1:
		var dust_path = "res://assets/sprites/player/dust/"
		var dir = DirAccess.open(dust_path)
		if dir:
			var dust_files = dir.get_files()
			if dust_files.size() > 0:
				# 创建Sprite2D节点
				var dust_sprite = Sprite2D.new()
				# 随机选择贴图
				var random_dust = dust_files[randi() % dust_files.size()]
				# 只要.png文件，如果是其他文件，跳过
				if not random_dust.ends_with(".png"):
					return
				
				dust_sprite.texture = load(dust_path + random_dust)
				dust_sprite.global_position = global_position + Vector2(randf_range(-5, 5), 3)
				# 缩小
				dust_sprite.scale = Vector2(0.05, 0.05)
				%Dust.add_child(dust_sprite)
				
				# 可选：添加烟雾消失效果
				var tween = create_tween()
				tween.tween_property(dust_sprite, "modulate:a", 0, 0.5)
				tween.tween_callback(dust_sprite.queue_free)


func _on_area_2d_area_entered(area: Area2D) -> void:
	# 检查是否是敌人区域或者子弹区域
	if not is_dead:
		if area.name == "EnemyArea":
			death()
		# 检查是否是子弹区域
		elif area.name == "BulletArea":
			if area.get_parent().birth_time > 0.2 and area.get_parent().is_clone:
				hit.emit()
				death()

func death() -> void:
	print("player death")
	%HurtAudio.play()
	is_dead = true
	animation.play("death")
	# 等待后触发重启信号
	await get_tree().create_timer(0.5).timeout
	restart.emit()
