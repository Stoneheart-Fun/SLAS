local SmartLocalAiRestockDirectorPatch = require 'monkey_patches.smart_local_ai_restock_director'
local SmartLocalAiDiagnostics = require 'lib.diagnostics'
local SmartLocalAiLogger = require 'lib.logger'
local SmartLocalAiSettings = require 'lib.settings'
local SmartLocalAiState = require 'lib.state'
local RestockDirector = radiant.mods.require('stonehearth.services.server.inventory.restock_director')
local settings = SmartLocalAiSettings.get()

SmartLocalAiRestockDirectorPatch._ace_old__get_max_errands = RestockDirector._get_max_errands
radiant.mixin(RestockDirector, SmartLocalAiRestockDirectorPatch)

local function _start_slas_runtime()
   SmartLocalAiLogger.info(
      '[SLAS] settings loaded profile=%s diagnostics=%s restock_mode=%s local=%s expanded=%s max_items=%s',
      tostring(settings.search_profile),
      tostring(settings.diagnostics_enabled),
      tostring(settings.restock_mode),
      tostring(settings.local_radius),
      tostring(settings.expanded_radius),
      tostring(settings.max_items_to_examine)
   )
   SmartLocalAiState.log_patch_state(settings, {
      'restock_director',
      'pickup_item_type',
      'find_reachable_entity_type_anywhere',
      'find_reachable_storage_containing_best_entity_type',
      'fill_backpack_from_items',
      'drop_and_pickup_item_type',
      'rest_when_injured',
   })
   SmartLocalAiDiagnostics:get():start()
   SmartLocalAiLogger.info('Smart Local AI server patch loaded: restock mode = %s', settings.restock_mode)
end

if radiant and radiant.events and radiant.events.listen_once then
   radiant.events.listen_once(radiant, 'radiant:init', _start_slas_runtime)
else
   _start_slas_runtime()
end
