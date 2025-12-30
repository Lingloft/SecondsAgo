extends CharacterBody2D

# ==============================================================================================
# 文件功能：敌人控制模块
# 设计目标：实现敌人的行为逻辑、状态管理和数据记录
# 核心逻辑：
#   1. 敌人初始显示警告动画，2秒后切换为移动动画
#   2. 克隆敌人根据ID和当前循环状态决定行为：
#      - 与当前循环ID匹配：追踪玩家并记录状态
#      - 不匹配：根据历史数据回放行为
#   3. 敌人碰撞到子弹时播放死亡动画并移除碰撞体
# ==============================================================================================

var speed: float = 30.0 # 敌人移动速度
var dead: bool = false # 敌人是否死亡
var clone_id: int = 0 # 克隆敌人的ID

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D # 动画组件引用

func _ready() -> void:
	# 敌人初始播放警告动画，2秒后切换为移动动画
	animation.play("warn")
	await get_tree().create_timer(2.0).timeout
	animation.play("move")

func _physics_process(delta: float) -> void:
	if animation.animation == "death": return # 死亡状态下不处理移动逻辑
	
	if clone_id == Global.loop: track_player(delta) # 当前循环的敌人，追踪玩家
	else: replay_behavior() # 历史循环的敌人，回放行为

func track_player(delta: float) -> void:
	# 检查玩家数据是否存在
	if not Global.player_data.has(Global.loop): return
	if not Global.player_data[Global.loop].has(Global.time): return
	
	var player_pos: Vector2 = Global.player_data[Global.loop][Global.time]["position"] # 获取玩家位置
	animation.flip_h = player_pos.x < global_position.x # 翻转动画朝向玩家
	
	# 计算移动方向并移动
	if not animation.animation == "warn":
		var dir: Vector2 = (player_pos - global_position).normalized() # 朝向玩家的单位向量
		position += dir * speed * delta # 向玩家移动

	record() # 记录敌人当前状态

func replay_behavior() -> void:
	# 检查敌人历史数据是否存在
	if not Global.enemy_data.has(clone_id): return
	if not Global.enemy_data[clone_id].has(Global.time): return
	
	var data: Dictionary = Global.enemy_data[clone_id][Global.time] # 获取历史数据
	
	# 回放位置和动画状态
	position = data["position"] # 设置位置
	animation.flip_h = data["flip_h"] # 设置翻转状态
	animation.animation = data["animation"] # 设置动画

func record() -> void:
	# 确保敌人数据结构存在
	if not Global.enemy_data.has(Global.loop):
		Global.enemy_data[Global.loop] = {} # 初始化当前循环的敌人数据
	if not Global.enemy_data[Global.loop].has(Global.time):
		Global.enemy_data[Global.loop][Global.time] = {} # 初始化当前时间的敌人数据
	
	# 记录敌人当前状态
	Global.enemy_data[Global.loop][Global.time] = {
		"position": global_position, # 当前位置
		"animation": animation.animation, # 当前动画
		"flip_h": animation.flip_h # 当前翻转状态
	}

			
func _on_enemy_area_area_entered(area: Area2D) -> void:
	# 检查碰撞的是子弹区域且敌人未死亡
	if not dead and area.name == "BulletArea":
		animation.play("death") # 播放死亡动画
		dead = true # 标记为死亡
		$EnemyArea.queue_free() # 移除敌人区域碰撞体
