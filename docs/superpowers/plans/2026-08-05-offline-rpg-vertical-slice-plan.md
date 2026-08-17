# Offline RPG Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build one complete offline 2D side-view adventure loop with Knight, Archer, and Mage classes, from town departure through expedition completion and reward return.

**Architecture:** Keep `Town` and `Expedition` as separate game spaces. Keep temporary expedition state separate from permanent player progression. Offline play owns all state locally; later multiplayer can replace local ownership and input transport without changing the town-to-expedition loop.

**Tech Stack:** Godot 4.7, GDScript, existing 2D scene system, headless Godot smoke checks. No new dependencies.

## Global Constraints

- First multiplayer target: 2–4 player online co-op, but this plan implements offline play only.
- Initial classes: Knight, Archer, Mage.
- Core loop: `Town → expedition selection → expedition → reward → Town`.
- Expedition is temporary; player progression is permanent.
- Keep current user changes in `scenes/movement.gd`; inspect and preserve intentional behavior before modifying it.
- Do not add matchmaking, servers, PvP, trading, guilds, or MMO systems.
- Use the smallest scene and script structure that supports the complete slice.

---

## File map

Create focused files only when a responsibility becomes real:

- `scripts/player_state.gd`: serializable character progression and runtime values.
- `scripts/expedition_state.gd`: temporary expedition progress.
- `scripts/reward_result.gd`: immutable-style completion result data.
- `scripts/game_flow.gd`: town/expedition transitions and state ownership.
- `scripts/player.gd`: player movement, facing, class attack entry point.
- `scripts/enemy.gd`: minimal enemy health, contact damage, and defeat signal.
- `scripts/combat.gd`: shared hit and damage calculation.
- `scripts/save_system.gd`: local save/load for player progression.
- `scenes/town.tscn`: preparation area and expedition selection.
- `scenes/expedition.tscn`: one playable expedition map.
- `scenes/player.tscn`: player presentation and collision.
- `scenes/game.tscn`: application root and `GameFlow` entry point.
- `tests/smoke_test.gd`: one headless assert-based check for state transitions and rewards.

Modify existing files only where they own the corresponding behavior:

- `project.godot`: input actions and main-scene settings.
- `scenes/game.tscn`: root scene composition.
- `scenes/player.tscn`: player script and visual nodes.
- `scenes/movement.gd`: migrate or replace only after reviewing the uncommitted user change.

## Task 1: Establish typed game state

**Files:**
- Create: `scripts/player_state.gd`
- Create: `scripts/expedition_state.gd`
- Create: `scripts/reward_result.gd`
- Create: `tests/smoke_test.gd`

**Interfaces:**
- `PlayerState.new(id: String = "local_player")`
- `PlayerState.to_dict() -> Dictionary`
- `PlayerState.from_dict(data: Dictionary) -> PlayerState`
- `ExpeditionState.new(expedition_id: String)`
- `ExpeditionState.complete() -> RewardResult`
- `RewardResult.new(success: bool, experience: int, currency: int, items: Array[String])`

- [ ] **Step 1: Write the failing state smoke check**

Create a headless script that constructs a `PlayerState`, serializes it, restores it, completes an `ExpeditionState`, and asserts the reward values.

```gdscript
extends SceneTree

func _init() -> void:
	var player := PlayerState.new()
	player.class_id = "mage"
	player.experience = 10
	var restored := PlayerState.from_dict(player.to_dict())
	assert(restored.class_id == "mage")
	assert(restored.experience == 10)

	var expedition := ExpeditionState.new("starter_cave")
	var reward := expedition.complete()
	assert(reward.success)
	quit()
```

- [ ] **Step 2: Run the check and confirm it fails**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: FAIL because the state scripts and classes do not exist.

- [ ] **Step 3: Implement the minimum state classes**

Use typed properties with these minimum fields:

```gdscript
# PlayerState
var player_id: String
var class_id: String = "knight"
var level: int = 1
var experience: int = 0
var currency: int = 0
var items: Array[String] = []

# ExpeditionState
var expedition_id: String
var completed_objectives: Array[String] = []
var defeated_enemies: int = 0
var is_complete: bool = false
```

`complete()` sets `is_complete` and returns one starter reward: 100 experience, 25 currency, and `"starter_reward"`.

- [ ] **Step 4: Run the check and confirm it passes**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: PASS with exit code 0.

