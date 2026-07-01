local SmartLocalAiRestockDirectorPatch = require 'monkey_patches.smart_local_ai_restock_director'
local SmartLocalAiSettings = require 'lib.settings'
local SmartLocalAiState = require 'lib.state'
local RestockDirector = radiant.mods.require('stonehearth.services.server.inventory.restock_director')
local settings = SmartLocalAiSettings.get()

SmartLocalAiRestockDirectorPatch._ace_old__get_max_errands = RestockDirector._get_max_errands
radiant.mixin(RestockDirector, SmartLocalAiRestockDirectorPatch)

SmartLocalAiState.log_patch_state(settings, {
   'restock_director',
   'pickup_item_type',
   'find_reachable_entity_type_anywhere',
   'find_reachable_storage_containing_best_entity_type',
   'fill_backpack_from_items',
   'drop_and_pickup_item_type',
   'rest_when_injured',
})

radiant.log.write_('smart_local_ai', 0, 'Smart Local AI server patch loaded: restock mode = ' .. settings.restock_mode)
