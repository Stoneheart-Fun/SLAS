local SmartLocalAiRestockDirectorPatch = {}
local SmartLocalAiSettings = require 'lib.settings'
local SmartLocalAiState = require 'lib.state'

local function _clamp(value, min_value, max_value)
   if min_value and value < min_value then
      value = min_value
   end
   if max_value and value > max_value then
      value = max_value
   end
   return value
end

function SmartLocalAiRestockDirectorPatch:_get_max_errands()
   local settings = SmartLocalAiSettings.get()
   SmartLocalAiState.increment('restock_max_errands_calls')

   if settings.restock_mode == 'disabled' then
      return 0
   end

   if settings.restock_mode ~= 'throttle' then
      return self:_ace_old__get_max_errands()
   end

   local town = stonehearth.town:get_town(self._player_id)
   if not town then
      return self:_ace_old__get_max_errands()
   end

   local task_group = town:get_task_group('stonehearth:task_groups:restock')
   if not task_group then
      return self:_ace_old__get_max_errands()
   end

   local workers = task_group:get_workers()
   local disabled_workers = task_group:get_disabled_workers()
   local available_workers = math.max(0, radiant.size(workers) - radiant.size(disabled_workers))

   local workers_per_errand = tonumber(settings.restock_workers_per_errand) or 3
   if workers_per_errand < 1 then
      workers_per_errand = 1
   end

   local max_errands = math.ceil(available_workers / workers_per_errand)
   max_errands = _clamp(
      max_errands,
      tonumber(settings.min_concurrent_restock_errands) or 1,
      tonumber(settings.max_concurrent_restock_errands) or 4
   )

   return math.max(0, max_errands)
end

return SmartLocalAiRestockDirectorPatch
