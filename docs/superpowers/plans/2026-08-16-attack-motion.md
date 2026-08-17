# Data-Driven Attack Motion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give each attack a distinct, resource-authored procedural motion without changing combat behavior.

**Architecture:** Add an `AttackMotionData` Resource to each `CombatActionData`. Combat results carry the selected resource into `CombatComponent`; `ProceduralRig2D` interpolates its phase poses from that resource. Class/action-name branching is removed from attack pose selection.

**Tech Stack:** Godot 4.7, GDScript, `.tres` Resources, existing SceneTree tests.

## Global Constraints

- Preserve existing gameplay timing, hit detection, damage, and input behavior.
- Keep procedural silhouettes; do not add sprite assets or animation plugins.
- Keep tests runnable with `godot --headless --path . --script tests/<name>.gd`.
- Do not add a runtime dependency.

---

### Task 1: Motion data contract

**Files:**
- Create: `scripts/attack_motion_data.gd`
- Modify: `scripts/combat_action_data.gd`
- Modify: `scripts/combat_rules.gd`
- Create: `tests/attack_motion_test.gd`

- [x] Add a failing test asserting selected Knight, Archer, and Mage actions expose non-empty, distinct motion profiles.
- [x] Run the test and confirm it fails because the result has no motion profile.
- [x] Add the Resource and return it from combat results.
- [x] Run the focused test and confirm it passes.

### Task 2: Author class motions

**Files:**
- Modify: `data/classes/knight.tres`
- Modify: `data/classes/archer.tres`
- Modify: `data/classes/mage.tres`

- [x] Add compact phase pose subresources for light, heavy, aerial, ranged, charged, guard, and area attacks.
- [x] Assign those resources to the existing actions without changing gameplay fields.
- [x] Run the focused motion test.

### Task 3: Profile-driven procedural rig

**Files:**
- Modify: `scripts/combat_component.gd`
- Modify: `scripts/procedural_rig_2d.gd`
- Modify: `tests/attack_motion_test.gd`

- [x] Add a test that two motion profiles produce different rig pose values at the same phase.
- [x] Run it red.
- [x] Store the selected motion in `CombatComponent`.
- [x] Replace class/action-name attack pose branches with profile interpolation.
- [x] Run focused and full tests.

### Task 4: Verification

**Files:** None.

- [x] Run all SceneTree tests.
- [x] Run `godot --headless --path . --editor --quit`.
- [x] Inspect the diff for gameplay-field changes and report any remaining limitation.
