extends RigidBody2D
var is_clone := false
# 方向，力
var force := 30000 # 力大小
var direction := Vector2.ZERO
@export var camera: Camera2D  # 显式声明相机变量
func _ready() -> void:
	if is_clone: apply_central_force(direction * force) # 施加力
	# 摄像机震动
	camera.shake_once()

func _physics_process(_delta: float) -> void:
	# 子弹方向设定为速度方向
	rotation = linear_velocity.angle()


func _on_body_entered(_body) -> void:
	camera.shake_once()
	
