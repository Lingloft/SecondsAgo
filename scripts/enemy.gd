extends CharacterBody2D
const speed := 30
var is_clone := false
var is_dead := false
var clone_id := 1
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
# 开始启动，如果是克隆，向玩家移动
func _physics_process(delta: float) -> void:
	if is_clone and not is_dead:
		# 向玩家移动
		# 获取玩家位置
		# 先确保时间存在
		if not Global.player_data.has(Global.loop):return
		if not Global.player_data[Global.loop].has(Global.time):return
		var player_position = Global.player_data[Global.loop][Global.time]["position"]
		# 根据玩家与自己的相对位置决定翻转
		animation.flip_h = player_position.x < global_position.x
		# 计算移动方向
		var direction = player_position - global_position
		direction = direction.normalized()
		# 移动
		position += direction * speed * delta

		Global.enemy_data[Global.loop] = {}
		
		Global.enemy_data[Global.loop][Global.time] = {}
		Global.enemy_data[Global.loop][Global.time][clone_id] = {}

		Global.enemy_data[Global.loop][Global.time][clone_id] = {"position": global_position, "flip_h": animation.flip_h}

# 当被子弹击中时，如果是克隆，则动画播放死亡

func _on_area_2d_body_entered(body: Node2D) -> void:
	# 检测是否是子弹，不仅仅是只检测克隆，来自bullets的子弹
	if not is_clone:return
	if is_dead:return
	if body.get_parent().name == "Bullets":
		animation.play("death")
		is_dead = true
		# 移除arae2d
		$Area2D.queue_free()
		# 自己的collision_shape2d也移除
		await get_tree().create_timer(0.1).timeout
		$CollisionShape2D.queue_free()
		
