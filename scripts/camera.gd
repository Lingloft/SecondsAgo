extends Camera2D

@export var target: Node2D      # 跟随目标节点
@export var speed: float = 12.0  # 相机移动速度
@export var shake := false       # 震动开关
var amplitude := 3              # 震动幅度

func _physics_process(delta: float) -> void:
	# 计算新位置（玩家和鼠标之间的1/4处）
	var newPos = target.global_position.lerp(get_global_mouse_position(), 0.25)
	
	# 平滑移动相机
	global_position = global_position.lerp(newPos, delta * speed)
	
	# 相机震动效果
	if shake:
		global_position += Vector2(randf(), randf()) * amplitude

func shake_once():
	# 执行一次震动效果
	shake = true
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	await timer.timeout
	timer.queue_free()
	
	shake = false
	
