extends Node2D


const GAME_SCENE = preload("res://scenes/game.tscn")
var current_game = null
@onready var top_label: CanvasLayer = $UI/TopLabel
func _ready():
	$UI.process_mode = Node.PROCESS_MODE_ALWAYS
	show_main_menu()
	


func show_main_menu():
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/GameOverMenu.hide()
	$UI/GameUI.hide()
	top_label.visible = false
	# 确保游戏实例已被释放
	free_game()

func load_game():
	#清理旧游戏实例
	free_game()
	# 实例化并添加
	current_game = GAME_SCENE.instantiate()
	get_tree().paused = false
	$GameContainer.add_child(current_game)
	$UI/PauseMenu.hide()
	$UI/MainMenu.hide()
	$UI/GameOverMenu.hide()
	$UI/GameUI.show()
	top_label.visible = true
	# 重置游戏全局状态
	Global.loop = 0  # 重置循环次数
	Global.player_data = {}  # 清空玩家数据
	Global.bullet_data = {}  # 清空子弹数据
	Global.enemy_data = {}  # 清空敌人数据
	$GameContainer/Game/WorldEnvironment.environment.glow_intensity = 2.0  # 设置初始光强度
	# TopLabel 显示
	top_label.visible = true

# 释放game
func free_game():
	if current_game:
		current_game.queue_free()
		current_game = null
		$UI/GameUI.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel") and current_game:
		# 暂停游戏运行
		get_tree().paused = true
		$UI/PauseMenu.show()
		$UI/GameUI.hide()


func _on_start_button_down() -> void:
	load_game()


func _on_exit_button_down() -> void:
	get_tree().quit()


func _on_back_button_down() -> void:
	show_main_menu()


func _on_restart_button_down() -> void:
	load_game()


func _on_cancel_button_down() -> void:
	get_tree().paused = false
	$UI/PauseMenu.hide()
	$UI/GameUI.show()
	top_label.visible = true


func _on_pause_button_down() -> void:
	get_tree().paused = true
	$UI/PauseMenu.show()
	$UI/GameUI.hide()
	top_label.visible = false


func _on_game_die() -> void:
	$UI/GameOverMenu.show()
	$UI/GameUI.hide()
	top_label.visible = false


func _physics_process(_delta: float) -> void:
	# 更新循环次数和时间显示
	$UI/TopLabel/LoopLabel.text = "LOOP: " + str(Global.loop)  # 更新循环次数显示
	$UI/TopLabel/TimeLabel.text = "TIME: " + str(snappedf(Global.time, 0.1))  # 更新时间显示
