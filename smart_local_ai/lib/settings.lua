local Settings = {}

local DEFAULT_SETTINGS = {
   search_profile = 'BALANCED',
   local_radius = 32,
   expanded_radius = 64,
   global_fallback = true,
   max_items_to_examine = 140,
   debug_enabled = false,
   log_search_stats = false,
   log_patch_state = true,
   search_log_interval = 50,
   enable_for_hauling = true,
   enable_for_fetching = true,
   enable_for_restocking = false,
   restock_mode = 'disabled',
   disable_restock_errands = true,
   enable_restock_throttle = true,
   max_concurrent_restock_errands = 0,
   restock_workers_per_errand = 12,
   min_concurrent_restock_errands = 0,
}

local PROFILE_SETTINGS = {
   SAFE = {
      local_radius = 24,
      expanded_radius = 48,
      max_items_to_examine = 80,
      global_fallback = true,
   },
   BALANCED = {
      local_radius = 32,
      expanded_radius = 64,
      max_items_to_examine = 140,
      global_fallback = true,
   },
   AGGRESSIVE = {
      local_radius = 48,
      expanded_radius = 96,
      max_items_to_examine = 220,
      global_fallback = true,
   },
}

local _cached_settings = nil

local function _copy_keys(destination, source)
   if not source then
      return
   end

   for key, value in pairs(source) do
      destination[key] = value
   end
end

local function _normalize_restock_mode(settings, raw_settings)
   local restock_mode = raw_settings.restock_mode
   if restock_mode == nil then
      if raw_settings.disable_restock_errands then
         restock_mode = 'disabled'
      elseif raw_settings.enable_restock_throttle == false then
         restock_mode = 'vanilla'
      else
         restock_mode = 'throttle'
      end
   end

   if restock_mode ~= 'disabled' and restock_mode ~= 'throttle' and restock_mode ~= 'vanilla' then
      restock_mode = DEFAULT_SETTINGS.restock_mode
   end

   settings.restock_mode = restock_mode
   settings.disable_restock_errands = restock_mode == 'disabled'
   settings.enable_restock_throttle = restock_mode == 'throttle'
end

local function _normalize_settings(raw_settings)
   raw_settings = raw_settings or {}

   local settings = {}
   _copy_keys(settings, DEFAULT_SETTINGS)

   local profile_name = tostring(raw_settings.search_profile or DEFAULT_SETTINGS.search_profile):upper()
   if not PROFILE_SETTINGS[profile_name] then
      profile_name = DEFAULT_SETTINGS.search_profile
   end

   settings.search_profile = profile_name
   _copy_keys(settings, PROFILE_SETTINGS[profile_name])
   _copy_keys(settings, raw_settings)
   _normalize_restock_mode(settings, raw_settings)

   settings.local_radius = tonumber(settings.local_radius) or DEFAULT_SETTINGS.local_radius
   settings.expanded_radius = tonumber(settings.expanded_radius) or DEFAULT_SETTINGS.expanded_radius
   settings.max_items_to_examine = tonumber(settings.max_items_to_examine) or DEFAULT_SETTINGS.max_items_to_examine
   settings.max_concurrent_restock_errands = tonumber(settings.max_concurrent_restock_errands)
      or DEFAULT_SETTINGS.max_concurrent_restock_errands
   settings.restock_workers_per_errand = tonumber(settings.restock_workers_per_errand)
      or DEFAULT_SETTINGS.restock_workers_per_errand
   settings.min_concurrent_restock_errands = tonumber(settings.min_concurrent_restock_errands)
      or DEFAULT_SETTINGS.min_concurrent_restock_errands
   settings.search_log_interval = tonumber(settings.search_log_interval) or DEFAULT_SETTINGS.search_log_interval
   settings.global_fallback = settings.global_fallback ~= false
   settings.debug_enabled = settings.debug_enabled and true or false
   settings.log_search_stats = settings.log_search_stats and true or false
   settings.log_patch_state = settings.log_patch_state ~= false
   settings.enable_for_hauling = settings.enable_for_hauling ~= false
   settings.enable_for_fetching = settings.enable_for_fetching ~= false
   settings.enable_for_restocking = settings.enable_for_restocking and true or false

   return settings
end

function Settings.reload()
   local raw_settings = radiant.resources.load_json('smart_local_ai:data:settings', true, false) or {}
   _cached_settings = _normalize_settings(raw_settings)
   return _cached_settings
end

function Settings.get()
   if not _cached_settings then
      return Settings.reload()
   end

   return _cached_settings
end

function Settings.get_profile_settings(profile_name)
   return PROFILE_SETTINGS[profile_name]
end

return Settings
