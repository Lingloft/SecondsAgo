"""
幽灵玩家控制器
这个文件控制幽灵玩家的行为。
幽灵玩家是玩家在之前循环中的"影子"，会完全重现玩家之前的行为。
主要功能：
1. 根据全局数据中记录的历史位置移动
2. 播放与历史记录相同的动画
3. 保持与历史记录相同的朝向
"""
extends CharacterBody2D

var clone_id: int = 0 # 循环ID，用于读取对应循环的历史数据
var is_clone: bool = false # 是否是克隆幽灵（从场景实例化的都是克隆）

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D # 获取动画精灵节点

func _physics_process(_delta: float) -> void: # 每个物理帧调用
	var data: Variant = Global.player_data.get(clone_id, {}).get(Global.time) # 获取该循环该时间点的玩家数据
	if not data: return # 如果没有数据就跳过
	global_position = data["position"] # 设置位置为历史记录的位置
	animation.animation = data["animation"] # 设置动画为历史记录的动画
	animation.flip_h = data["flip_h"] # 设置朝向为历史记录的朝向
