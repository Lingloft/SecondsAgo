extends CharacterBody2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var is_clone := false
var clone_id := 1
func _ready() -> void:
	var label = $Label
	label.text = str(clone_id)

func _physics_process(_delta: float) -> void:
	if Global.player_data.size() > 0 and is_clone:
		var data = Global.player_data[clone_id][Global.time]
		global_position = data["position"]
		animation.play(data["animation"])
		animation.flip_h = data["flip_h"]
