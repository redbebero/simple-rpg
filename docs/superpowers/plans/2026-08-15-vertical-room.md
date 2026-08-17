# Vertical Room Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add buffered hitstop input, one reusable vertical room, and a shape-based moving enemy prototype.

**Architecture:** Separate room scene owns rectangular static geometry. Combat input owns a tiny FIFO buffer and runs while SceneTree is paused. Enemy keeps existing health/combat behavior and delegates only visual movement to a small drawing component.

**Tech Stack:** Godot 4.7, GDScript, 2D CharacterBody2D, Compatibility renderer.

## Global Constraints

- Side-view movement only; verticality comes from jump and platforms.
- No tilemap, procedural generation, networking, or art assets in this slice.
- Reuse existing components; no class-specific enemy subclasses.
- Every non-trivial rule gets one headless assertion.

## Tasks

### Task 1: Hitstop input buffer

**Files:** Modify `scripts/combat_component.gd`; create `tests/input_buffer_test.gd`.

- Run existing combat tests first.
- Add buffer for `action`, `class_action`, and `evade` press/release events during pause.
- Set component `process_mode` to `PROCESS_MODE_ALWAYS`.
- Flush events in order after pause ends; expire buffered events after `0.18` seconds.
- Test press and release during paused tree still produce one action after unpause.

### Task 2: Reusable room pieces

**Files:** Create `scripts/room_piece.gd`, `scenes/room_piece.tscn`, `scenes/room_vertical.tscn`; create `tests/room_piece_test.gd`; modify `scenes/game.tscn`.

- Export rectangle `size` and `color` on `RoomPiece`.
- Create one collision shape and draw one rectangle from same size.
- Build vertical room with floor, two platforms, and side walls.
- Replace game scene ground with room scene.
- Test exported size and room piece collision shape dimensions.

### Task 3: Shape-based enemy motion

**Files:** Create `scripts/enemy_visual.gd`; modify `scenes/enemy.tscn`; create `tests/enemy_visual_test.gd`.

- Replace red `ColorRect` with Node2D drawing circle head, rectangle body, rectangle weapon, and shadow.
- Lean and weapon offset follow parent velocity and facing.
- Squash briefly on landing or hit; keep effect visual-only.
- Test visual node responds to non-zero enemy velocity without changing enemy collision.

### Task 4: Verification

- Run every `tests/*_test.gd`.
- Run Godot editor parse, main scene startup, and `git diff --check`.
- Manually verify jump onto platform, attack during hitstop, enemy movement, and room boundaries.
