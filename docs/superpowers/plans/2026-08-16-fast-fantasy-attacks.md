# Fast Fantasy Attack Motion Implementation Plan

**Goal:** Make attacks respond immediately and read as agile fantasy swordsmanship with continuous blade motion, body momentum, and restrained impact effects.

**Architecture:** Keep gameplay timing in `CombatActionData` and keep presentation in `AttackMotionData` plus `ProceduralRig2D`. A single normalized attack clock drives the blade trajectory; the arm, torso, step, trail, and impact feedback derive from that same clock.

**Tech Stack:** Godot 4.7, GDScript, SceneTree assertion tests, procedural `Node2D` drawing.

## Global Constraints

- Keep the procedural geometric character style.
- Do not hardcode behavior by action or class name in the rig.
- Preserve gameplay hit detection and existing combat tests.
- Use data parameters for attack differences.
- Run the focused test after each behavior change and the full suite before completion.

## Tasks

### Task 1: Immediate response and attack intent data

Files:
- Modify `scripts/attack_motion_data.gd`
- Modify `scripts/combat_action_data.gd`
- Modify Knight motion resources in `data/classes/knight.tres`
- Test `tests/character_motion_invariants_test.gd`

Add `cut_start`, `cut_end`, `step_length`, `commitment`, and `arc_height` to motion data. Add a visual progress accessor that starts at zero when an action resolves and reaches the cut immediately instead of spending a visible startup interval. Keep `windup_time` and hit timing intact for non-Knight actions unless their existing data explicitly opts into a different timing.

### Task 2: Continuous blade trajectory

Files:
- Modify `scripts/procedural_rig_2d.gd`
- Test `tests/character_motion_invariants_test.gd`

Generate the sword hand from a continuous curved trajectory. Use smooth easing for acceleration and deceleration, interpolate angle with `lerp_angle`, and add the profile’s arc height. The blade must have distinct intermediate positions and must never switch directly between phase endpoints.

### Task 3: Organic arm and body momentum

Files:
- Modify `scripts/procedural_rig_2d.gd`
- Test `tests/procedural_rig_test.gd`

Derive the wrist from the trajectory, solve a two-segment shoulder/elbow/wrist chain, and drive torso lean, body shift, knee bend, and forward step from the same attack clock. The body leads the cut; the sword does not rotate the whole character.

### Task 4: Speed readability and impact effects

Files:
- Modify `scripts/procedural_rig_2d.gd`
- Modify `scripts/feedback_component.gd` only if existing hooks are insufficient
- Test existing feedback and hit-stop tests; add one focused assertion if needed

Show the trail only during the blade acceleration and impact window. Add a small leading-edge flash and use existing hit-stop/camera feedback on impact without adding a second effect system.

### Task 5: Class profile tuning and verification

Files:
- Modify `data/classes/knight.tres`
- Modify `data/classes/archer.tres`
- Modify `data/classes/mage.tres`
- Modify enemy motion resources if required by the shared parameters

Tune Knight first, then give ranged and magical profiles compatible trajectories without sword-specific branches. Run every test, headless editor startup, and a live window capture for visual inspection.
