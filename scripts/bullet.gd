extends RigidBody2D

# ==============================================================================================
# 文件功能：子弹控制模块
# 设计目标：实现子弹的物理运动、旋转和碰撞检测
# 核心逻辑：
#   1. 子弹生成时施加初始力，朝指定方向飞行
#   2. 子弹自动旋转朝向运动方向
#   3. 碰撞检测和处理，包括玩家和敌人碰撞
# 模块间交互：
#   - 被玩家模块生成和配置
#   - 碰撞时触发相机震动和音效
# 主要变量：
#   - is_clone: 是否为克隆子弹（实际发射的子弹）
#   - direction: 子弹飞行方向
#   - force: 子弹初始力大小
#   - birth_time: 子弹诞生时间，用于防止立即碰撞
# ==============================================================================================

# 子弹核心属性
var is_clone: bool = false  # 是否为克隆子弹（实际发射的子弹）
var direction: Vector2 = Vector2.ZERO  # 子弹飞行方向
@export var force: float = 10000.0  # 子弹初始力大小
@export var camera: Camera2D  # 相机节点引用，用于震动效果

# 防止子弹立即碰撞自身的出生时间
var birth_time: float = 0.0  # 子弹诞生时间（秒）

func _ready() -> void:
	if is_clone:  # 如果是实际发射的子弹
		apply_central_force(direction * force)  # 朝指定方向施加初始力
		camera.shake_once()  # 触发相机震动效果

func _physics_process(delta: float) -> void:
	rotation = linear_velocity.angle()  # 子弹旋转朝向运动方向
	birth_time += delta  # 更新子弹诞生时间

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_clone:  # 非克隆子弹不处理碰撞
		return
	
	if area.name == "PlayerArea" and birth_time > 0.2:  # 碰撞玩家且超过安全时间
		%DeathAudio.play()  # 播放死亡音效
		queue_free()  # 销毁子弹
	elif area.name == "EnemyArea":  # 碰撞敌人
		%DeathAudio.play()  # 播放死亡音效
