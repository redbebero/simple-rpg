# simple-rpg Error Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Keep the current duel gameplay, rename visible project identity to `simple-rpg`, remove all missing-script load errors, and publish the verified repository to GitHub.

**Architecture:** Preserve `scenes/game.tscn` and its existing duel controller/player/enemy path. Remove only unused broken prototype scene references and scripts; do not replace the combat architecture.

**Tech Stack:** Godot 4.7 GDScript, Git, GitHub remote.

## Global Constraints

- Preserve existing user changes.
- Do not add dependencies or new gameplay systems.
- Delete only files proven unused after reference-graph and Godot checks.
- Verify with Godot headless before committing or pushing.

### Task 1: Identify broken and unused resources

**Files:** Read-only inspection of `scenes/*.tscn`, `scripts/*.gd`, `project.godot`, `.code-review-graph`.

- [ ] List every `res://` script/scene reference and confirm whether its target exists.
- [ ] Confirm the current main scene loads through `duel_controller.gd`.
- [ ] Compare broken prototype resources against all scene and script callers.

### Task 2: Remove load errors and rename the project

**Files:**
- Modify: `project.godot`
- Modify: `scenes/game.tscn`
- Modify or delete: only unused prototype scenes/scripts identified in Task 1

- [ ] Change the project name and visible title from `The First Duel` to `simple-rpg`.
- [ ] Remove broken external script references from unused scenes, or delete the unused scenes when no caller remains.
- [ ] Keep the active duel scene and its referenced scripts intact.

### Task 3: Verify and publish

**Files:** All changed files from Tasks 1-2.

- [ ] Run `godot --headless --path . --editor --quit` and confirm no missing-script/resource errors.
- [ ] Run the repository's existing GDScript tests if they are runnable without extra dependencies.
- [ ] Use `.code-review-graph`/SQLite metadata and `rg` to confirm no stale references remain.
- [ ] Review `git diff` and `git status` so unrelated user changes remain untouched.
- [ ] Commit the cleanup and push to `https://github.com/redbebero/simple-rpg`.
