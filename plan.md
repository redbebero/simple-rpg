# Systemic 2D Action RPG Plan

## Goal

Evolve the existing `simple-rpg` duel into a spatial, data-driven 2D side-view action RPG without replacing the working project. The first shipped milestone proves responsive movement, spatial attacks, defensive freedom, modular attack timing, and procedural geometric feedback in the existing arena.

## Current baseline

- `scenes/game.tscn` composes the active encounter, HUD, camera, player, and enemy.
- `scripts/duel_controller.gd` currently owns encounter phases, HUD, environment drawing, lights, impact drawing, and most combat resolution.
- `scripts/duel_player.gd` owns movement, custom jump height, action timing, health, and player drawing.
- `scripts/duel_enemy.gd` owns intent state, approach/commit/recovery motion, knockback, and telegraphs.
- `scripts/duel_rules.gd` chooses symbolic intents and resolves action outcomes.
- `scripts/procedural_rig_2d.gd` supplies the minimal square silhouette and is safe to extend with motion parameters.
- Existing Godot tests cover timing, camera, rules, scene behavior, enemy motion, and geometric rendering.

## First vertical-slice milestone

Keep the current controls and duel encounter, then make the following concrete behaviors true:

1. A/D movement uses acceleration/deceleration and retains air control.
2. Jump supports coyote time and a short jump buffer.
3. J attack supports a short input buffer and a reusable `AttackData` phase model.
4. Player and enemy attacks use actual physics shape queries against actor collision shapes, not only `distance <= reach` or symbolic evade results.
5. Attack phases remain `startup → active → recovery`; startup permits movement, active commits movement, recovery restores movement.
6. K dodge remains directional and grants a short invulnerability window.
7. L parry remains optional and high-risk/high-reward; walking away, jumping, and dodging remain valid solutions.
8. Attack visuals derive from the same attack data: line/arc telegraphs, directional commitment, impact flash, hit stop, and a small camera impulse.
9. `DuelRules` is narrowed to intent selection and compatibility helpers; it no longer decides whether a spatial attack hits.

## Target boundaries

```text
DuelController
  encounter phase / enemy AI choice / HUD / arena feedback

DuelPlayer + DuelEnemy
  movement / action state / health / actor collision / actor-specific intent

AttackData
  phase durations / hit shape / damage / knockback / visual profile

CombatQuery
  one shared physics-space query for an AttackData against collision bodies

ProceduralRig2D + actor _draw()
  geometric silhouette / deformation / telegraph / trail / impact presentation
```

The first slice deliberately does not add a generic ECS, networking, inventory, faction simulation, NPC memory, or a boss framework. Those become later consumers of the same actor, attack, and event boundaries.

## Dependency-ordered implementation

### Phase 1 — data and test seams

- Add `scripts/attack_data.gd` as a typed `Resource` with startup, active, recovery, reach, thickness, damage, knockback, and visual kind.
- Add `scripts/combat_query.gd` with one shared rectangle/capsule physics query that excludes the attacker and returns unique hit bodies.
- Add focused tests for phase timing, attack context selection, and spatial hit filtering.

### Phase 2 — movement and action buffering

- Extend `duel_player.gd` with coyote time, jump buffering, attack buffering, and a movement multiplier by action phase.
- Preserve the current public methods used by tests and controller.
- Keep the custom geometric jump representation until a real floor collision scene is introduced.

### Phase 3 — spatial player/enemy combat

- Give player slash and enemy intent attacks `AttackData` profiles.
- Replace controller-side attack reach checks with `CombatQuery` calls during active frames.
- Keep `DuelRules.enemy_intent()` as the first AI decision layer; add no perfect-reactivity logic.
- Use `DuelRules.resolve()` only for legacy test compatibility where necessary, then remove callers once spatial behavior is verified.

### Phase 4 — procedural feedback

- Drive actor telegraphs and attack lines from `AttackData.visual_kind` and normalized action progress.
- Add reusable hit stop and camera impulse state to the encounter controller.
- Scale feedback by attack strength so normal attacks remain restrained.
- Keep all visuals draw-based and asset-free.

### Phase 5 — verification and graph review

- Run every existing `tests/*_test.gd` plus the new focused tests.
- Run Godot editor parse and headless main-scene startup.
- Rebuild `.code-review-graph` and inspect affected flows, architecture overview, and changed-file risk.
- Commit the milestone only after the full suite is green.

## Later milestones

1. Extract a shared `CombatActor` only after player and enemy have two proven shared consumers.
2. Add composable `AttackPattern` resources: motion, strike, timing, follow-up, visual profile.
3. Add utility-based enemy selection using distance, velocity, action state, health, recent actions, and personality.
4. Add `CombatProfile` for recent/long-term player tendencies.
5. Add `GameEvents`, `WorldHistory`, faction knowledge, NPC memory, and region reactions.
6. Add bosses by composing existing attacks and environment feedback, not by creating a parallel combat engine.

## Verification contract

The milestone is complete only when:

- no new Godot parse/resource errors appear;
- all existing tests pass;
- new tests prove the attack phase model, buffered input, and actual spatial hit filtering;
- the main scene still launches with A/D, Space, J, K, and L;
- the graph has no unresolved changed-file warnings that affect the active flow.
