extends CharacterBody2D

const speed := 30
var is_clone := false
var is_dead := false
var clone_id := 1

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if is_clone and not is_dead:
		# 检查玩家数据是否存在
		if not Global.player_data.has(Global.loop) or not Global.player_data[Global.loop].has(Global.time):
			return

		# 获取玩家位置
		var player_position = Global.player_data[Global.loop][Global.time]["position"]
		
		# 翻转动画
		animation.flip_h = player_position.x < global_position.x
		
		# 向玩家移动
		var direction = (player_position - global_position).normalized()
		position += direction * speed * delta

		# 记录敌人数据
		if not Global.enemy_data.has(Global.loop):
			Global.enemy_data[Global.loop] = {}
		if not Global.enemy_data[Global.loop].has(Global.time):
			Global.enemy_data[Global.loop][Global.time] = {}
			
		Global.enemy_data[Global.loop][Global.time][clone_id] = {
			"position": global_position,
			"flip_h": animation.flip_h
		}

func _on_area_2d_body_entered(body: Node2D) -> void:
	# 被子弹击中检测
	if not is_clone or is_dead or body.get_parent().name != "Bullets":
		return

	# 死亡处理
	animation.play("death")
	is_dead = true
	
	# 移除碰撞区域
	$Area2D.queue_free()
	
	# 延迟移除碰撞形状
	await get_tree().create_timer(0.1).timeout
	$CollisionShape2D.queue_free()
