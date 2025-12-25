extends RigidBody2D

# 子弹属性
var is_clone := false
var direction := Vector2.ZERO
@export var force := 30000
@export var camera: Camera2D

# 防止立即碰撞
var birth_time := 0.0

func _ready() -> void:
	if is_clone:
		# 施加力
		apply_central_force(direction * force)
		# 摄像机震动
		camera.shake_once()

func _physics_process(delta: float) -> void:
	# 子弹旋转朝向运动方向
	rotation = linear_velocity.angle()
	# 更新诞生时间
	birth_time += delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("bullet enter area " + area.name)
	if is_clone:
		if area.name == "EnemyArea":
			camera.shake_once()
			queue_free()
		elif area.name == "PlayerArea" and birth_time > 0.2:
			queue_free()
