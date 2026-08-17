# Systemic Combat Foundation Design

**Status:** Approved for implementation by the user's request to make `plan.md` and do all.

## Decision

Migrate the existing duel in place. The current scene, controls, geometric visuals, and tested public methods remain. Spatial combat is introduced through one reusable `AttackData` resource and one reusable physics query helper. This is the smallest change that makes the requested combat model real without duplicating the encounter in a second sandbox or prematurely creating a generic framework.

## Data flow

```text
input / enemy intent
  → actor action state
  → AttackData phase clock
  → CombatQuery against physics bodies
  → actor damage / stagger / knockback
  → controller hit-stop / camera impulse
  → actor procedural draw feedback
```

`DuelRules` continues to choose enemy intent. It does not decide a hit from symbolic action names. `CombatQuery` is the sole first-slice spatial hit test and uses the same reach/thickness values that drive the attack drawing.

## Error handling and compatibility

- Missing or invalid attack data returns a safe inactive attack and a clear test failure rather than crashing the scene.
- Queries deduplicate bodies so one active frame cannot damage an actor repeatedly.
- Existing `begin_action`, `action_can_hit`, `action_can_evade`, `take_hit`, and `clear_action` methods remain available while their internals gain buffering and data-driven timing.
- No external art, plugin, or runtime dependency is introduced.

## Testing

- `attack_data_test.gd` proves phase transitions and visual progress.
- `spatial_attack_test.gd` proves a query hits an overlapping body, misses an out-of-range body, and excludes the attacker.
- `action_timing_test.gd` gains one buffered-input assertion.
- Existing scene, rules, camera, enemy, and visual tests remain unchanged unless a public behavior contract needs an explicit update.
