# Offline-First Multiplayer Structure

## Goal

Build the game offline first while keeping the core structure compatible with later 2–4 player online co-op.

The first multiplayer version will use a shared town and party-based expedition instances:

`Town → expedition selection → party assembly → expedition → return to town`

## Scope

This document defines boundaries and data flow only. It does not define networking technology, server deployment, matchmaking, trading, PvP, or MMO systems.

## Game spaces

### Town

Town is the preparation space.

Responsibilities:

- Show player and party status
- Change or configure character equipment
- Select an expedition
- Form or join a party
- Receive expedition rewards
- Save progression

Offline version: one local player can use the town.

Future multiplayer version: players share a town channel or instance. A literal unlimited-capacity map is not required; capacity is handled by multiple town instances.

### Expedition

An expedition is a self-contained adventure instance.

Responsibilities:

- Load a selected map
- Spawn enemies and objectives
- Run exploration, combat, puzzles, and boss encounters
- Track expedition progress
- Produce a completion result
- Return players to town

Offline version: one player owns the expedition.

Future multiplayer version: one party owns the expedition state. Other parties do not affect it.

## Core boundaries

### Player

Owns character-specific state:

- Stable player identifier
- Character name
- Selected class
- Health and resource values
- Equipment
- Skills and unlocks
- Position inside the current space

Input handling must remain separate from character state changes. Offline input can directly control the local player; multiplayer input can later be accepted from a network participant.

### Class

Defines class-specific behavior and data for:

- Knight
- Archer
- Mage

Class data should not be embedded in town or expedition scenes. A class provides stats, abilities, and combat rules to a player character.

### Party

Represents the group entering an expedition.

Responsibilities:

- Track members
- Track selected expedition
- Track party readiness
- Start the expedition
- Receive the expedition result

Initial target: maximum four members. Offline mode can treat the local player as a one-member party.

### Expedition state

Tracks only the current expedition:

- Expedition identifier
- Selected map or mission
- Party members
- Current objective
- Defeated enemies and completed objectives
- Boss state
- Completion or failure state

Expedition state must be separate from permanent player progression. Returning to town converts the expedition result into rewards and progression changes.

### Reward result

The expedition should produce a result instead of directly modifying every player system.

Result contains:

- Success or failure
- Experience gained
- Items gained
- Currency gained
- Unlocks earned

Offline mode applies the result locally. Future multiplayer mode can validate and apply the result from the party expedition authority.

## Data flow

### Offline flow

1. Player loads saved progression in town.
2. Player selects an expedition.
3. Game creates a one-member party.
4. Game creates an expedition state.
5. Player explores and fights.
6. Expedition produces a reward result.
7. Game applies the result to player progression.
8. Player returns to town and saves.

### Future multiplayer flow

1. Players connect to a town instance.
2. One player creates or joins a party.
3. Party members select an expedition and ready up.
4. An expedition instance is created for that party.
5. The authoritative game state validates movement, combat, objectives, and rewards.
6. Clients receive the resulting state and display it.
7. Expedition completion creates one result per party member.
8. Players return to town and receive validated rewards.

The offline flow must remain usable without a network connection. The multiplayer flow changes ownership and transport, not the meaning of player, party, expedition, or reward data.

## Scene boundaries

Recommended scene responsibilities:

- `Town`: town map and town interactions
- `Expedition`: expedition map and encounter placement
- `Player`: character presentation, input adapter, and movement hooks
- `Combat`: attacks, hit detection, damage, status effects
- `Party`: party membership and readiness state
- `Progression`: saved character and reward data

Keep maps responsible for placement and presentation. Keep combat, progression, and expedition rules outside map-specific scripts so the same rules can run offline and later under multiplayer authority.

## Development order

1. Define player, class, party, expedition, and reward data boundaries.
2. Complete movement and camera feel offline.
3. Implement Knight, Archer, and Mage basic combat.
4. Build one complete expedition.
5. Add town return, rewards, and save/load.
6. Test cooperation with a second local character or temporary AI companion.
7. Add online room creation and party joining.
8. Synchronize player movement and combat.
9. Synchronize expedition lifecycle and reward results.
10. Add reconnection and failure handling.

## Explicitly deferred

- Matchmaking
- Persistent shared-world simulation
- PvP
- Trading
- Guilds
- Dedicated-server operations
- Unlimited players in one physical town instance
- Cross-platform account systems

These systems should be added only after one offline expedition and one online co-op expedition are fun and stable.

## Success criteria

The structure is working when:

- One player can complete an expedition offline.
- A player can return to town with rewards.
- The same expedition rules do not depend on the town scene.
- Permanent progression is not stored inside temporary expedition state.
- A future party member can be added without rewriting class or reward rules.
- Multiplayer can replace local ownership and input transport without changing the player-facing game loop.
