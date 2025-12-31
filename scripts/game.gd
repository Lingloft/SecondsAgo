"""
游戏主控制器
这个文件是游戏场景的"总指挥"，管理游戏运行时的所有逻辑。
主要功能：
1. 管理10秒循环计时器
2. 监听射击信号，生成子弹并记录数据
3. 每帧回放历史子弹
4. 循环结束时生成新敌人和幽灵玩家
5. 处理玩家死亡，通知主界面显示结束菜单
"""
extends Node2D

const BULLET_SCENE = preload("res://scenes/bullet.tscn") # 预加载子弹场景，用于实例化新子弹
const ENEMY_SCENE = preload("res://scenes/enemy.tscn") # 预加载敌人场景，用于实例化新敌人
const GHOST_SCENE = preload("res://scenes/ghost_player.tscn") # 预加载幽灵玩家场景，用于实例化幽灵

@export var timer: Timer # 循环计时器，在编辑器中指定
@onready var player: CharacterBody2D = $Player # 获取玩家节点，用于确定敌人生成位置

@warning_ignore("unused_signal")
signal die # 兼容场景中旧的信号连接，实际不使用

func _ready() -> void: # 节点进入场景树时调用
	timer.wait_time = Global.wait_time # 设置计时器时长为10秒
	timer.start() # 启动计时器
	spawn_enemy(0) # 生成第一个敌人
	EventBus.shoot.connect(_on_shoot) # 监听射击信号
	EventBus.player_death.connect(_on_player_death) # 监听玩家死亡信号

func _exit_tree() -> void: # 节点离开场景树时调用（场景被销毁时）
	if EventBus.shoot.is_connected(_on_shoot): # 检查信号是否已连接
		EventBus.shoot.disconnect(_on_shoot) # 断开射击信号，防止重玩时重复连接
	if EventBus.player_death.is_connected(_on_player_death): # 检查信号是否已连接
		EventBus.player_death.disconnect(_on_player_death) # 断开死亡信号

func _physics_process(_delta: float) -> void: # 每个物理帧调用
	Global.time = snappedf(timer.time_left, 0.01) # 更新全局时间为计时器剩余时间，保留两位小数
	_replay_bullets() # 回放历史子弹

func _replay_bullets() -> void: # 回放历史子弹
	if not Global.bullet_data.has(Global.time): return # 如果当前时间点没有子弹数据就跳过
	var data: Dictionary = Global.bullet_data[Global.time] # 获取该时间点的子弹数据
	_spawn_bullet(data["position"], data["direction"]) # 在记录的位置和方向生成子弹

func _on_shoot(pos: Vector2, dir: Vector2) -> void: # 收到射击信号时调用
	%ShootAudio.play() # 播放射击音效
	EventBus.camera_shake.emit() # 发送相机震动信号
	Global.bullet_data[Global.time] = {"position": pos, "direction": dir} # 记录子弹数据到全局，供下个循环回放
	_spawn_bullet(pos, dir) # 生成子弹

func _spawn_bullet(pos: Vector2, dir: Vector2) -> void: # 生成一颗子弹
	var bullet := BULLET_SCENE.instantiate() # 实例化子弹场景
	bullet.global_position = pos # 设置子弹位置
	bullet.direction = dir # 设置子弹飞行方向
	%Bullets.add_child(bullet) # 添加到子弹容器

func _on_player_death() -> void: # 收到玩家死亡信号时调用
	EventBus.camera_shake.emit() # 发送相机震动信号
	EventBus.game_over.emit() # 发送游戏结束信号，通知主界面

func _on_player_hit() -> void: pass # 兼容场景中旧的信号连接
func _on_player_shoot() -> void: pass # 兼容场景中旧的信号连接

func _on_timer_loop_timeout() -> void: # 计时器超时时调用（每10秒一次）
	fade_screen() # 播放屏幕闪白效果
	for c in ["Bullets", "Enemies"]: clear_entities(c) # 清除所有子弹和敌人
	for i in Global.enemy_data.size() + 1: spawn_enemy(i) # 生成敌人，数量等于历史循环数+1
	var ghost := GHOST_SCENE.instantiate() # 实例化幽灵玩家
	ghost.clone_id = Global.loop # 设置幽灵的循环ID，用于读取对应的历史数据
	%GhostPlayers.add_child(ghost) # 添加到幽灵容器
	Global.loop += 1 # 循环次数+1
	EventBus.loop_timeout.emit() # 发送循环超时信号，通知地图切换墙壁

func fade_screen() -> void: # 屏幕闪白效果
	var glow: float = 2 # 获取当前辉光强度
	$WorldEnvironment.environment.glow_intensity = 10 # 瞬间提高辉光强度（闪白）
	create_tween().tween_property($WorldEnvironment.environment, "glow_intensity", glow, 0.8) # 0.8秒内恢复原来的辉光强度

func clear_entities(container_name: String) -> void: # 清除指定容器中的所有实体
	for e in get_node("%" + container_name).get_children(): e.queue_free() # 遍历容器的所有子节点并删除

func spawn_enemy(id: int) -> void: # 生成一个敌人
	var enemy := ENEMY_SCENE.instantiate() # 实例化敌人场景
	enemy.clone_id = id # 设置敌人的循环ID
	enemy.global_position = player.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100)) # 在玩家附近随机位置生成
	%Enemies.add_child(enemy) # 添加到敌人容器
