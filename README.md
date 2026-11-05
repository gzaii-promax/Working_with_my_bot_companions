# Working_with_my_bot_companions

多智能体游戏开发工作流训练仓库,目标是产出一个 Godot 4 像素风横版动作 Roguelike 半成品。

- 设计真相源:[DESIGN.md](DESIGN.md)(由 Pixel 维护)
- 工程真相源 / 协作规则与任务拆分:[AGENTS.md](AGENTS.md)(由小G维护)

## 用 Godot 打开 / Open in Godot

1. 安装 [Godot 4.x](https://godotengine.org/download)(标准版即可,无需 .NET 版)。
2. 打开 Godot → Import → 选择本仓库的 `project.godot`。
3. 按 F5 运行,启动沙盒测试房 `scenes/main.tscn`。方向键 ← / → 移动,空格跳跃,Shift 地面翻滚；非翻滚期间松开方向键立即停止,仅落地后可再次跳跃。

Install Godot 4.x, import `project.godot`, press F5 — move with Left / Right, jump with Space, and roll on the ground with Shift.

本次补齐 **Player movement: move/jump/roll** 的实现。玩家为独立的 `systems/player/player.tscn`（32×32 占位色块）；测试房在 `content/rooms/sandbox.tscn`，由主场景组合。尚未包含攻击或怪；60 fps 手感仍需 Victor 在 Godot Editor 中验收。

翻滚默认速度 500 px/s、持续 0.2 秒，可在玩家 Inspector 中调整。按当前移动方向翻滚，静止时沿上次朝向（初始向右）；期间锁定方向并禁止跳跃，结束后立即恢复普通移动，无方向输入时立即停止。长按 Shift 不会连续触发。`is_rolling` 和 `is_invincible` 为可读取状态，整个翻滚窗口内无敌标记为真，结束即清除；目前仅为 i-frame 占位，尚未接入伤害系统。

无界面验证（仓库根目录）：

```sh
godot --headless --editor --import --quit
godot --headless --script res://systems/player/tests/movement_smoke.gd
godot --headless --quit-after 60
```

## 工作流 / Workflow

一句话:Victor 把关手感与验收,本地 Codex 负责重实现,Cursor 负责仓库壳/小修/PR,Claude Code 负责疑难重构,机器人(小G / Pixel / Scout)协调文档与任务。详见 [AGENTS.md](AGENTS.md)。
