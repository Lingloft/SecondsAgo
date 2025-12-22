extends Node2D

@export var ghostp_player: CharacterBody2D
# 获取timer节点的时间
@export var timer: Timer

@onready var loop_label: Label = $LoopLabel
@onready var camera: Camera2D = %Camera

func _ready():
	timer.wait_time = Global.wait_time
	timer.start()
	clone_enemy()

func _physics_process(_delta: float) -> void:
	Global.time = snappedf(timer.time_left, 0.01)
	loop_label.text = "LOOP: " + str(Global.loop) + " TIME: " + str(Global.time)

	# 如果bullet_data里存在当前time的键
	if Global.bullet_data.has(Global.time):
		# 获取当前时间的子弹数据
		var bullet_data = Global.bullet_data[Global.time]
		# 创建子弹
		var bullet_clone = $Bullet.duplicate()
		# 设置位置
		bullet_clone.global_position = bullet_data["position"]
		# 设置方向
		bullet_clone.direction = bullet_data["direction"]
		bullet_clone.visible = true
		bullet_clone.is_clone = true
		%Bullets.add_child(bullet_clone)

		
		
func _on_timer_loop_timeout() -> void:
	ScreenFade()
	# 删除所有子弹
	for child in %Bullets.get_children(): child.queue_free()
	clone()

	# 进入下一循环
	Global.loop += 1
	


func _on_player_hit() -> void:
	# 相机震动
	camera.shake_once()


# 屏幕遮罩刷新，用CanvasModulate
func ScreenFade() -> void:
	# 记录当前color
	var current_color = $CanvasModulate.color
	# 设置color为全白
	$CanvasModulate.color = Color(1, 1, 1, 1)
	create_tween().tween_property($CanvasModulate, "color", current_color, 0.5)


func clone() -> void:
	clone_enemy()
	clone_ghost_player()
	
func clone_ghost_player() -> void:	
	# 克隆幽灵玩家
	var ghostp = $GhostPlayer.duplicate()
	# 设置为克隆体
	ghostp.is_clone = true
	# 设置可见
	ghostp.visible = true
	# 设置位置
	ghostp.clone_id = Global.loop
	%GhostPlayers.add_child(ghostp)

func clone_enemy() -> void:
	# 克隆敌人
	var enemy_clone = $Enemy.duplicate()
	enemy_clone.is_clone = true
	enemy_clone.visible = true
	enemy_clone.clone_id = Global.loop
	# 设置初始位置为玩家附近随机位置
	var random_pos = Vector2(
		randf_range(ghostp_player.global_position.x - 100, ghostp_player.global_position.x + 100),
		randf_range(ghostp_player.global_position.y - 100, ghostp_player.global_position.y + 100)
	)
	enemy_clone.global_position = random_pos
	
	%Enemies.add_child(enemy_clone)

# 重启游戏
func restart_game() -> void:
	# 重置循环
	Global.loop = 1
	# 重置玩家数据
	Global.player_data = {}
	# 重置子弹数据
	Global.bullet_data = {}
	# 重置敌人数据
	Global.enemy_data = {}
	# 重置敌人
	for child in %Enemies.get_children(): child.queue_free()
	# 重置幽灵玩家
	for child in %GhostPlayers.get_children(): child.queue_free()
	# 重置所有子弹
	for child in %Bullets.get_children(): child.queue_free()
	# 重新开始游戏
	ScreenFade()
	get_tree().reload_current_scene()

func _on_player_restart() -> void:
	restart_game()
