# AGENTS.md — Engineering Source of Truth

> 本文件是所有 AI 编程助手(Codex / Cursor / Claude Code)的工程契约。设计问题以 `DESIGN.md` 为准;工程问题以本文件为准。两者冲突时,先停下来问 Victor。

## Project

**One-liner:** A 2D pixel side-scrolling action roguelike (Dead Cells as the benchmark for combat feel and art clarity — not content volume), built as a *systems-complete* vertical slice first.

**Engine lock: Godot 4 + GDScript.** This is final. Do not propose or introduce Unity, Unreal, C#, Rust/GDExtension, or any other engine/runtime without an explicit decision from Victor recorded in `DESIGN.md`.

## Repo layout

Keep a strict **systems vs content** split. Systems define interfaces and generic behavior; content is concrete data that plugs into them.

```
res://
├── project.godot        # Godot 4 project file
├── scenes/              # Entry/bootstrap scenes (main.tscn lives here)
├── systems/             # Interfaces & generic systems — NO concrete game data
│   ├── combat/          # (future) hitboxes, damage pipeline, weapon template interface
│   ├── gear/            # (future) equipment slots, stat modifiers
│   ├── map/             # (future) room graph, room loader (procedural or hand-authored)
│   ├── inventory/       # (future) inventory CRUD, item definitions interface
│   ├── skills/          # (future) skill slots, cooldowns
│   └── story/           # (future) dialogue runner + cutscene hooks (hooks only)
└── content/             # Concrete instances — weapons, rooms, items, dialogue data
    ├── weapons/         # (future) e.g. the single sword template instance
    ├── rooms/           # (future) the one-room loop
    └── dialogue/        # (future) placeholder dialogue data
```

Rules:
- Code in `systems/` must never hard-reference a specific weapon/room/item in `content/`. Content registers into systems (via exported resources, registries, or scene composition), never the reverse.
- New top-level folders require a note in this file in the same PR.
- The `(future)` subfolders above are created on demand, not preemptively.

## Coding conventions

- **GDScript only**, targeting **Godot 4.x** APIs. No Godot 3 syntax (`onready var` → `@onready var`, `export` → `@export`, signals via `signal`/`connect` Godot-4 style).
- **Prefer typed GDScript** where practical: typed parameters, return types, `: Type` on vars. Use `class_name` for reusable classes.
- **No Unity leftovers**: no `MonoBehaviour` idioms, no `Update()`/`Start()` naming, no "GameObject" vocabulary in names or comments. Use Godot idioms: `_ready()`, `_process(delta)`, `_physics_process(delta)`, signals, scenes-as-prefabs.
- File/folder names: `snake_case`. Class names: `PascalCase`. Constants: `SCREAMING_SNAKE_CASE`.
- Scenes (`.tscn`) and resources (`.tres`) stay text-format (default) so diffs are reviewable.
- Keep scripts small and single-purpose; prefer composition (child nodes / resources) over inheritance chains.

## Workflow & roles

- **Victor** owns game feel and acceptance. Nothing ships to `main` without his sign-off on feel-sensitive changes (movement, combat timing, animation).
- **`DESIGN.md`** = design source of truth. **`AGENTS.md`** (this file) = engineering source of truth.
- **Codex CLI (local)** — heavy implementation work: new systems, feature branches, large diffs.
- **Cursor (cloud)** — PR plumbing, shell tasks, small fixes, doc updates.
- **Claude Code** — hard refactors and tricky architectural untangling.
- **Bots (小G / Pixel / Scout)** — coordinate docs and tasks. Pixel refines combat-feel specs in `DESIGN.md`; they do not land engine code directly.
- All work lands via PR against `main`. One logical change per PR. PR description states which checklist item(s) it advances.

## Current milestone: Vertical Slice

Systems-complete semi: every core system exists and works end-to-end, with *thin* content counts (roughly one of each thing). Story is dialogue + cutscene **hooks only**.

Checklist with acceptance criteria:

- [ ] **Player movement: move / jump / roll**
  - Accept: a player character in a test room can walk, jump, and roll (with i-frames stubbed or real); input mapped through Godot's InputMap; feels responsive at 60 fps.
- [ ] **Attack + 1 weapon template**
  - Accept: one melee weapon implemented as a reusable template (data-driven: damage, swing timing, hitbox) with exactly one concrete instance in `content/weapons/`; attacking hits a dummy target and applies damage through the damage pipeline.
- [ ] **Gear slots (small)**
  - Accept: a small fixed set of equipment slots (e.g. weapon + 2 accessories); equipping/unequipping changes stats; no gear tree.
- [ ] **Skill slots (small)**
  - Accept: a small fixed set of skill slots with cooldowns; at least one placeholder skill that visibly fires.
- [ ] **Map: one room loop (procedural-or-hand)**
  - Accept: player can traverse a loop of at least one room — hand-authored or trivially generated — with an entrance/exit transition; room loading goes through `systems/map/`, not hardcoded scene paths in gameplay code.
- [ ] **Inventory CRUD**
  - Accept: items can be added, viewed, moved/used, and removed via a minimal UI; inventory state survives a room transition.
- [ ] **Dialogue + cutscene hooks**
  - Accept: a dialogue runner can play a short placeholder conversation triggered in-world; a cutscene hook API exists (start/end events a cutscene could latch onto). No actual story content beyond placeholder lines.

## Do / Don't for agents

**Do:**
- Keep the `systems/` vs `content/` split in every change.
- Work from the vertical-slice checklist above; say which item your change advances.
- Write typed GDScript against Godot 4 APIs; keep scenes/resources in text format.
- Ask (or stop and flag) when a task implies a design decision not covered by `DESIGN.md`.
- Keep placeholder art/audio obviously placeholder.

**Don't:**
- Don't invent long story content — story is hooks + placeholder lines only.
- Don't expand content counts (more weapons, rooms, items, skills) without a corresponding `DESIGN.md` update first.
- Don't collapse systems and content into each other, even "temporarily".
- Don't add multiplayer, multiple endings, big gear trees, or meta-progression — these are explicit non-goals.
- Don't change engine, language, or add third-party plugins without Victor's sign-off.
