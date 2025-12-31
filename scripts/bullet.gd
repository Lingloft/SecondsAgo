"""
子弹控制器
这个文件控制子弹的行为。
主要功能：
1. 子弹生成后朝指定方向飞行
2. 子弹旋转角度跟随飞行方向
3. 检测与玩家或敌人的碰撞
4. 记录出生时间，防止刚发射就打到玩家自己
"""
extends RigidBody2D

var direction: Vector2 = Vector2.ZERO # 飞行方向
var birth_time: float = 0.0 # 出生时间，用于判断是否刚发射
@export var force: float = 10000.0 # 推力大小，决定子弹飞行速度

func _ready() -> void: # 节点进入场景树时调用
	apply_central_force(direction * force) # 给子弹施加推力让它飞出去

func _physics_process(delta: float) -> void: # 每个物理帧调用
	rotation = linear_velocity.angle() # 让子弹旋转角度跟随速度方向
	birth_time += delta # 累加出生时间

func _on_area_2d_area_entered(area: Area2D) -> void: # 当子弹碰撞区域与其他区域接触时调用
	if (area.name == "PlayerArea" and birth_time > 0.2) or area.name == "EnemyArea": # 碰到玩家（出生超过0.2秒）或敌人
		%BoomAudio.play() # 播放爆炸音效


func _on_body_entered(_body: Node) -> void:
	%CollisionAudio.play()
		
	
