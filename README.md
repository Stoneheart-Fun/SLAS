# Smart Local AI

`Smart Local AI` is a Stonehearth ACE performance mod and research lab focused on one rule:

```txt
log -> metric -> small patch -> test -> compare -> next patch
```

The mod is not trying to rewrite all of Stonehearth at once.  
Its purpose is to reduce costly AI search, storage-heavy item lookup, and restock pressure while keeping fallback behavior intact.

## Project Direction

The project now has three tracks:

- `Diagnostics`: observe without changing gameplay
- `Lua Optimization Layer`: controlled AI, search, and storage patches
- `Native Runtime Research`: future capability probing only

This means new optimization work should start with measurement, not intuition.

## Current Scope

The current shipped code focuses on:

- staged local-first search for reachable entities
- pickup/fetch-related action overrides
- configurable restock throttling or suppression
- startup patch-state logging
- lightweight search and restock counters

## What It Does

- tries nearby valid targets before broader scans
- expands search in stages: `local -> expanded -> fallback`
- keeps global fallback available instead of hard-failing the action path
- exposes conservative profile-based tuning
- logs active patch state and optional diagnostics events

## What It Does Not Do

- it does not replace the full inventory service
- it does not replace the full storage service
- it does not yet ship a production storage index
- it does not yet throttle broad AI behavior outside the current search/restock scope
- it does not ship native runtime optimization

## Compatibility

- target game: `Stonehearth`
- required mod environment: `ACE`
- dependencies: `stonehearth`, `stonehearth_ace`, `radiant`

## Settings

Current settings live in `smart_local_ai/data/settings.json`.

Example:

```json
{
  "search_profile": "BALANCED",
  "diagnostics_enabled": false,
  "diagnostics_player_id": "player_1",
  "diagnostics_log_interval_seconds": 60,
  "diagnostics_log_file_name": "slas_diagnostics.log",
  "diagnostics_log_heavy_searches": true,
  "diagnostics_heavy_search_candidate_threshold": 300,
  "diagnostics_log_failed_searches": true,
  "diagnostics_log_fallbacks": true,
  "local_radius": 32,
  "expanded_radius": 64,
  "global_fallback": true,
  "max_items_to_examine": 140,
  "debug_enabled": false,
  "log_loaded_overrides": true,
  "log_search_stats": false,
  "log_patch_state": true,
  "search_log_interval": 50,
  "enable_for_hauling": true,
  "enable_for_fetching": true,
  "enable_for_restocking": false,
  "restock_mode": "disabled",
  "disable_restock_errands": true,
  "enable_restock_throttle": true,
  "max_concurrent_restock_errands": 0,
  "restock_workers_per_errand": 12,
  "min_concurrent_restock_errands": 0
}
```

## Profiles

`search_profile` controls conservative defaults for radius and per-stage search budget:

- `SAFE`
- `BALANCED`
- `AGGRESSIVE`

The current implementation still uses a mostly flat settings structure.  
The long-term roadmap moves toward nested sections such as `diagnostics`, `local_search`, `restock`, and `storage_index`.

The current code now accepts both:

- flat keys for backward compatibility
- nested sections for migration work

## Restock Behavior

`restock_mode` accepts:

- `disabled`
- `throttle`
- `vanilla`

Important: the roadmap and technical spec are still deciding what the long-term default should be.  
The current shipped default remains `disabled`, and any change to that default should be treated as a migration note, not a silent behavior flip.

## Diagnostics

Phase 1 diagnostics are intended to be non-invasive.

When enabled, the mod can emit structured log events such as:

- `[SLAS:SUMMARY]`
- `[SLAS:HEAVY_SEARCH]`
- `[SLAS:FAILED_SEARCH]`
- `[SLAS:FALLBACK]`

Current summary output includes:

- profile
- settlers
- approximate item count
- public storage entity count
- search and fallback counters
- failed searches
- restock allowed/blocked counts
- current restock limit
- loaded override names

The purpose is to produce comparison data before more aggressive optimization work lands.

## Known Limitations

- current override coverage still needs live validation against actual ACE call paths
- diagnostics are still early and should be treated as baseline instrumentation
- search-result caching is intentionally deferred until invalidation rules are clearly specified
- storage index work is still planned as a staged prototype, not a gameplay authority

## Repository Notes

- `game_files/` is for local reference and research
- active mod code lives under `smart_local_ai/`
- project direction is tracked in `roadmap.md`
- release history is tracked in `changelog.md`
