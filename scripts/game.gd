extends Node2D

# ==============================================================================================
# 文件功能：游戏主控制器
# 设计目标：管理游戏的整体流程和状态
# 核心逻辑：
#   1. 初始化游戏状态和UI
#   2. 更新游戏时间和UI显示
#   3. 处理10秒循环机制
#   4. 生成敌人和幽灵玩家
#   5. 回放历史子弹
#   6. 处理玩家死亡和游戏重启
# 模块间交互：
#   - 监听玩家、子弹等模块的信号
#   - 控制相机、计时器等节点
#   - 管理场景中的实体（敌人、幽灵玩家、子弹）
# 主要函数：
#   - spawn_enemy(): 生成单个敌人
#   - clear_entities(): 清除指定容器中的实体
#   - fade_screen(): 屏幕淡入淡出效果
# ==============================================================================================

# 导出属性
@export var ghost_player: CharacterBody2D  # 幽灵玩家模板
@export var timer: Timer  # 循环计时器

# 节点引用
@onready var loop_label: Label = %LoopLabel  # 循环次数标签
@onready var time_label: Label = %TimeLabel  # 时间标签
@onready var camera: Camera2D = %Camera  # 相机节点

func _ready() -> void:
	timer.wait_time = Global.wait_time  # 设置计时器时长为全局等待时间
	timer.start()  # 启动计时器
	spawn_enemy(0)  # 生成初始敌人

func _physics_process(_delta: float) -> void:
	# 更新游戏时间和UI
	Global.time = snappedf(timer.time_left, 0.01)  # 更新全局游戏时间
	loop_label.text = "LOOP: " + str(Global.loop)  # 更新循环次数显示
	time_label.text = "TIME: " + str(snappedf(Global.time, 0.1))  # 更新时间显示

	# 回放历史子弹
	if Global.bullet_data.has(Global.time):  # 检查当前时间是否有子弹数据
		var data: Dictionary = Global.bullet_data[Global.time]  # 获取子弹数据
		var bullet_clone: RigidBody2D = $Bullet.duplicate()  # 克隆子弹模板
		
		# 配置回放子弹
		bullet_clone.global_position = data["position"]  # 设置子弹位置
		bullet_clone.direction = data["direction"]  # 设置子弹方向
		bullet_clone.visible = true  # 设置可见
		bullet_clone.is_clone = true  # 标记为克隆子弹
		
		%Bullets.add_child(bullet_clone)  # 将子弹添加到场景

func _on_timer_loop_timeout() -> void:
	# 循环结束处理
	fade_screen()  # 播放屏幕过渡效果
	clear_entities("Bullets")  # 清除所有子弹
	clear_entities("Enemies")  # 清除所有敌人
	spawn_enemies_and_ghosts()  # 生成新的敌人和幽灵玩家
	Global.loop += 1  # 增加循环次数

func _on_player_hit() -> void:
	camera.shake_once()

func fade_screen() -> void:
	# 屏幕过渡效果（通过调整环境光强度实现）
	var glow_intensity: float = $WorldEnvironment.environment.glow_intensity  # 获取当前光强度
	$WorldEnvironment.environment.glow_intensity = 10  # 设置强光强度
	
	# 创建补间动画，0.8秒内恢复原光强度
	create_tween().tween_property($WorldEnvironment.environment, "glow_intensity", glow_intensity, 0.8)

func spawn_enemies_and_ghosts() -> void:
	# 生成敌人
	var enemy_count: int = Global.enemy_data.size() + 1  # 计算敌人生成数量
	print("enemy_count:", enemy_count)  # 打印敌人数
	
	# 循环生成敌人
	for enemy_id in range(enemy_count):
		spawn_enemy(enemy_id)  # 生成单个敌人

	# 生成幽灵玩家
	var ghost_clone: CharacterBody2D = $GhostPlayer.duplicate()  # 克隆幽灵玩家模板
	ghost_clone.is_clone = true  # 标记为克隆
	ghost_clone.visible = true  # 设置可见
	ghost_clone.clone_id = Global.loop  # 设置克隆ID
	%GhostPlayers.add_child(ghost_clone)  # 添加到幽灵玩家容器

func _on_player_restart() -> void:
	# 重置游戏全局状态
	Global.loop = 0  # 重置循环次数
	Global.player_data = {}  # 清空玩家数据
	Global.bullet_data = {}  # 清空子弹数据
	Global.enemy_data = {}  # 清空敌人数据
	
	# 清除所有实体
	for container in ["Enemies", "GhostPlayers", "Bullets"]:
		clear_entities(container)  # 清除指定容器中的实体
	
	# 重新加载场景
	get_tree().reload_current_scene()  # 重新加载当前场景
	fade_screen()  # 播放淡入效果
	
	# 设置环境光强度
	$WorldEnvironment.environment.glow_intensity = 2.0  # 设置初始光强度

func clear_entities(container_name: String) -> void:
	# 清除指定容器中的所有实体
	var container: Node = get_node("%" + container_name)  # 获取容器节点
	
	# 遍历并销毁所有子实体
	for entity in container.get_children():
		entity.queue_free()  # 释放实体资源

func spawn_enemy(id: int) -> void:
	# 生成单个敌人
	var enemy_clone: CharacterBody2D = $Enemy.duplicate()  # 克隆敌人模板
	enemy_clone.is_clone = true  # 标记为克隆
	enemy_clone.visible = true  # 设置可见
	enemy_clone.clone_id = id  # 设置克隆ID
	
	# 生成玩家附近的随机位置
	var random_pos: Vector2 = Vector2(
		randf_range(ghost_player.global_position.x - 100, ghost_player.global_position.x + 100),  # 随机X坐标
		randf_range(ghost_player.global_position.y - 100, ghost_player.global_position.y + 100)  # 随机Y坐标
	)
	
	enemy_clone.global_position = random_pos  # 设置敌人位置
	%Enemies.add_child(enemy_clone)  # 添加到敌人容器


func _on_player_shoot() -> void:
	# 播放射击音效
	%ShootAudio.play()  # 播放射击音效
