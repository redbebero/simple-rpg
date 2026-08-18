# Role-Based World Scenes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Split the integrated prototype map into separate village, forest, and boss-arena scenes while preserving the existing player, world-state, and combat systems.

**Architecture:** `game.tscn` remains the application root and owns the scene-owned `WorldContext`, player, camera, and HUD. A small `SceneRouter` loads one role-based map scene at a time under a `MapRoot` node. Each map scene owns only its geometry and local actors; shared simulation state remains in `WorldContext` and is passed to the active map.

**Tech Stack:** Godot 4.7.1, typed GDScript, Node2D scenes, procedural CanvasItem drawing, existing duel combat scripts.

## Global Constraints

- Preserve the current geometric player/combat implementation.
- Do not add external art assets or dependencies.
- Keep world state and events scene-owned; do not add an autoload.
- Reuse existing `WorldContext`, `WorldEvents`, components, and entity scripts.
- Keep the untracked `scenes/projectile.tscn` untouched.
- Verify parser errors, runtime errors, existing tests, and scene transitions before claiming completion.

### Task 1: Add the scene routing boundary

**Files:**
- Create: `scripts/scene_router.gd`
- Modify: `scenes/game.tscn`
- Test: `tests/scene_router_test.gd`

**Interfaces:**
- `SceneRouter.setup(context: WorldContext, map_root: Node2D) -> void`
- `SceneRouter.change_map(scene_path: String, spawn_position: Vector2 = Vector2.ZERO) -> void`
- `SceneRouter.current_map_id: String`

- [ ] Add a test that loads each map scene path and asserts the router records the selected map.
- [ ] Run the targeted test and confirm it fails because the router does not exist.
- [ ] Implement the router with `load()`, `instantiate()`, `map_root.add_child()`, optional `setup_world(context)`, and removal of only the previous map child.
- [ ] Add `MapRoot` and `SceneRouter` to `game.tscn`; keep `WorldContext` outside `MapRoot`.
- [ ] Run the targeted test and the editor parse check.

### Task 2: Extract the village scene

**Files:**
- Create: `scenes/village.tscn`
- Create: `world/village_map.gd`
- Modify: `scripts/scene_router.gd`
- Test: `tests/scene_router_test.gd`

**Interfaces:**
- `VillageMap.setup_world(context: WorldContext) -> void`
- `VillageMap.get_spawn_point() -> Vector2`

- [ ] Make the village scene draw the safe area and instantiate one generic villager through the existing entity setup path.
- [ ] Add a visible forest exit marker that calls `SceneRouter.change_map("forest")` when the player reaches it.
- [ ] Keep village geometry procedural and avoid copying combat logic.
- [ ] Assert the village scene contains its role marker and villager after instantiation.

### Task 3: Extract the forest scene and systemic ecology

**Files:**
- Create: `scenes/forest.tscn`
- Create: `world/forest_map.gd`
- Modify: `scripts/scene_router.gd`
- Modify: `world/prototype_world.gd`
- Test: `tests/scene_router_test.gd`

**Interfaces:**
- `ForestMap.setup_world(context: WorldContext) -> void`
- `ForestMap.get_spawn_point() -> Vector2`

- [ ] Move the existing herbivore, predator, plant, fire, and shelter setup into the forest map.
- [ ] Keep perception, interaction resolution, weather reactions, and ecology connected to the same `WorldContext`.
- [ ] Add village and boss-arena exits using the router.
- [ ] Remove duplicated region drawing/spawn logic from `PrototypeWorld` after the forest scene owns it.
- [ ] Assert the forest has creatures and flammable objects and that fire/rain interactions still resolve.

### Task 4: Add the boss arena scene

**Files:**
- Create: `scenes/boss_arena.tscn`
- Create: `world/boss_arena_map.gd`
- Modify: `scripts/scene_router.gd`
- Test: `tests/scene_router_test.gd`

**Interfaces:**
- `BossArenaMap.setup_world(context: WorldContext) -> void`
- `BossArenaMap.get_spawn_point() -> Vector2`

- [ ] Create a separate enclosed arena with procedural walls, floor, entrance, and one existing duel enemy instance.
- [ ] Add an exit back to the forest that is available after the arena is entered.
- [ ] Reuse `duel_enemy.gd` and `duel_rules.gd`; do not create a boss framework or rewrite combat.
- [ ] Assert the arena scene contains the combat enemy and its arena marker.

### Task 5: Integrate initial routing and verify behavior

**Files:**
- Modify: `core/world_context.gd`
- Modify: `scenes/game.tscn`
- Modify: `scripts/duel_controller.gd` only if needed for coexistence
- Test: `tests/scene_router_test.gd`

- [ ] Start the game in the village and route village → forest → boss arena → forest.
- [ ] Preserve player/camera/HUD ownership in `game.tscn` and pass the player spawn position to the active map.
- [ ] Run all existing tests and the new scene-routing test.
- [ ] Run `godot --headless --path . --editor --quit` and `godot --headless --path . --quit-after 2`.
- [ ] Run `code-review-graph` and confirm no parser errors or unresolved references are introduced.
- [ ] Review the final diff and leave `scenes/projectile.tscn` unchanged.

## Self-review

- The plan covers scene separation, NPC placement, forest ecology, boss combat, shared state, routing, and verification.
- No placeholder tasks or new general-purpose framework are required.
- `WorldContext` remains the single scene-owned shared context; map scripts only consume its public API.
- `PrototypeWorld` is retired from the active main-scene path after the forest map owns its content.
