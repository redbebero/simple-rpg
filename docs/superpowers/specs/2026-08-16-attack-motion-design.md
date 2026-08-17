# Data-Driven Attack Motion Design

## Goal

Make attacks visibly distinct per action and class while keeping the current procedural character silhouettes.

## Design

`CombatActionData` owns an optional `AttackMotionData` resource. The combat rules result carries that resource to `CombatComponent`, which exposes it to `ProceduralRig2D`. The rig interpolates phase poses from the resource instead of branching on class and action names.

Each motion profile defines windup, active, and recovery poses using body shift, torso lean, weapon angle, weapon lift, knee bend, and squash. The profile also controls trail intensity. Gameplay timing remains owned by `CombatActionData`; motion only describes presentation.

Existing class resources reuse a small set of named motion profiles: light, heavy, aerial, guard, ranged, charged, and area. This keeps authoring compact while allowing every action to point at a different profile later.

## Boundaries

- `CombatActionData`: gameplay values plus motion resource reference.
- `CombatRules`: returns motion data with the selected action.
- `CombatComponent`: stores the selected action motion for the current timeline.
- `ProceduralRig2D`: interpolates and draws the motion; it does not select by class/action ID.
- `FeedbackComponent`: remains responsible for impact/light feedback.

## Verification

- Add a Godot SceneTree test proving Knight, Archer, and Mage actions expose distinct motion profiles.
- Run all existing tests and a headless project startup.
