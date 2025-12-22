extends RigidBody2D
var is_clone := false
var force := 10000 # 力大小
var direction := Vector2.ZERO
@export var camera: Camera2D
# 子弹诞生时间，防止在玩家位置一生成就命中玩家
var birth_time := 0.0
func _ready() -> void:
	if is_clone: 
		apply_central_force(direction * force) # 施加力
		camera.shake_once()# 摄像机震动

func _physics_process(delta: float) -> void:
	# 子弹方向设定为速度方向
	rotation = linear_velocity.angle()
	# 记录诞生时间
	birth_time += delta


func _on_body_entered(body) -> void:
	# 如果是玩家或者敌人
	print("body name: " + body.name)
	if body.name == "Player" or body.name == "Enemy":
		# 摄像机震动
		camera.shake_once()
		# 子弹删除自己,且要求是clone体
		if birth_time > 0.1 and is_clone:
			queue_free()
		
	
