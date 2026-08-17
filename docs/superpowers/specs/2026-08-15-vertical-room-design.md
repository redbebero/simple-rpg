# Vertical Room Design

## Goal

Keep side-view combat while adding simple vertical exploration through platforms, ledges, and room boundaries.

## Design

- Each dungeon room is a separate scene.
- Map geometry uses reusable rectangular `StaticBody2D` room pieces.
- Visual geometry is drawn by the same piece, so prototype collision and display cannot drift.
- Enemy gameplay stays one `CharacterBody2D`; its visible body becomes reusable rectangle/circle drawing with movement-based squash, lean, and weapon motion.
- Hitstop pauses physics but keeps combat input in `CombatComponent` running in `PROCESS_MODE_ALWAYS`.
- Press/release events received during hitstop enter a short FIFO buffer and execute after pause ends.

## First slice

One vertical combat room with floor, two platforms, and side walls. No procedural generation, tilemap, ladder, or art assets yet.
