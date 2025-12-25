extends Node2D

@export var ghost_player: CharacterBody2D
@export var timer: Timer

@onready var loop_label: Label = %LoopLabel
@onready var time_label: Label = %TimeLabel
@onready var camera: Camera2D = %Camera

func _ready():
	timer.wait_time = Global.wait_time
	timer.start()
	_spawn_enemy()

func _physics_process(_delta: float) -> void:
	# 更新游戏时间和UI
	Global.time = snappedf(timer.time_left, 0.01)
	loop_label.text = "LOOP: " + str(Global.loop)
	time_label.text = "TIME: " + str(snappedf(Global.time, 0.1))

	# 回放子弹
	if Global.bullet_data.has(Global.time):
		var data = Global.bullet_data[Global.time]
		var bullet_clone = $Bullet.duplicate()
		
		# 配置回放子弹
		bullet_clone.global_position = data["position"]
		bullet_clone.direction = data["direction"]
		bullet_clone.visible = true
		bullet_clone.is_clone = true
		
		%Bullets.add_child(bullet_clone)

func _on_timer_loop_timeout() -> void:
	# 循环结束处理
	_fade_screen()
	_clear_entities("Bullets")
	_clear_entities("Enemies")
	_spawn_enemies_and_ghosts()
	Global.loop += 1

func _on_player_hit() -> void:
	camera.shake_once()

func _fade_screen() -> void:
	# 屏幕过渡效果
	# 修改WorldEnvironment的glow_intensity值
	var glow_intensity = $WorldEnvironment.environment.glow_intensity
	$WorldEnvironment.environment.glow_intensity = 10
	create_tween().tween_property($WorldEnvironment.environment, "glow_intensity", glow_intensity, 0.8)

func _spawn_enemies_and_ghosts() -> void:
	# 生成敌人
	# 从enemy_data中获取敌人数据，根据loop克隆对应数量的敌人
	var enemy_count = Global.enemy_data.size()
	if enemy_count > 0:
		for enemy_id in range(enemy_count):
			var enemy_clone = $Enemy.duplicate()
			enemy_clone.is_clone = true
			enemy_clone.visible = true
			enemy_clone.clone_id = enemy_id
			var random = Vector2(randf_range(-100, 100),randf_range(-100, 100))
			enemy_clone.global_position = ghost_player.global_position + random
			# 随机位置（玩家附近）
			%Enemies.add_child(enemy_clone)

	# 生成幽灵玩家
	var ghost_clone = $GhostPlayer.duplicate()
	ghost_clone.is_clone = true
	ghost_clone.visible = true
	ghost_clone.clone_id = Global.loop
	%GhostPlayers.add_child(ghost_clone)

func _on_player_restart() -> void:
	# 重置游戏状态
	Global.loop = 1
	Global.player_data = {}
	Global.bullet_data = {}
	Global.enemy_data = {}
	
	# 清除所有实体
	for container in ["Enemies", "GhostPlayers", "Bullets"]:
		_clear_entities(container)
	
	# 淡入并重新加载场景
	get_tree().reload_current_scene()
	_fade_screen()
	
	$WorldEnvironment.environment.glow_intensity = 2.0

func _clear_entities(container_name: String) -> void:
	# 清除指定容器中的所有实体
	for entity in get_node("%" + container_name).get_children():
		entity.queue_free()

func _spawn_enemy() -> void:
	# 初始生成敌人
	var enemy_clone = $Enemy.duplicate()
	enemy_clone.is_clone = true
	enemy_clone.visible = true
	enemy_clone.clone_id = Global.loop
	
	# 随机位置（玩家附近）
	var random_pos = Vector2(
		randf_range(ghost_player.global_position.x - 100, ghost_player.global_position.x + 100),
		randf_range(ghost_player.global_position.y - 100, ghost_player.global_position.y + 100)
	)
	enemy_clone.global_position = random_pos
	
	%Enemies.add_child(enemy_clone)


func _on_player_shoot() -> void:
	# 播放射击音效
	%ShootAudio.play()
