# Character Motion and Silhouette Polish Plan

**Goal:** Restore readable animation, give attacks a continuous fantasy sword path, and make the player read as one coherent character.

**Approach:** Use one local-facing convention, keep gameplay timing unchanged, and drive a shared procedural skeleton from compact attack keyframes. Weapons get separate drawing/hand behavior while the body keeps one persistent silhouette.

### Task 1: Lock visual invariants

- Add tests for one-time mirroring, weapon-tip direction, and recovery continuing past impact.
- Run them red before changing the rig.

### Task 2: Fix the motion coordinate system

- Make local `+X` the facing direction everywhere.
- Remove the negative facing inversion and the second weapon-side mirror.
- Add a follow-through keyframe and interpolate recovery through it.
- Apply authored squash values and remove dead duplicate assignments.

### Task 3: Give each weapon its own motion language

- Knight uses a grip-to-tip sword arc and sampled trail.
- Archer uses a draw/release/recoil bow path.
- Mage uses a staff/orb casting path with a visible charge point.
- Keep the existing combat hit timings and projectile logic.

### Task 4: Make one character, not three colored primitives

- Keep one shared head, torso, cloak, belt, boots, and face highlight.
- Add restrained class identity through silhouette and weapon: shoulder/shield, hood/quiver/bow, robe/hood/staff.
- Keep the palette to outline, body, accent, and highlight.

### Task 5: Verify

- Run focused visual tests, all SceneTree tests, and headless editor startup.
- Manually inspect each class through the existing game scene before calling the work complete.
