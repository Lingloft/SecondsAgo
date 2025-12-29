extends Camera2D

# ==============================================================================================
# 文件功能：相机控制模块
# 设计目标：实现相机跟随玩家和震动效果
# 核心逻辑：
#   1. 相机平滑跟随玩家和鼠标位置的混合点
#   2. 实现临时震动效果
# 模块间交互：
#   - 被玩家、子弹等模块调用，触发震动效果
#   - 跟随指定的目标节点（通常是玩家）
# 主要函数：
#   - shake_once(): 触发一次相机震动
# ==============================================================================================

@export var target: Node2D      # 相机跟随的目标节点
@export var speed: float = 12.0  # 相机移动速度
@export var shake: bool = false   # 震动开关
var amplitude: float = 3.0       # 震动幅度

func _physics_process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()  # 获取鼠标全局位置
	var new_pos: Vector2 = target.global_position.lerp(mouse_pos, 0.25)  # 计算玩家和鼠标之间的混合位置
	global_position = global_position.lerp(new_pos, delta * speed)  # 平滑移动相机到目标位置
	
	if shake:  # 如果开启震动
		global_position += Vector2(randf(), randf()) * amplitude  # 添加随机偏移实现震动效果

func shake_once() -> void:
	# 触发一次相机震动
	shake = true  # 开启震动
	
	var timer: Timer = Timer.new()  # 创建临时计时器
	timer.wait_time = 0.2  # 震动持续时间
	timer.one_shot = true  # 设置为一次性触发
	add_child(timer)  # 添加到场景树
	timer.start()  # 启动计时器
	
	await timer.timeout  # 等待计时器结束
	timer.queue_free()  # 释放计时器
	
	shake = false  # 关闭震动
	
