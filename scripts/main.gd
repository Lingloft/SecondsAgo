extends Node2D


const GAME_SCENE = preload("res://scenes/game.tscn")
var current_game = null
func _ready():
	show_main_menu()

func show_main_menu():
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/GameOverMenu.hide()
	$UI/GameUI.hide()
	# 确保游戏实例已被释放
	free_game()

func load_game():
	#清理旧游戏实例
	free_game()
	# 实例化并添加
	current_game = GAME_SCENE.instantiate()
	current_game.paused = false
	$GameContainer.add_child(current_game)
	$UI/PauseMenu.hide()
	$UI/MainMenu.hide()
	$UI/GameOverMenu.hide()
	$UI/GameUI.show()

# 释放game
func free_game():
	if current_game:
		current_game.queue_free()
		current_game = null
		$UI/GameUI.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel") and current_game:
		# 暂停游戏运行
		current_game.paused = true
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
	current_game.paused = false
	$UI/PauseMenu.hide()
	$UI/GameUI.show()


func _on_pause_button_down() -> void:
	current_game.paused = true
	$UI/PauseMenu.show()
	$UI/GameUI.hide()
