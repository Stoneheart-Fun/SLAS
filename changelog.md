# Changelog

All notable changes to `Smart Local AI` are documented here.

## [0.3.0] - 2026-07-02

### Added

- added a structured diagnostics layer through `smart_local_ai/lib/logger.lua` and `smart_local_ai/lib/diagnostics.lua`
- added periodic `[SLAS:SUMMARY]` output with settlement, search, fallback, and restock counters
- added `[SLAS:HEAVY_SEARCH]`, `[SLAS:FAILED_SEARCH]`, and `[SLAS:FALLBACK]` events for staged search analysis
- added loaded-override tracking so diagnostics can report which SLAS overrides actually initialized
- added nested-settings compatibility for `diagnostics`, `local_search`, `restock`, and `debug` sections while keeping flat-key support

### Changed

- expanded diagnostics coverage from the local finder into `find_reachable_entity_type_anywhere`
- moved startup logging to a clearer runtime boot sequence with explicit `[SLAS] settings loaded` output
- extended restock metrics to report current throttled errand limit and available worker-derived capacity
- included loaded override names and current restock limit in diagnostics summaries

### Fixed

- fixed nested `restock.mode` normalization so future config migration does not silently fall back to the wrong mode
- fixed patch-state reporting so override visibility is captured from the shared runtime state instead of relying on guesswork

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
