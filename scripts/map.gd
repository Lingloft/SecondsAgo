"""
地图控制器
这个文件控制地图的行为。
主要功能：
1. 管理多套墙壁，每2个循环切换一次
2. 根据当前显示的墙壁更新遮罩区域
3. 遮罩让墙壁外的区域变黑，限制玩家视野
"""
extends Node2D

@onready var mask: Polygon2D = $Mask # 遮罩多边形，用于遮挡墙壁外的区域
@onready var walls: Array = $Walls.get_children() # 获取所有墙壁图层

func _ready() -> void: # 节点进入场景树时调用
	switch_wall(0) # 显示第一套墙壁

func switch_wall(loop: int) -> void: # 切换墙壁
	var idx := mini(int(loop / 2.0), walls.size() - 1) # 计算应该显示哪套墙壁，每2个循环切换一次，最多到最后一套
	for i in walls.size(): # 遍历所有墙壁
		walls[i].visible = (i == idx) # 只显示当前索引的墙壁
		walls[i].set_deferred("collision_enabled", i == idx) # 只启用当前墙壁的碰撞
	update_mask(walls[idx]) # 更新遮罩区域

func _on_timer_loop_timeout() -> void: # 计时器超时时调用（通过场景连接）
	switch_wall(Global.loop) # 根据当前循环切换墙壁

func update_mask(wall: TileMapLayer) -> void: # 更新遮罩区域
	var cells := wall.get_used_cells() # 获取墙壁使用的所有格子
	if cells.is_empty(): # 如果没有格子
		mask.visible = false # 隐藏遮罩
		return # 跳过
	
	var ts := Vector2(wall.tile_set.tile_size) / 2 # 获取格子大小的一半
	var bounds := [Vector2(INF, INF), Vector2(-INF, -INF)] # 初始化边界，最小值设为无穷大，最大值设为负无穷大
	for cell in cells: # 遍历所有格子
		var pos := wall.map_to_local(cell) # 把格子坐标转换为本地坐标
		bounds[0] = bounds[0].min(pos) # 更新最小边界
		bounds[1] = bounds[1].max(pos) # 更新最大边界
	
	mask.visible = true # 显示遮罩
	mask.polygon = PackedVector2Array([bounds[0] - ts, Vector2(bounds[1].x + ts.x, bounds[0].y - ts.y), bounds[1] + ts, Vector2(bounds[0].x - ts.x, bounds[1].y + ts.y)]) # 设置遮罩多边形为墙壁的边界矩形
	mask.invert_enabled = true # 启用反转，让矩形内部透明，外部不透明
	mask.invert_border = 5000 # 设置反转边界大小，确保覆盖整个屏幕
	mask.color = Color.BLACK # 设置遮罩颜色为黑色
