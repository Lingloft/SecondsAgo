# 几秒之前 (Seconds Ago)

一个基于时间循环的生存射击游戏，使用 Godot 4.5 开发。

## 游戏简介

在《几秒之前》中，你将陷入一个10秒的时间循环。每一轮循环中，你的所有行为都会被记录下来，并在下一轮循环中以"幽灵"的形式重现。你需要与自己的幽灵共存，同时躲避不断增加的敌人。

## 核心玩法

### 时间循环机制
- 每轮游戏时间为10秒
- 循环结束时，新的敌人和幽灵玩家会出现
- 每次循环会记录玩家的所有行为数据

### 幽灵系统
- **幽灵玩家**：重现你上一轮的移动和动画
- **历史子弹**：在记录的时间点自动发射
- 幽灵与玩家同时存在，增加了生存难度

### 敌人系统
- 敌人出生时有2秒警告时间
- 当前循环的敌人会追踪玩家
- 历史循环的敌人会回放之前的行为

## 操作控制

| 操作 | 按键 |
|------|------|
| 移动 | WASD / 方向键 |
| 射击 | 鼠标左键 |
| 瞄准 | 鼠标位置 |
| 暂停 | ESC |

## 项目结构

```
SecondsAgo/
├── assets/                 # 游戏资源
│   ├── fonts/             # 字体文件
│   ├── sounds/            # 音效和音乐
│   ├── sprites/           # 精灵图像
│   └── tilesets/          # 瓦片地图
├── scenes/                # 游戏场景
│   ├── main.tscn         # 主场景（菜单）
│   ├── game.tscn         # 游戏场景
│   ├── player.tscn       # 玩家
│   ├── enemy.tscn        # 敌人
│   ├── bullet.tscn       # 子弹
│   ├── ghost_player.tscn # 幽灵玩家
│   ├── map.tscn          # 地图
│   └── camera.tscn       # 相机
├── scripts/              # 脚本代码
│   ├── main.gd          # 主场景控制器
│   ├── game.gd          # 游戏主控制器
│   ├── player.gd        # 玩家控制
│   ├── enemy.gd         # 敌人AI
│   ├── bullet.gd        # 子弹逻辑
│   ├── ghost_player.gd  # 幽灵回放
│   ├── global.gd        # 全局数据
│   ├── map.gd           # 地图控制
│   ├── camera.gd        # 相机控制
│   └── autoload/        # 自动加载脚本
│       └── event_bus.gd # 事件总线
└── project.godot         # 项目配置
```

## 技术特点

- **引擎**: Godot 4.5
- **语言**: GDScript
- **类型**: 2D 动作射击

## 运行游戏

1. 安装 [Godot 4.5](https://godotengine.org/)
2. 克隆仓库：`git clone https://github.com/Lingloft/SecondsAgo.git`
3. 用 Godot 打开项目
4. 按 F5 运行

## 许可证

本项目采用 [GNU General Public License v3.0](LICENSE) 许可证开源。

## 贡献

欢迎提交 Issue 和 Pull Request！
