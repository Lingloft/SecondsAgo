extends Node2D

@onready var mask: Polygon2D = $Mask
@onready var walls: Array = $Walls.get_children()

func _ready() -> void:
	switch_wall(0)

func switch_wall(loop: int) -> void:
	var idx := mini(int(loop / 2.0), walls.size() - 1)
	for i in walls.size():
		walls[i].visible = (i == idx)
		walls[i].set_deferred("collision_enabled", i == idx)
	update_mask(walls[idx])

func _on_timer_loop_timeout() -> void:
	switch_wall(Global.loop)

func update_mask(wall: TileMapLayer) -> void:
	var cells := wall.get_used_cells()
	if cells.is_empty():
		mask.visible = false
		return
	
	var ts := Vector2(wall.tile_set.tile_size) / 2
	var bounds := [Vector2(INF, INF), Vector2(-INF, -INF)]
	for cell in cells:
		var pos := wall.map_to_local(cell)
		bounds[0] = bounds[0].min(pos)
		bounds[1] = bounds[1].max(pos)
	
	mask.visible = true
	mask.polygon = PackedVector2Array([bounds[0] - ts, Vector2(bounds[1].x + ts.x, bounds[0].y - ts.y), bounds[1] + ts, Vector2(bounds[0].x - ts.x, bounds[1].y + ts.y)])
	mask.invert_enabled = true
	mask.invert_border = 5000
	mask.color = Color.BLACK
