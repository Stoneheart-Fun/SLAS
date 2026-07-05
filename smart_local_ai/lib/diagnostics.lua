local SmartLocalAiLogger = require 'lib.logger'
local SmartLocalAiSettings = require 'lib.settings'
local SmartLocalAiState = require 'lib.state'

local Diagnostics = class()

local _instance = nil

local function _safe_size(collection)
   if not collection then
      return 0
   end

   local ok, size = pcall(radiant.size, collection)
   if ok and size then
      return size
   end

   return 0
end

function Diagnostics:get()
   if not _instance then
      _instance = Diagnostics()
   end

   return _instance
end

function Diagnostics:start()
   local settings = SmartLocalAiSettings.get()
   self._settings = settings
   if not settings.diagnostics_enabled then
      return false
   end

   if self._heartbeat then
      return true
   end

   local interval = tostring(settings.diagnostics_log_interval_seconds or 60) .. 's'
   if stonehearth and stonehearth.calendar and stonehearth.calendar.set_interval then
      self._heartbeat = stonehearth.calendar:set_interval('slas diagnostics summary', interval, function()
            self:_emit_summary()
         end)
      SmartLocalAiLogger.info('[SLAS] diagnostics active interval=%s target=%s file=%s',
         interval,
         tostring(settings.diagnostics_player_id),
         tostring(settings.diagnostics_log_file_name))
      self:_emit_summary()
      return true
   end

   SmartLocalAiLogger.warn('[SLAS] diagnostics requested but no interval scheduler was available')
   return false
end

function Diagnostics:_emit_summary()
   local settings = SmartLocalAiSettings.get()
   local snapshot = SmartLocalAiState.get_snapshot()
   local player_id = settings.diagnostics_player_id or 'player_1'

   local settlers = 0
   local items_total = 0
   local storage_entities = 0
   local game_day = nil
   local time_now = nil

   if stonehearth and stonehearth.calendar then
      if stonehearth.calendar.get_elapsed_days then
         game_day = stonehearth.calendar:get_elapsed_days()
      end
      if stonehearth.calendar.get_elapsed_time then
         time_now = stonehearth.calendar:get_elapsed_time()
      end
   end

   if stonehearth and stonehearth.population and stonehearth.population.get_population then
      local ok, population = pcall(stonehearth.population.get_population, stonehearth.population, player_id)
      if ok and population then
         if population.get_citizen_count then
            local ok_count, citizen_count = pcall(population.get_citizen_count, population)
            if ok_count and citizen_count then
               settlers = citizen_count
            end
         elseif population.get_citizens then
            local ok_citizens, citizens = pcall(population.get_citizens, population)
            if ok_citizens and citizens and citizens.get_size then
               local ok_size, size = pcall(citizens.get_size, citizens)
               if ok_size and size then
                  settlers = size
               end
            end
         end
      end
   end

   if stonehearth and stonehearth.inventory and stonehearth.inventory.get_inventory then
      local ok, inventory = pcall(stonehearth.inventory.get_inventory, stonehearth.inventory, player_id)
      if ok and inventory then
         if inventory.get_all_items then
            local ok_items, items = pcall(inventory.get_all_items, inventory)
            if ok_items then
               items_total = _safe_size(items)
            end
         end
         if inventory.get_all_public_storage then
            local ok_storage, storages = pcall(inventory.get_all_public_storage, inventory)
            if ok_storage then
               storage_entities = _safe_size(storages)
            end
         end
      end
   end

   local search_calls = snapshot.search_calls or snapshot.searches_started or 0
   local avg_candidates = 0
   if search_calls > 0 then
      avg_candidates = math.floor((snapshot.total_candidates_examined or 0) / search_calls)
   end

   SmartLocalAiLogger.summary({
      time = time_now,
      game_day = game_day,
      settlers = settlers,
      items_total = items_total,
      storage_entities = storage_entities,
      search_calls = search_calls,
      fallback_calls = snapshot.fallback_calls or snapshot.fallback_results_found or 0,
      failed_searches = snapshot.failed_searches or snapshot.search_failures or 0,
      restock_allowed = snapshot.restock_allowed or 0,
      restock_blocked = snapshot.restock_blocked or 0,
      restock_current_limit = snapshot.restock_current_limit or 0,
      avg_candidates = avg_candidates,
      max_candidates = snapshot.max_candidates_examined or 0,
      profile = settings.search_profile,
      overrides = table.concat(snapshot.loaded_overrides or {}, ','),
   })
end

return Diagnostics
