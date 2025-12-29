extends CharacterBody2D

# ==============================================================================================
# 文件功能：玩家控制模块
# 设计目标：实现玩家的移动、射击、动画和数据记录
# 核心逻辑：
#   1. 玩家通过输入控制角色移动
#   2. 玩家点击鼠标发射子弹
#   3. 玩家移动时播放动画和生成灰尘效果
#   4. 玩家状态记录到全局数据中
#   5. 玩家碰撞到敌人或子弹时死亡
# 模块间交互：
#   - 发送hit和shoot信号给其他模块
#   - 从全局数据获取和设置游戏状态
#   - 生成子弹并添加到场景中
# 主要函数：
#   - death(): 处理玩家死亡逻辑
#   - create_dust(): 生成移动灰尘效果
# ==============================================================================================
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D  # 动画组件引用

# 玩家移动属性
@export var speed: float = 200.0       # 移动速度
@export var acceleration: float = 1000.0  # 加速度
@export var friction: float = 1000.0     # 摩擦力

# 射击属性
@export var bullet: RigidBody2D         # 子弹模板
@export var fire_rate: float = 1.0       # 射击频率（秒）

# 内部状态
var shoot_cooldown: float = 0.0          # 射击冷却时间
var is_dead: bool = false                # 是否死亡

# 信号定义
signal hit  # 被击中信号
signal restart  # 重启信号
signal shoot  # 射击信号

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	update_movement(delta)
	update_animation()
	update_shooting(delta)
	record_data()
	
	move_and_slide()
	create_dust()

func update_movement(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")  # 获取移动方向
	var target: Vector2 = dir * speed  # 计算目标速度
	
	# 处理X轴加速度和摩擦力
	velocity.x = move_toward(velocity.x, target.x, (acceleration if dir.x != 0 else friction) * delta)
	# 处理Y轴加速度和摩擦力
	velocity.y = move_toward(velocity.y, target.y, (acceleration if dir.y != 0 else friction) * delta)

func update_animation() -> void:
	var is_moving: bool = velocity.length() > 0.1  # 检查是否在移动
	animation.play("move" if is_moving else "idle")  # 播放对应动画
	animation.flip_h = get_global_mouse_position().x < global_position.x  # 根据鼠标位置翻转

func update_shooting(delta: float) -> void:
	shoot_cooldown += delta  # 更新冷却时间
	
	# 检查射击条件
	if Input.is_action_just_pressed("shoot") and shoot_cooldown >= fire_rate:
		shoot.emit()  # 发送射击信号
		
		# 创建并配置子弹
		var bullet_clone: RigidBody2D = bullet.duplicate()  # 克隆子弹模板
		bullet_clone.is_clone = true  # 标记为实际发射的子弹
		bullet_clone.visible = true  # 设置可见
		bullet_clone.global_position = global_position  # 设置初始位置
		
		# 计算并设置射击方向
		var shoot_dir: Vector2 = (get_global_mouse_position() - global_position).normalized()  # 朝向鼠标的单位向量
		bullet_clone.direction = shoot_dir  # 设置子弹方向
		
		# 添加到子弹容器
		%Bullets.add_child(bullet_clone)  # 将子弹添加到场景
		
		shoot_cooldown = 0.0  # 重置冷却时间
		
		# 记录子弹数据到全局
		Global.bullet_data[Global.time] = {
			"position": bullet_clone.global_position,  # 子弹位置
			"direction": bullet_clone.direction  # 子弹方向
		}

func record_data() -> void:
	# 确保玩家数据结构存在
	if not Global.player_data.has(Global.loop):
		Global.player_data[Global.loop] = {}  # 初始化当前循环的玩家数据
	
	# 记录玩家当前状态到全局数据
	Global.player_data[Global.loop][Global.time] = {
		"position": global_position,  # 当前位置
		"animation": animation.animation,  # 当前动画
		"flip_h": animation.flip_h  # 当前翻转状态
	}

func create_dust() -> void:
	# 检查是否在移动
	if velocity.length() <= 0.1:
		return  # 不移动则不生成灰尘
	
	# 灰尘资源路径
	var dust_path: String = "res://assets/sprites/player/dust/"
	var dir: DirAccess = DirAccess.open(dust_path)  # 打开灰尘资源目录
	
	# 检查目录是否存在
	if dir:
		var dust_files: PackedStringArray = dir.get_files()  # 获取所有灰尘文件
		
		# 检查是否有灰尘文件
		if dust_files.size() > 0:
			# 随机选择一个灰尘文件
			var random_dust: String = dust_files[randi() % dust_files.size()]
			
			# 跳过非PNG文件
			if not random_dust.ends_with(".png"):
				return
			
			# 创建灰尘精灵
			var dust_sprite: Sprite2D = Sprite2D.new()  # 创建新的精灵节点
			dust_sprite.texture = load(dust_path + random_dust)  # 加载灰尘纹理
			
			# 设置灰尘位置和大小
			dust_sprite.global_position = global_position + Vector2(randf_range(-5, 5), 3)  # 随机偏移位置
			dust_sprite.scale = Vector2(0.05, 0.05)  # 缩小灰尘
			
			# 添加到灰尘容器
			%Dust.add_child(dust_sprite)  # 将灰尘添加到场景
			
			# 创建灰尘消失动画
			var tween: Tween = create_tween()  # 创建补间动画
			tween.tween_property(dust_sprite, "modulate:a", 0, 0.5)  # 0.5秒内透明度变为0
			tween.tween_callback(dust_sprite.queue_free)  # 动画结束后销毁灰尘


func _on_area_2d_area_entered(area: Area2D) -> void:
	# 检查是否已经死亡
	if is_dead:
		return
	
	# 检查碰撞区域类型
	if area.name == "EnemyArea":
		# 检查敌人是否在警告状态
		if area.get_parent().animation.animation != "warn":
			death()  # 调用死亡函数
	elif area.name == "BulletArea":
		# 检查子弹是否是克隆的且超过安全时间
		if area.get_parent().birth_time > 0.2 and area.get_parent().is_clone:
			hit.emit()  # 发送被击中信号
			death()  # 调用死亡函数

func death() -> void:
	print("player death")  # 打印死亡信息
	%HurtAudio.play()  # 播放受伤音效
	is_dead = true  # 标记为死亡
	animation.play("death")  # 播放死亡动画
	
	# 等待后触发重启信号
	await get_tree().create_timer(0.5).timeout  # 等待0.5秒
	restart.emit()  # 发送重启信号
