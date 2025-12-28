extends Node2D
# 根据loop，切换不同的wall，在walls下，有许多个tilemaplayer，根据loop的值，切换不同的tilemaplayer的visible属性
# 每两个loop切换一次wall
# Walls是node2d，里面有Wall1、Wall2、Wall3、Wall4、Wall5、Wall6、Wall7
var walls = []

func _ready() -> void:
	walls = $Walls.get_children()
	switch_wall(0)

func switch_wall(loop: int) -> void:
	var active_index = int(loop / 2.0)
	if (active_index >= walls.size()):
		active_index = walls.size() - 1
	for i in range(walls.size()):
		var is_active = (i == active_index)
		walls[i].visible = is_active
		walls[i].set_deferred("collision_enabled", is_active)


			

func _on_timer_loop_timeout() -> void:
	print(Global.loop)
	switch_wall(Global.loop)
