extends Camera2D

@export var target: Node2D  # 相机跟随的目标节点
@export var speed: float = 12.0  # 相机移动速度
@export var shake:= false
var amplitude := 3
func _physics_process(delta: float) -> void:
	# 获取目标节点的世界坐标
	var playerPos = target.global_position
	# 获取鼠标的世界坐标
	var mousePos = get_global_mouse_position()
	# 计算玩家和鼠标之间的1/3处(靠近玩家的位置)
	var newPos = playerPos.lerp(mousePos, 1.0 / 3.0)
	# 平滑移动相机到新位置
	global_position = global_position.lerp(newPos, delta * speed)
	# 相机抖动
	if shake:
		global_position += Vector2(randf(), randf()) * amplitude

func shake_once():
	# 震动一下，0.1秒
	shake = true
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()
	shake = false
	
