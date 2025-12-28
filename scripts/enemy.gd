extends CharacterBody2D

@export var speed := 30
var is_clone := false
var is_dead := false
var clone_id := 0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

# 实现敌人出现，默认是warn动画，等待2s后播放move动画
func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	animation.play("move")

func _physics_process(delta: float) -> void:
	#如果是克隆且不是warn动画，则执行以下代码
	if  is_clone and animation.animation != "warn":
		if clone_id == Global.loop:
			# 检查玩家数据是否存在
			if not Global.player_data.has(Global.loop) or not Global.player_data[Global.loop].has(Global.time):
				return
			if animation.animation == "death":
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
				
			Global.enemy_data[Global.loop][Global.time] = {
				"position": global_position,
				"animation": animation.animation,
				"flip_h": animation.flip_h
			}
		else:
			# 检查敌人数据是否存在
			if not Global.enemy_data.has(clone_id) or not Global.enemy_data[clone_id].has(Global.time):
				return

			var data = Global.enemy_data[clone_id][Global.time]
			if animation.animation == "death":
				return

			# 设置位置
			position = data["position"]
			animation.flip_h = data["flip_h"]
			animation.animation = data["animation"]

			
			


func _on_enemy_area_area_entered(area: Area2D) -> void:
	if is_clone and not is_dead and area.name == "BulletArea" and area.get_parent().is_clone:
		# 死亡处理
		animation.play("death")
		is_dead = true
		$CollisionShape2D.queue_free()
		await get_tree().create_timer(0.1).timeout
		$EnemyArea.queue_free()
		
