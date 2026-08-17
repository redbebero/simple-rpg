# Data-Driven Combat Profiles

## Goal

Remove class-specific branching from combat selection so new classes and actions can be added as data without editing `CombatRules`.

## Design

`CombatActionData` is a reusable `Resource` containing action ID, context conditions, combat values, and result state. `CombatClassData` is a `Resource` containing a class ID, basic actions, and class actions.

`CombatRules` discovers every `.tres` profile under `res://data/classes/`, indexes them by `class_id`, filters actions by generic condition matching, and selects the highest-priority matching action. It never checks for Knight, Archer, Mage, or future class names.

Conditions support exact context values plus generic `_min` and `_max` suffixes. This covers movement, charge timing, guard, evade, target state, and future numeric thresholds without one branch per class.

Contact resolution looks up the selected action by ID, copies its values, and applies target modifiers such as boss pushback resistance. Missing profiles or action IDs return an explicit error and empty result.

## Data Layout

```text
data/classes/knight.tres
data/classes/archer.tres
data/classes/mage.tres
data/classes/rogue.tres
```

The Rogue profile in tests proves a new class works without a code change.

## Compatibility

The existing `CombatRules` public methods remain unchanged:

```gdscript
get_action(class_id, context)
can_cancel(action_id, elapsed)
resolve_contact(class_id, action_id, target_state)
resolve_class_action(class_id, context)
```

## Testing

Headless assertions verify profile discovery, class-specific action selection, generic conditions, class-action selection, contact modifiers, cancellation timing, and a new data-only class. No test relies on hardcoded class branches.
