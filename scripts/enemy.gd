"""
敌人控制器
这个文件控制敌人的行为。
主要功能：
1. 敌人出生时显示警告动画，2秒后开始追踪玩家
2. 当前循环的敌人会追踪玩家位置
3. 历史循环的敌人会回放之前记录的行为
4. 被子弹击中时播放死亡动画
"""
extends CharacterBody2D

var speed: float = 30.0 # 移动速度
var dead: bool = false # 是否已死亡
var clone_id: int = 0 # 循环ID，用于区分是哪个循环的敌人

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D # 获取动画精灵节点

func _ready() -> void:
	animation.play("warn") # 播放警告动画（红色闪烁）
	await get_tree().create_timer(2.0).timeout # 等待2秒
	animation.play("move") # 切换到移动动画

func _physics_process(delta: float) -> void:
	if animation.animation == "death": return # 如果正在播放死亡动画就跳过
	if clone_id == Global.loop: track_player(delta) # 如果是当前循环的敌人就追踪玩家
	else: replay_behavior() # 否则回放历史行为

func track_player(delta: float) -> void: # 追踪玩家
	var player_pos: Variant = Global.player_data.get(Global.loop, {}).get(Global.time, {}).get("position") # 获取玩家当前位置
	if player_pos == null: return # 如果没有玩家数据就跳过
	
	
	animation.flip_h = player_pos.x < global_position.x # 根据玩家位置决定朝向
	if animation.animation != "warn": # 如果不是警告状态
		position += (player_pos - global_position).normalized() * speed * delta # 朝玩家方向移动
	
	Global.enemy_data.get_or_add(Global.loop, {})[Global.time] = { # 记录当前状态到全局数据
		"position": global_position, "animation": animation.animation, "flip_h": animation.flip_h # 记录位置、动画、朝向
	}

func replay_behavior() -> void: # 回放历史行为
	var data: Variant = Global.enemy_data.get(clone_id, {}).get(Global.time) # 获取该循环该时间点的数据
	if not data: return # 如果没有数据就跳过
	position = data["position"] # 设置位置
	animation.flip_h = data["flip_h"] # 设置朝向
	animation.animation = data["animation"] # 设置动画

func _on_enemy_area_area_entered(area: Area2D) -> void: # 当敌人碰撞区域与其他区域接触时调用
	if not dead and area.name == "BulletArea": # 如果没死且碰到子弹
		animation.play("death") # 播放死亡动画
		dead = true # 标记为死亡
		$EnemyArea.queue_free() # 删除碰撞区域，防止继续触发碰撞
