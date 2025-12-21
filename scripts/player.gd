extends CharacterBody2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 200
@export var acceleration: float = 1500
@export var friction: float = 1500
@export var bullet: RigidBody2D
# 子弹发射时间计时
var shoot_timer:= 1.0


func _physics_process(delta: float) -> void:
	# 获取输入方向
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 计算目标速度
	var targetVelocity = moveDirection * speed
	
	# 处理加速度/摩擦力
	velocity.x = move_toward(velocity.x, targetVelocity.x, (acceleration if moveDirection.x != 0 else friction) * delta)
	velocity.y = move_toward(velocity.y, targetVelocity.y, (acceleration if moveDirection.y != 0 else friction) * delta)
	
	# 处理动画
	animation.play("move" if velocity.length() > 0.1 else "idle")
	
	# 根据鼠标位置翻转角色
	animation.flip_h = get_global_mouse_position().x < global_position.x

	# 记录数据: 使用字符串键存储
	if not Global.player_data.has(Global.loop):
		Global.player_data[Global.loop] = {}
	
	Global.player_data[Global.loop][Global.time] = {
		"position": global_position,
		"animation": animation.animation,
		"flip_h": animation.flip_h
	}
	

	# 移动角色
	move_and_slide()



	# 射击
	shoot_timer += delta
	if Input.is_action_just_pressed("shoot") and shoot_timer > 1:
		# 克隆子弹
		var bullet_clone = bullet.duplicate()
		# 设置为克隆体
		bullet_clone.is_clone = true
		# 设置可见
		bullet_clone.visible = true
		# 设置位置
		bullet_clone.global_position = global_position
		# 设置方向，将鼠标坐标转换为方向向量
		bullet_clone.direction = (get_global_mouse_position() - bullet_clone.global_position).normalized()
		# 添加到场景，根节点，不是到玩家节点
		get_tree().root.call_deferred("add_child", bullet_clone)
		# 重置计时器
		shoot_timer = 0.0

		