- [ ] **Step 5: Commit**

```bash
git add scripts tests
git commit -m "feat: add offline game state models"
```

## Task 2: Make player movement feel correct

**Files:**
- Modify: `project.godot`
- Modify: `scenes/player.tscn`
- Modify: `scenes/movement.gd` after reviewing the uncommitted user change
- Create: `scripts/player.gd`

**Interfaces:**
- `Player.move_input(direction: float) -> void`
- `Player.attack() -> void`
- `Player.set_class(class_id: String) -> void`

- [ ] **Step 1: Define gameplay input actions**

Add `move_left`, `move_right`, `jump`, `attack`, and `ability` actions in `project.godot`. Keep the existing UI actions working until the new actions are verified.

- [ ] **Step 2: Add the player scene contract**

Make `scenes/player.tscn` contain one `CharacterBody2D`, one collision node, one visible placeholder, and a `Player` script. Keep visuals as simple colored shapes until art is requested.

- [ ] **Step 3: Implement movement and facing**

Use acceleration/deceleration, gravity, floor checks, jump, and left/right facing. Do not add inventory, animation state machines, or networking hooks yet.

- [ ] **Step 4: Run the game and verify the movement checklist**

Run: `godot --path . --editor --quit`

Manual check: player moves left/right, stops without sliding indefinitely, jumps only from the floor, collides with the ground, and does not fall through the map.

- [ ] **Step 5: Commit**

```bash
git add project.godot scenes/player.tscn scenes/movement.gd scripts/player.gd
git commit -m "feat: establish responsive player movement"
```

## Task 3: Add shared combat and the three classes

**Files:**
- Create: `scripts/combat.gd`
- Create: `scripts/enemy.gd`
- Modify: `scripts/player.gd`
- Modify: `scenes/player.tscn`
- Create: `scenes/enemy.tscn`

**Interfaces:**
- `Combat.calculate_damage(attacker_class: String, ability_id: String) -> int`
- `Combat.apply_damage(target: Node, amount: int) -> void`
- `Player.attack() -> void`
- `Enemy.take_damage(amount: int) -> void`

- [ ] **Step 1: Add the failing combat assertions**

Extend `tests/smoke_test.gd` with:

```gdscript
assert(Combat.calculate_damage("knight", "basic_attack") > 0)
assert(Combat.calculate_damage("archer", "basic_attack") > 0)
assert(Combat.calculate_damage("mage", "basic_attack") > 0)
```

- [ ] **Step 2: Run the check and confirm it fails**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: FAIL because `Combat` does not exist.

- [ ] **Step 3: Implement one basic attack per class**

Use deliberately simple distinctions:

- Knight: short-range, strongest direct hit.
- Archer: long-range projectile or hit area, lower direct damage.
- Mage: short-to-mid-range area hit, lowest single-target damage.

Keep the attack entry point identical. Only class data and hit shape/range differ.

- [ ] **Step 4: Add one enemy type**

Enemy follows the player at short range, deals contact damage with a cooldown, has health, and emits a defeat signal. No behavior tree or general AI framework.

- [ ] **Step 5: Run the check and manual combat test**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Manual check: each class attacks, enemies take damage, enemies defeat, and the player can be damaged without receiving damage every frame.

- [ ] **Step 6: Commit**

```bash
git add scripts scenes/player.tscn scenes/enemy.tscn tests/smoke_test.gd
git commit -m "feat: add class combat and starter enemy"
```

## Task 4: Build town-to-expedition flow

**Files:**
- Create: `scripts/game_flow.gd`
- Create: `scenes/town.tscn`
- Create: `scenes/expedition.tscn`
- Modify: `scenes/game.tscn`
- Modify: `project.godot`

**Interfaces:**
- `GameFlow.start_expedition(expedition_id: String) -> void`
- `GameFlow.finish_expedition() -> RewardResult`
- `GameFlow.return_to_town() -> void`

- [ ] **Step 1: Add the transition assertions**

Extend `tests/smoke_test.gd` to assert that a fresh flow starts in town, starts `starter_cave`, finishes it, and returns to town.

```gdscript
var flow := GameFlow.new()
assert(flow.current_space == "town")
flow.start_expedition("starter_cave")
assert(flow.current_space == "expedition")
var result := flow.finish_expedition()
assert(result.success)
flow.return_to_town()
assert(flow.current_space == "town")
```

