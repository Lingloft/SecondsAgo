"""
玩家控制器
这个文件控制玩家角色的所有行为。
主要功能：
1. 接收键盘输入控制玩家移动（WASD或方向键）
2. 接收鼠标点击发射子弹
3. 播放玩家的各种动画（出场、待机、移动、死亡）
4. 移动时在脚下生成烟尘特效
5. 每帧记录玩家状态到全局数据，供幽灵回放使用
6. 检测与敌人或子弹的碰撞，触发死亡
"""
extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D # 获取动画精灵节点，用于播放各种动画

@export var speed: float = 200.0 # 玩家最大移动速度，可在编辑器中调整
@export var acceleration: float = 1000.0 # 加速度，决定玩家多快达到最大速度
@export var friction: float = 1000.0 # 摩擦力，决定玩家松开按键后多快停下来

var fire_rate: float = 1.0 # 射击间隔，两次射击之间至少间隔1秒
var shoot_cooldown: float = 0.0 # 射击冷却计时器，记录距离上次射击过了多久
var dead: bool = false # 玩家是否已死亡，死亡后不再响应输入

func _ready() -> void: # 节点进入场景树时调用
	# 播放transition音效，表示玩家已准备好
	%TransitionAudio.play()
	animation.play("show") # 播放出场动画（玩家从地上冒出来）
	await animation.animation_finished # 等待出场动画播放完毕
	animation.play("idle") # 切换到待机动画

func _physics_process(delta: float) -> void: # 每个物理帧调用，delta是距离上一帧的时间
	if dead or animation.animation == "show": return # 如果死亡或正在播放出场动画，跳过所有逻辑
	
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down") # 获取玩家输入的移动方向，返回一个单位向量
	velocity = velocity.move_toward(dir * speed, (acceleration if dir else friction) * delta) # 根据输入方向平滑改变速度，有输入用加速度，没输入用摩擦力
	
	animation.play("move" if velocity.length() > 0.1 else "idle") # 如果在移动就播放移动动画，否则播放待机动画
	animation.flip_h = get_global_mouse_position().x < global_position.x # 根据鼠标位置决定玩家朝向，鼠标在左边就翻转
	
	shoot_cooldown += delta # 累加射击冷却时间
	if Input.is_action_just_pressed("shoot") and shoot_cooldown >= fire_rate: # 如果按下射击键且冷却完毕
		shoot_cooldown = 0.0 # 重置冷却时间
		EventBus.shoot.emit(global_position, (get_global_mouse_position() - global_position).normalized()) # 发送射击信号，携带位置和朝向鼠标的方向
	
	Global.player_data.get_or_add(Global.loop, {})[Global.time] = { # 记录当前状态到全局数据，供幽灵回放
		"position": global_position, "animation": animation.animation, "flip_h": animation.flip_h # 记录位置、当前动画、是否翻转
	}
	
	move_and_slide() # 执行移动，自动处理碰撞
	if velocity.length() > 0.1: _spawn_dust() # 如果在移动就生成烟尘

func _spawn_dust() -> void: # 生成脚下的烟尘特效
	var dust_files: Array = Array(DirAccess.get_files_at("res://assets/sprites/player/dust/")).filter(func(f): return f.ends_with(".png")) # 获取烟尘文件夹里所有png图片
	if dust_files.is_empty(): return # 如果没有烟尘图片就跳过
	
	var dust := Sprite2D.new() # 创建一个新的精灵节点
	dust.texture = load("res://assets/sprites/player/dust/" + dust_files.pick_random()) # 随机选一张烟尘图片作为纹理
	dust.global_position = global_position + Vector2(randf_range(-5, 5), 3) # 设置位置在玩家脚下，稍微随机偏移
	dust.scale = Vector2(0.05, 0.05) # 缩小烟尘图片
	%Dust.add_child(dust) # 把烟尘添加到Dust容器节点
	
	create_tween().tween_property(dust, "modulate:a", 0, 0.5).finished.connect(dust.queue_free) # 创建动画让烟尘0.5秒内淡出，淡出后删除

func _on_area_2d_area_entered(area: Area2D) -> void: # 当玩家的碰撞区域与其他区域接触时调用
	if dead: return # 已经死了就不处理
	if (area.name == "EnemyArea" and area.get_parent().animation.animation != "warn") or \
	   (area.name == "BulletArea" and area.get_parent().birth_time > 0.2): # 碰到敌人（非警告状态）或子弹（出生超过0.2秒）
		dead = true # 标记为死亡
		%HurtAudio.play() # 播放受伤音效
		animation.play("death") # 播放死亡动画
		await %HurtAudio.finished
		EventBus.player_death.emit() # 发送玩家死亡信号
