extends Node2D
# 根据loop，切换不同的wall，在walls下，有许多个tilemaplayer，根据loop的值，切换不同的tilemaplayer的visible属性
# 每两个loop切换一次wall
# Walls是node2d，里面有Wall1、Wall2、Wall3、Wall4、Wall5、Wall6、Wall7

@onready var mask: Polygon2D = $Mask

var walls = []

func _ready() -> void:
	walls = $Walls.get_children()
	switch_wall(0)

func switch_wall(loop: int) -> void:
	var active_index = int(loop / 2.0)
	if (active_index >= walls.size()):
		active_index = walls.size() - 1
	update_mask(active_index)
	for i in range(walls.size()):
		var is_active = (i == active_index)
		walls[i].visible = is_active
		walls[i].set_deferred("collision_enabled", is_active)

func _on_timer_loop_timeout() -> void:
	print(Global.loop)
	switch_wall(Global.loop)

func update_mask(active_index) -> void:
	var wall = walls[active_index]
	var used_cells = wall.get_used_cells()
	
	if used_cells.is_empty():
		mask.visible = false
		return
	
	mask.visible = true
	
	# 1. 计算墙体的边界 (这一步和你之前的逻辑一致)
	var min_x = INF; var min_y = INF
	var max_x = -INF; var max_y = -INF
	
	for cell in used_cells:
		var pos = wall.map_to_local(cell)
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	
	var tile_size = wall.tile_set.tile_size
	min_x -= tile_size.x / 2
	min_y -= tile_size.y / 2
	max_x += tile_size.x / 2
	max_y += tile_size.y / 2
	
	# 2. 定义“洞”的形状（即墙体矩形）
	var hole_vertices = PackedVector2Array([
		Vector2(min_x, min_y),
		Vector2(max_x, min_y),
		Vector2(max_x, max_y),
		Vector2(min_x, max_y)
	])
	
	# 3. 配置 Polygon2D 实现反向遮罩
	mask.polygon = hole_vertices  # 直接设置洞的形状
	mask.invert_enabled = true     # 开启反转 [类似效果见 2]
	mask.invert_border = 5000      # 设置一个足够大的边界，覆盖整个屏幕
	mask.color = Color(0, 0, 0, 1) # 遮罩颜色为黑色
