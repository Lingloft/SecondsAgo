"""
全局数据管理器
这个文件是游戏的"大脑"，存储所有需要在不同场景之间共享的数据。
主要功能：
1. 记录当前是第几个循环（loop）
2. 记录当前游戏时间（time）
3. 存储玩家、子弹、敌人在每个时间点的状态数据，用于回放
"""
extends Node

var loop: int = 0 # 当前循环次数，每10秒增加1
var time: float = 10.0 # 当前倒计时时间，从10秒开始倒数
var wait_time: float = 10.0 # 每个循环的总时长，固定10秒
var player_data: Dictionary = {} # 玩家数据，格式：{循环号: {时间点: {位置, 动画, 翻转}}}
var bullet_data: Dictionary = {} # 子弹数据，格式：{时间点: {位置, 方向}}
var enemy_data: Dictionary = {} # 敌人数据，格式：{循环号: {时间点: {位置, 动画, 翻转}}}

func reset() -> void: # 重置所有数据，在开始新游戏时调用
	loop = 0 # 循环次数归零
	time = wait_time # 时间重置为10秒
	player_data = {} # 清空玩家历史数据
	bullet_data = {} # 清空子弹历史数据
	enemy_data = {} # 清空敌人历史数据
