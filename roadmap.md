# Roadmap

## Goal

Turn `Smart Local AI` into a performance lab for Stonehearth ACE that follows a strict order:

```txt
log -> metric -> small patch -> test -> compare -> next patch
```

The project should improve AI, item search, storage, and restock-heavy scenarios without silently breaking gameplay or save stability.

## Development Principles

- measure before optimizing
- keep every subsystem toggleable through settings
- prefer safe fallback over clever failure
- separate diagnostics from gameplay-changing patches
- treat native runtime work as research, not implementation
- keep compatibility with vanilla and ACE behavior as the default guardrail

## Current State

### Already In Place

- manifest wiring for the current local-search and pickup/fetch action overrides
- staged local-first search with `local`, `expanded`, and `fallback` passes
- per-stage candidate budget for local search
- shared settings loader and profile-aware settings normalization
- lightweight runtime state counters and startup patch-state logging
- restock director patch with explicit `disabled`, `throttle`, and `vanilla` modes
- user-facing `README.md`, versioned `changelog.md`, and local research folder in `game_files/`

### Confirmed Done From Older Task Lists

These items should not be treated as open implementation tasks anymore:

- manifest/override confirmation work
- startup patch-state logging
- per-stage `max_items_to_examine` logic
- baseline local-search stage logging

## New Technical Direction

The roadmap now follows the new technical spec and is split into three tracks:

1. `Diagnostics`
2. `Lua Optimization Layer`
3. `Native Runtime Research`

The order matters:

- first observe
- then validate
- then optimize
- only after that expand scope

## Spec Alignment Notes

### 1. Restock Default Is Not Settled Yet

The new spec proposes a throttle-first default, but the current shipped settings still default to disabled restock.

Roadmap decision:

- do not silently flip the default in the next code change
- treat any restock default change as a versioned migration
- document it in `changelog.md` before changing user-facing behavior

### 2. Settings Migration Must Be Explicit

The current mod uses a mostly flat settings structure.  
The new spec proposes nested sections such as:

- `diagnostics`
- `local_search`
- `restock`
- `storage_index`
- `ai_throttle`
- `native_runtime`
- `debug`

Roadmap decision:

- migrate in phases
- support old flat keys during transition
- only remove flat compatibility after the nested structure is fully adopted

### 3. Search Result Caching Is Deferred

The spec mentions `cache_results` and `cache_ttl_seconds` for local search, but the invalidation rules are not yet strong enough.

Roadmap decision:

- do not implement query-result caching for live item searches yet
- keep this behind a separate design/research step
- only move forward once invalidation and race safety are specified as clearly as `storage_index`

## Phases

## Phase 1: Diagnostics Foundation

Goal:
build a non-invasive measurement layer before any major new optimization patch.

Tasks:

- add a dedicated diagnostics/logger module
- define structured summary, heavy-search, failed-search, and fallback log formats
- collect counters for:
  - settlers
  - items
  - storage entities
  - search calls
  - fallback calls
  - failed searches
  - restock blocked/allowed
- ensure diagnostics can run for long sessions without becoming a source of lag

Definition of done:

- diagnostics are toggleable
- logs are readable and stable
- gameplay is unchanged with diagnostics alone
- logs provide enough data for before/after comparisons

## Phase 2: Current Local Search Validation

Goal:
prove that the existing local-search layer is actually active and behaving as intended under ACE.

Tasks:

- audit all current overrides against live `game_files/stonehearth` and `game_files/stonehearth_ace`
- confirm which AI paths really hit the SLAS actions in game
- expand search counters to fetch/storage-related paths, not just the current local finder
- log stage usage, fallback frequency, and failure frequency in a form suitable for comparison
- build a repeatable smoke-test checklist for near/far item choice and not-found cases

Definition of done:

- override activity is confirmed in logs
- affected call paths are mapped
- fallback behavior is verified, not assumed
- there is a baseline dataset for later optimization work

## Phase 3: Restock Behavior Stabilization

Goal:
turn the current restock patch into a measured and configurable subsystem instead of a blunt workaround.

Tasks:

- decide and document the intended default restock mode
- add better logging for:
  - restock mode
  - current allowed errand count
  - blocked/limited restock behavior
- validate the effect of throttle vs disabled vs vanilla across small and crowded settlements
- separate restock evaluation from local-search evaluation in logs and test notes

Definition of done:

- restock no longer acts as a hidden behavior change
- user-facing defaults are intentional
- restock impact can be compared independently from search impact

## Phase 4: Settings Migration

Goal:
move from the current flat config surface to the nested technical-spec structure without breaking existing users abruptly.

Tasks:

- introduce nested settings sections in `data/settings.json`
- keep compatibility with flat keys during migration
- update all action and patch files to use nested settings access
- add migration notes to `README.md` and `changelog.md`
- define when flat-key support can be removed

Definition of done:

- nested config works end to end
- old config still loads during transition
- no action reads stale or duplicated values from two competing structures

## Phase 5: Storage Index Diagnostics Prototype

Goal:
build storage indexing first as an observability tool, not as a gameplay authority.

Tasks:

- collect storage summaries and item-type counts
- add TTL/rebuild interval behavior
- log index contents and rebuild cadence
- never replace vanilla search with index results in this first step

Definition of done:

- index data can be inspected in logs
- rebuild behavior is stable
- the index does not affect gameplay yet

## Phase 6: Storage Index Assisted Search

Goal:
use storage index information to reduce unnecessary search work while preserving safe vanilla fallback.

Tasks:

- let local-search paths consult the storage index before broader scans
- keep hard fallback to vanilla/ACE behavior
- validate stale-index safety cases explicitly
- measure candidate reduction before claiming a performance win

Definition of done:

- candidate counts drop in measured scenarios
- fallback remains intact
- stale index cases do not hide valid items permanently

## Phase 7: AI Throttle Research

Goal:
reduce non-critical AI churn without creating "dead" hearthlings.

Tasks:

- log social/idle/decorative action frequency first
- identify safe throttle candidates
- explicitly exclude:
  - eating
  - sleeping
  - medical
  - combat
  - fleeing
  - urgent hauling
- prototype throttle only after logging validates the target actions

Definition of done:

- critical AI remains untouched
- non-critical behavior is measurably reduced
- settlers still feel alive and responsive

## Phase 8: Native Runtime Probe

Goal:
treat native runtime work as capability research only.

Tasks:

- inspect Lua/runtime constraints
- test whether native module loading is possible
- perform a minimal `ping/pong` probe only
- record the result as:
  - viable
  - blocked
  - requires deeper binary patching

Definition of done:

- the feasibility question is answered
- no production optimization depends on native runtime yet

## Test Strategy

All future optimization work should be compared across:

- vanilla Stonehearth
- ACE only
- ACE + SLAS SAFE
- ACE + SLAS BALANCED
- ACE + SLAS AGGRESSIVE

Reference scenarios:

- small town / low item count
- medium town / moderate item count
- stress town / high item count
- freeze-boundary town / very high item count

Track at minimum:

- fallback count
- failed searches
- max candidates
- search stage distribution
- restock pressure
- visible AI stalls

## Immediate Next Priorities

1. build the diagnostics/logger layer from the new spec
2. validate the currently wired overrides against live ACE call paths
3. decide the migration policy for restock defaults
4. design flat-to-nested settings compatibility before broader refactors
5. postpone search-result caching until invalidation rules are explicit

## Non-Goals For Now

- rewriting all AI systems at once
- replacing pathfinding wholesale
- aggressive binary patching before diagnostics maturity
- shipping native C++ optimization before Lua-layer evidence exists
- claiming performance wins without before/after data
