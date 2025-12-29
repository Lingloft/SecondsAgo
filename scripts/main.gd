extends Node2D


const GAME_SCENE = preload("res://scenes/game.tscn")
var current_game = null
func _ready():
	show_main_menu()

func show_main_menu():
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/GameOverMenu.hide()
	# 确保游戏实例已被释放
	if current_game:
		current_game.queue_free()
		current_game = null

func load_game():
	#清理旧游戏实例
	if current_game:
		current_game.queue_free()
		current_game = null
	# 实例化并添加
	current_game = GAME_SCENE.instantiate()
	$GameContainer.add_child(current_game)
	#重置状态
	get_tree().paused = false
	$UI/PauseMenu.hide()
	$UI/MainMenu.hide()
	$UI/GameOverMenu.hide()

func _input(event) :
	if event.is_action_pressed("ui_cancel") and current_game:
		# 暂停游戏运行
		current_game.paused = true
		$UI/PauseMenu.show()
#信号连接
func _on_start_button_pressed():
	load_game()
func _on_restart_button_pressed() :
	load_game()#直接重新实例化实现重玩
func _on_resume_button_pressed() :
	# 恢复游戏运行
	get_tree().paused = false
	$UI/PauseMenu.hide()
