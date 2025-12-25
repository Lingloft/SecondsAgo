extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var is_clone := false
var clone_id := 1

func _physics_process(_delta: float) -> void:
	if is_clone and Global.player_data.size() > 0:
		# 检查数据是否存在
		if not Global.player_data[clone_id].has(Global.time):
			return

		# 回放玩家数据
		var data = Global.player_data[clone_id][Global.time]
		global_position = data["position"]
		animation.play(data["animation"])
		animation.flip_h = data["flip_h"]
