extends Node

# 游戏全局变量
var loop := 1              # 当前循环
var time := 10.0           # 游戏时间
var wait_time := 10.0      # 循环时间

# 游戏数据记录
var player_data := {}      # 玩家数据 {loop: {time: {position, flip_h}}}
var bullet_data := {}      # 子弹数据 {time: {position, direction}}
var enemy_data := {}       # 敌人数据 {loop: {time: {enemy_id: {position, flip_h}}}}
