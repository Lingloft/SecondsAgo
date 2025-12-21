extends RigidBody2D
var is_clone := false
var force := 30000 # 力大小
var direction := Vector2.ZERO
@export var camera: Camera2D
func _ready() -> void:
	if is_clone: 
		apply_central_force(direction * force) # 施加力
		camera.shake_once()# 摄像机震动

func _physics_process(_delta: float) -> void:
	# 子弹方向设定为速度方向
	rotation = linear_velocity.angle()


func _on_body_entered(_body) -> void:
	camera.shake_once()
	
