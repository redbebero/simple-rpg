# Large Scrolling Dungeon and Class Combat Plan

**Goal:** Turn the current vertical prototype into one large, dark fantasy side-view dungeon with smooth scrolling, readable layered atmosphere, and clearly different Archer/Mage attacks while preserving the Knight flow.

**Architecture:** Reuse the existing `RoomController`, `RoomPiece`, `FantasyBackground`, `CombatRules`, `CombatComponent`, and `ProceduralRig2D`. Add only one reusable projectile scene/script and keep attack differences in the existing class Resource data. Use Godot-native `Camera2D` smoothing and draw-based visuals; no external assets or new dependency.

**Success criteria:** The player can cross a large map without camera snapping, see depth through parallax-like layers and torches, fire distinct Archer/Mage projectiles with charge/hold behavior, and fight an enemy/boss whose connected geometric parts animate together and visibly telegraph large attacks.

## Constraints

- Keyboard only; no mouse input.
- Keep the current Knight controls and guard/counter behavior.
- Keep Compatibility renderer and procedural geometry.
- No networking, inventory expansion, skill tree, or art pipeline in this slice.
- Prefer existing files and Godot-native nodes over new abstractions.
- Every non-trivial new rule gets one focused Godot test.

## Implementation Order

### 1. Large map and camera

**Files:** `scenes/game.tscn`, `scripts/fantasy_background.gd`, `scripts/room_piece.gd`, new `scripts/dungeon_map.gd` only if scene data cannot stay simple.

- Expand the playable floor and walls from a room-sized rectangle to a long dungeon route.
- Keep collision geometry reusable through `RoomPiece` instances.
- Configure `Camera2D` limits to the map bounds.
- Enable position smoothing and use a small dead zone so the camera does not stick to the player.
- Make catch-up responsive when the player is far from the camera and gentle near the target using native smoothing plus a small camera script adjustment only if native behavior cannot express it.
- Draw three dark layers: distant architecture, midground pillars/arches, and foreground silhouettes.
- Add repeated torches as lightweight `Node2D` drawing elements with glow, flame pulse, and limited count.

### 2. Projectile combat

**Files:** `scripts/combat_component.gd`, `scripts/combat_rules.gd`, class `.tres` files, new `scripts/projectile.gd`, new `scenes/projectile.tscn`, `scenes/player.tscn` only if a projectile spawn marker is needed.

- Archer:
  - tap/hold Z while moving: fast low-damage arrow;
  - release charged Z: slow precise arrow with longer reach;
  - X: piercing arrow;
  - Shift while charging: cancel and backstep.
- Mage:
  - tap/hold Z: moving arcane bolt;
  - release charged Z: larger slow orb with area impact;
  - hold X: charge a large ground spell, release X to cast at the current facing position;
  - keep Shift as reposition/evade.
- Projectile owns movement, lifetime, collision query, damage payload, and visual color.
- Combat component only selects and spawns a projectile from the resolved action result.
- Use action data fields rather than class-name conditionals for projectile speed, size, damage, area, and piercing.
- Knight melee remains direct hit detection.

### 3. Procedural enemy and boss animation

**Files:** `scripts/procedural_rig_2d.gd`, `scripts/enemy.gd`, `scenes/boss.tscn`, new tests for enemy telegraph state if needed.

- Keep one rig with profile-driven scale, colors, limb count, and pose.
- Animate connected parts with shared walk phase and attack phase; avoid independent random motion.
- Add enemy states for approach, telegraph, active attack, recovery, hit, and death.
- Normal enemy gets a readable melee telegraph and short lunge.
- Boss gets large but simple patterns: sweeping attack, ground wave, and charge.
- Boss attacks must show a clear windup pose/color/scale before the damaging frame.
- Boss movement remains low pushback but receives posture and visual feedback.

### 4. Verification

- Add focused assertions for camera target/limits, projectile direction and lifetime, Archer/Mage action selection, and boss telegraph timing.
- Run all existing `tests/*_test.gd` scripts.
- Run Godot editor parse and a headless game startup.
- Manually verify: long traversal, camera feel, torch visibility, Archer/Mage distinction, boss telegraph readability, and no regressions to Knight guard/charge.

## Deliberate simplifications

- Map is hand-authored with repeated geometry, not procedural generation.
- Torches are draw-based, not individual particle systems.
- Projectiles use simple distance/collision queries, not a full projectile physics framework.
- Boss has three patterns, not a data-authored attack graph; add one only after the prototype is fun.
