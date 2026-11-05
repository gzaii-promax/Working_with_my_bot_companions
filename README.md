# Working_with_my_bot_companions

多智能体游戏开发工作流训练仓库,目标是产出一个 Godot 4 像素风横版动作 Roguelike 半成品。

- 设计真相源:[DESIGN.md](DESIGN.md)(由 Pixel 维护)
- 工程真相源 / 协作规则与任务拆分:[AGENTS.md](AGENTS.md)(由小G维护)

## 用 Godot 打开 / Open in Godot

1. 安装 [Godot 4.x](https://godotengine.org/download)(标准版即可,无需 .NET 版)。
2. 打开 Godot → Import → 选择本仓库的 `project.godot`。
3. 按 F5 运行,会启动一个空的主场景 `scenes/main.tscn`。

Install Godot 4.x, import `project.godot`, press F5 — an empty main scene runs.

## 工作流 / Workflow

一句话:Victor 把关手感与验收,本地 Codex 负责重实现,Cursor 负责仓库壳/小修/PR,Claude Code 负责疑难重构,机器人(小G / Pixel / Scout)协调文档与任务。详见 [AGENTS.md](AGENTS.md)。