- [ ] **Step 2: Run the check and confirm it fails**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: FAIL because `GameFlow` and the two spaces do not exist.

- [ ] **Step 3: Implement the transition owner**

`GameFlow` owns the current `PlayerState`, current `ExpeditionState`, and current space. It creates the expedition state on start, converts completion into `RewardResult`, and clears temporary expedition state on return.

- [ ] **Step 4: Create one playable expedition**

Build a small side-view map with ground, one traversal obstacle, three enemy encounters, one objective, and one boss arena. Use placeholder shapes. The player must be able to reach the exit after the boss is defeated.

- [ ] **Step 5: Connect the main scene**

Make `scenes/game.tscn` instantiate `GameFlow`, load town first, and transition to the expedition scene when the player selects `starter_cave`.

- [ ] **Step 6: Run the check and manual loop test**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Manual check: launch in town, choose the starter expedition, complete it, see a completion result, and return to town.

- [ ] **Step 7: Commit**

```bash
git add project.godot scripts scenes tests/smoke_test.gd
git commit -m "feat: add town and expedition flow"
```

## Task 5: Add rewards and local save/load

**Files:**
- Create: `scripts/save_system.gd`
- Modify: `scripts/game_flow.gd`
- Modify: `scripts/player_state.gd`
- Modify: `tests/smoke_test.gd`

**Interfaces:**
- `SaveSystem.save_player(state: PlayerState) -> bool`
- `SaveSystem.load_player() -> PlayerState`
- `GameFlow.apply_reward(result: RewardResult) -> void`

- [ ] **Step 1: Add the failing save/reward assertions**

Create a temporary save path under `user://`, apply a reward, save the player, load it, and assert experience, currency, and item values match.

- [ ] **Step 2: Run the check and confirm it fails**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: FAIL because `SaveSystem` and reward application do not exist.

- [ ] **Step 3: Implement JSON save/load**

Save one local player dictionary to `user://simple_rpg_save.json`. If the file is missing, return a default `PlayerState`. If JSON is invalid, return a default state and print one clear error.

- [ ] **Step 4: Apply rewards only after expedition completion**

`GameFlow.apply_reward()` updates permanent player state. It must not update the player when the expedition result is unsuccessful or already applied.

- [ ] **Step 5: Run the check and manual persistence test**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Manual check: complete the expedition, close the game, reopen it, and verify the reward remains.

- [ ] **Step 6: Commit**

```bash
git add scripts tests/smoke_test.gd
git commit -m "feat: persist expedition rewards"
```

## Task 6: Validate the offline vertical slice

**Files:**
- Modify: `tests/smoke_test.gd` only if a failed flow exposes a real defect.
- Modify: relevant implementation file only when the checklist identifies a defect.

- [ ] **Step 1: Run the full headless smoke check**

Run: `godot --headless --path . --script res://tests/smoke_test.gd`

Expected: PASS with exit code 0.

- [ ] **Step 2: Run an editor import check**

Run: `godot --headless --path . --editor --quit`

Expected: exit code 0 with no parse errors.

- [ ] **Step 3: Play one complete expedition manually**

Verify:

- Town loads first.
- Expedition selection is understandable.
- Movement and jumping feel controllable.
- Knight, Archer, and Mage feel mechanically different.
- Enemies can be damaged and defeated.
- Boss completion allows return.
- Rewards appear once.
- Reload preserves progression.

- [ ] **Step 4: Record the multiplayer gate**

Do not begin networking until one person can complete the loop without blocking bugs and the three classes have distinct useful roles. At that point, create a separate multiplayer implementation plan covering room ownership, authority, synchronization, disconnects, and reward validation.

- [ ] **Step 5: Commit only verified fixes**

```bash
git add scripts scenes project.godot tests
git commit -m "test: validate offline adventure slice"
```

## Multiplayer boundary after this plan

Online multiplayer is intentionally a separate plan. It should consume the completed interfaces rather than redesigning the offline game:

- `PlayerState` becomes replicated character data.
- `Party` becomes a networked lobby model.
- `ExpeditionState` becomes party-owned authoritative state.
- `RewardResult` becomes validated completion output.
- `GameFlow` remains the town/expedition lifecycle owner.

No server or networking code should be added before the offline gate in Task 6 passes.
