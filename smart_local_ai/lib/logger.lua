local SmartLocalAiSettings = require 'lib.settings'

local Logger = {}

local log = radiant.log.create_logger('smart_local_ai')

local function _stringify(value)
   if value == nil then
      return 'nil'
   end

   if type(value) == 'boolean' then
      return value and 'true' or 'false'
   end

   return tostring(value)
end

local function _format_payload(payload, ordered_keys)
   local parts = {}
   local used = {}
   local extra_parts = {}

   if ordered_keys then
      for _, key in ipairs(ordered_keys) do
         if payload[key] ~= nil then
            parts[#parts + 1] = key .. '=' .. _stringify(payload[key])
            used[key] = true
         end
      end
   end

   for key, value in pairs(payload) do
      if not used[key] then
         extra_parts[#extra_parts + 1] = key .. '=' .. _stringify(value)
      end
   end

   table.sort(extra_parts)
   for _, part in ipairs(extra_parts) do
      parts[#parts + 1] = part
   end

   return table.concat(parts, ' ')
end

function Logger.info(message, ...)
   log:info(message, ...)
end

function Logger.warn(message, ...)
   log:warning(message, ...)
end

function Logger.error(message, ...)
   log:error(message, ...)
end

function Logger.override_active(name)
   local SmartLocalAiState = require 'lib.state'
   SmartLocalAiState.register_override(name)
   local settings = SmartLocalAiSettings.get()
   if settings.log_loaded_overrides then
      log:info('[SLAS] override active: %s', tostring(name))
   end
end

function Logger.summary(payload)
   log:info('[SLAS:SUMMARY] %s', _format_payload(payload, {
      'time',
      'game_day',
      'settlers',
      'items_total',
      'storage_entities',
      'search_calls',
      'fallback_calls',
      'failed_searches',
      'restock_allowed',
      'restock_blocked',
      'restock_current_limit',
      'avg_candidates',
      'max_candidates',
      'profile',
      'overrides',
   }))
end

function Logger.heavy_search(payload)
   log:info('[SLAS:HEAVY_SEARCH] %s', _format_payload(payload, {
      'time',
      'action',
      'stage',
      'candidates',
      'result',
      'reason',
   }))
end

function Logger.failed_search(payload)
   log:warning('[SLAS:FAILED_SEARCH] %s', _format_payload(payload, {
      'time',
      'action',
      'stage',
      'candidates',
      'fallback',
      'result',
      'reason',
   }))
end

function Logger.fallback(payload)
   log:info('[SLAS:FALLBACK] %s', _format_payload(payload, {
      'time',
      'action',
      'stage',
      'candidates',
      'reason',
   }))
end

return Logger
