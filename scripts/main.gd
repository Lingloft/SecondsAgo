"""
主场景控制器
这个文件是整个游戏的"入口"，管理菜单和游戏场景的切换。
主要功能：
1. 显示主菜单、暂停菜单、游戏结束菜单
2. 加载和销毁游戏场景
3. 处理暂停和继续游戏
4. 更新顶部的循环次数和时间显示
"""
extends Node2D

const GAME_SCENE = preload("res://scenes/game.tscn") # 预加载游戏场景
var current_game = null # 当前游戏实例，没有游戏时为null
@onready var top_label: CanvasLayer = $UI/TopLabel # 顶部标签容器，显示循环次数和时间

func _ready(): # 节点进入场景树时调用
	$UI.process_mode = Node.PROCESS_MODE_ALWAYS # 设置UI在游戏暂停时也能响应
	EventBus.game_over.connect(_on_game_over) # 监听游戏结束信号
	show_main_menu() # 显示主菜单

func show_main_menu(): # 显示主菜单
	set_ui(true, false, false, false, false) # 只显示主菜单
	free_game() # 销毁游戏场景

func load_game(): # 加载游戏
	free_game() # 先销毁旧游戏
	Global.reset() # 重置全局数据
	current_game = GAME_SCENE.instantiate() # 实例化游戏场景
	get_tree().paused = false # 取消暂停
	$GameContainer.add_child(current_game) # 添加游戏到容器
	set_ui(false, false, false, true, true) # 显示游戏UI和顶部标签
	$GameContainer/Game/WorldEnvironment.environment.glow_intensity = 2.0 # 设置初始辉光强度

func free_game(): # 销毁游戏
	if current_game: # 如果有游戏实例
		current_game.queue_free() # 删除游戏
		current_game = null # 清空引用

func set_ui(main: bool, pause: bool, over: bool, game: bool, top: bool): # 设置各个UI的显示状态
	$UI/MainMenu.visible = main # 主菜单
	$UI/PauseMenu.visible = pause # 暂停菜单
	$UI/GameOverMenu.visible = over # 游戏结束菜单
	$UI/GameUI.visible = game # 游戏内UI
	top_label.visible = top # 顶部标签

func _input(event): # 处理输入事件
	if event.is_action_pressed("ui_cancel") and current_game and not $UI/GameOverMenu.visible: # 按ESC且有游戏且不是结束状态
		get_tree().paused = true # 暂停游戏
		set_ui(false, true, false, false, false) # 显示暂停菜单

func _on_start_button_down() -> void: load_game() # 开始按钮：加载游戏
func _on_exit_button_down() -> void: get_tree().quit() # 退出按钮：退出游戏
func _on_back_button_down() -> void: show_main_menu() # 返回按钮：回到主菜单
func _on_restart_button_down() -> void: load_game() # 重玩按钮：重新加载游戏

func _on_cancel_button_down() -> void: # 继续按钮
	get_tree().paused = false # 取消暂停
	set_ui(false, false, false, true, true) # 显示游戏UI

func _on_pause_button_down() -> void: # 暂停按钮
	get_tree().paused = true # 暂停游戏
	set_ui(false, true, false, false, false) # 显示暂停菜单

func _on_game_over() -> void: # 收到游戏结束信号
	get_tree().paused = true # 暂停游戏
	set_ui(false, false, true, false, false) # 显示游戏结束菜单

func _on_game_die() -> void: pass # 兼容场景中旧的信号连接

func _physics_process(_delta: float) -> void: # 每个物理帧调用
	$UI/TopLabel/LoopLabel.text = "LOOP: " + str(Global.loop) # 更新循环次数显示
	$UI/TopLabel/TimeLabel.text = "TIME: " + str(snappedf(Global.time, 0.1)) # 更新时间显示
