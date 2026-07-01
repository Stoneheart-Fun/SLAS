local State = {}

local log = radiant.log.create_logger('smart_local_ai')
local _counters = {
   searches_started = 0,
   search_results_found = 0,
   fallback_results_found = 0,
   stage_exhaustions = 0,
   search_failures = 0,
   restock_max_errands_calls = 0,
}
local _last_search_summary_at = 0

local function _counter(name)
   _counters[name] = _counters[name] or 0
   return _counters[name]
end

function State.increment(name, amount)
   _counters[name] = _counter(name) + (amount or 1)
end

function State.get_snapshot()
   local snapshot = {}
   for name, value in pairs(_counters) do
      snapshot[name] = value
   end
   return snapshot
end

function State.log_patch_state(settings, patch_points)
   if not settings.log_patch_state then
      return
   end

   local patch_summary = patch_points and table.concat(patch_points, ', ') or 'none'
   log:info(
      'state profile=%s local=%s expanded=%s fallback=%s max_items=%s restock_mode=%s restock_range=%s-%s patches=%s',
      tostring(settings.search_profile),
      tostring(settings.local_radius),
      tostring(settings.expanded_radius),
      tostring(settings.global_fallback),
      tostring(settings.max_items_to_examine),
      tostring(settings.restock_mode),
      tostring(settings.min_concurrent_restock_errands),
      tostring(settings.max_concurrent_restock_errands),
      patch_summary
   )
end

function State.maybe_log_search_summary(settings)
   if not settings.log_search_stats then
      return
   end

   local searches_started = _counter('searches_started')
   local interval = tonumber(settings.search_log_interval) or 50
   if searches_started == 0 or searches_started % interval ~= 0 or searches_started == _last_search_summary_at then
      return
   end

   _last_search_summary_at = searches_started
   log:info(
      'search summary searches=%s found=%s fallback=%s exhausted=%s failed=%s',
      tostring(searches_started),
      tostring(_counter('search_results_found')),
      tostring(_counter('fallback_results_found')),
      tostring(_counter('stage_exhaustions')),
      tostring(_counter('search_failures'))
   )
end

return State
