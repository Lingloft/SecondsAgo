@warning_ignore_start("unused_signal")
"""
事件总线（信号中转站）
这个文件是游戏的"广播站"，用于在不同节点之间传递消息。
当一个节点想通知其他节点发生了什么事，就通过这里发送信号。
好处是节点之间不需要直接引用对方，降低耦合度。
"""
extends Node

signal shoot(position: Vector2, direction: Vector2) # 射击信号，玩家开枪时发出，携带射击位置和方向
signal player_death # 玩家死亡信号，玩家被敌人或子弹击中时发出
signal camera_shake # 相机震动信号，射击或死亡时发出，让画面抖一下
signal game_over # 游戏结束信号，玩家死亡后发出，通知主界面显示结束菜单
signal loop_timeout # 循环超时信号，通知地图切换墙壁
