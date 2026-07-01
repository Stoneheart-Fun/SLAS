# Changelog

All notable changes to `Smart Local AI` are documented here.

## [0.2.0] - 2026-07-01

### Added

- added a centralized settings loader in `smart_local_ai/lib/settings.lua`
- added profile-based search tuning with `SAFE`, `BALANCED`, and `AGGRESSIVE` presets
- added lightweight runtime state and counters in `smart_local_ai/lib/state.lua`
- added patch-state startup logging for easier validation in game logs
- added aggregate search statistics logging controlled by settings
- added explicit `restock_mode` support with `disabled`, `throttle`, and `vanilla`

### Changed

- connected the currently implemented action overrides in `smart_local_ai/manifest.json`
- updated local search to use a per-stage candidate budget instead of one shared budget across all stages
- destroyed active item finders more consistently after result selection or stage exhaustion
- moved search and restock code to the shared settings layer instead of reloading JSON in each file
- expanded debug logging for staged search flow, candidate exhaustion, and selected results
- updated `README.md` to document the current settings surface and remove the broken local worktree path

### Fixed

- fixed a wiring gap where multiple action files existed in the repo but were not registered through the manifest
- fixed staged fallback behavior so expanded/global passes are no longer starved after an expensive local pass

## [0.1.0] - 2026-06-30

### Added

- initial standalone `Smart Local AI` mod structure for Stonehearth ACE
- staged local-first search through `smart_local_ai:find_best_local_reachable_entity_by_type`
- radius-based search settings with local, expanded, and fallback passes
- pickup and fetch-oriented action replacements built around local-first target selection
- restock director patch for errand suppression or throttling
- optional debug toggle in settings
- custom `rest_when_injured` override currently shipped in the mod
- `README.md`, `roadmap.md`, and `changelog.md`

### Repository

- standardized the local reference directory as `game_files/`
- kept `game_files/` outside Git tracking for local research only
