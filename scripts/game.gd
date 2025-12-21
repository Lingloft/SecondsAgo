extends Node2D

@export var ghostp_player: CharacterBody2D
# 获取timer节点的时间
@export var timer: Timer
@onready var loop_label: Label = $LoopLabel
func _physics_process(_delta: float) -> void:
	Global.time = snappedf(timer.time_left, 0.01)
	loop_label.text = "LOOP: " + str(Global.loop) + " TIME: " + str(Global.time)
	


func _on_timer_loop_timeout() -> void:
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
