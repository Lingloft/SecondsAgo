"""
相机控制器
这个文件控制游戏相机的行为。
主要功能：
1. 平滑跟随玩家移动
2. 相机位置会稍微偏向鼠标方向，让玩家看到更多前方内容
3. 收到震动信号时抖动画面
"""
extends Camera2D

@export var target: Node2D # 跟随目标，在编辑器中指定为玩家
@export var speed: float = 12.0 # 跟随速度
var shake: bool = false # 是否正在震动
var amplitude: float = 3.0 # 震动幅度

func _ready() -> void:
	EventBus.camera_shake.connect(shake_once) # 监听相机震动信号

func _physics_process(delta: float) -> void: 
	global_position = global_position.lerp(target.global_position.lerp(get_global_mouse_position(), 0.25), delta * speed) # 相机位置平滑移动到玩家和鼠标之间的点
	if shake: global_position += Vector2(randf(), randf()) * amplitude # 如果正在震动就随机偏移位置

func shake_once() -> void: # 执行一次震动
	shake = true # 开始震动
	await get_tree().create_timer(0.1).timeout # 等待0.1秒
	shake = false # 停止震动
