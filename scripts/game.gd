extends Node2D

@export var ghostp_player: CharacterBody2D
# 获取timer节点的时间
@export var timer: Timer

@onready var loop_label: Label = $LoopLabel
@onready var camera: Camera2D = %Camera

func _ready():
	timer.wait_time = Global.time
	timer.start()

func _physics_process(_delta: float) -> void:
	Global.time = snappedf(timer.time_left, 0.01)
	loop_label.text = "LOOP: " + str(Global.loop) + " TIME: " + str(Global.time)

	# 如果bullet_data里存在当前time的键
	if Global.bullet_data.has(Global.time):
		# 获取当前时间的子弹数据
		var bullet_data = Global.bullet_data[Global.time]
		# 创建子弹
		var bullet_clone = $Bullet.duplicate()
		# 设置位置
		bullet_clone.global_position = bullet_data["position"]
		# 设置方向
		bullet_clone.direction = bullet_data["direction"]
		bullet_clone.visible = true
		bullet_clone.is_clone = true
		%Bullets.add_child(bullet_clone)

		
		
func _on_timer_loop_timeout() -> void:
	ScreenFade()
	# 删除所有子弹
	for child in %Bullets.get_children(): child.queue_free()
	# 克隆幽灵玩家
	var ghostp = ghostp_player.duplicate()
	# 设置为克隆体
	ghostp.is_clone = true
	# 设置可见
	ghostp.visible = true
	# 设置位置
	ghostp.clone_id = Global.loop
	add_child(ghostp)
	# 进入下一循环
	Global.loop += 1
	


func _on_player_hit() -> void:
	# 相机震动
	camera.shake_once()


# 屏幕遮罩刷新，用CanvasModulate
func ScreenFade() -> void:
	# 设置color为全白
	$CanvasModulate.color = Color(1, 1, 1, 1)
	create_tween().tween_property($CanvasModulate, "color", Color(0.35, 0.35, 0.35, 1), 0.5)

	
