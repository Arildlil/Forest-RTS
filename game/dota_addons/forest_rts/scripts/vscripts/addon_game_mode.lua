print("Welcome to Forest RTS!")

if CustomGameMode == nil then
	_G.CustomGameMode = class({})
end

require('utilities')
--require('upgrades')
require('mechanics')
require('orders')
require('builder')
require('buildinghelper')

require('libraries/timers')
require('libraries/popups')
require('libraries/notifications')



---------------------------------------------------------------------------
-- Precache
---------------------------------------------------------------------------
function Precache( context )
	print("Precache starting...")

	-- BuildingHelper Precaches
	PrecacheItemByNameSync("item_apply_modifiers", context)
	-- Model ghost and grid particles
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheResource("particle_folder", "particles/econ/items/earthshaker/earthshaker_gravelmaw/", context)

	-- Dropped item model
	PrecacheResource("model", "models/chest_worlddrop.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf", context)

	-- Fire projectile
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_base_attack.vpcf", context)

	-- Searing Arrows
	PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", context)

	-- Liquid Fire
	PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff_light.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", context)

	-- Soldiers
	--PrecacheResource("model", "models/creeps/lane_creeps/creep_good_melee/creep_good_melee.vmdl", context)
	--PrecacheResource("model", "models/creeps/lane_creeps/creep_good_ranged/creep_good_ranged.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl", context)

	-- Hero items
	PrecacheResource("model", "models/items/dragon_knight/shield_timedragon.vmdl", context)

	-- Buildings
	   -- Tower
	PrecacheResource("model", "models/props_structures/wooden_sentry_tower001.vmdl", context)
	   -- Temporary Mining Crystal
	PrecacheResource("model", "models/props_structures/good_base_wall006.vmdl", context)
	   -- Main Tent
	PrecacheResource("model", "models/props_structures/tent_dk_small.vmdl", context)
	   -- Good Barracks
	PrecacheResource("model", "models/props_structures/good_barracks_melee001.vmdl", context)
	   -- Evil Barracks
	PrecacheResource("model", "models/props_structures/bad_barracks001_melee.vmdl", context)
	   -- Market
	PrecacheResource("model", "models/props_structures/sideshop_radiant002.vmdl", context)
	   -- Armory
	PrecacheResource("model", "models/props_structures/tent_dk_med.vmdl", context)
	   -- Moonwell
	PrecacheResource("model", "models/props_structures/good_statue008.vmdl", context)
	   -- Unholy Spire
	PrecacheResource("model", "models/props_structures/bad_column001.vmdl", context)
	   -- Gold Mine
	PrecacheResource("model", "models/mine/mine.vmdl", context)

	-- Midas Particle
	PrecacheResource("particle", "particles/items2_fx/hand_of_midas_b.vpcf", context)

	-- Watch Tower Arrow
	PrecacheResource("particle", "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf", context)

	-- Healing Aura Particle
	PrecacheResource("particle", "particles/units/heroes/hero_enchantress/enchantress_natures_attendants_heal_aura.vpcf", context)





	-- Units and their items



	-- Common

	-- Worker
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.vmdl", context)

	-- Catapults
	PrecacheResource("model", "models/creeps/lane_creeps/creep_good_siege/creep_good_siege.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_siege/creep_bad_siege.vmdl", context)

	PrecacheResource("particle", "particles/base_attacks/ranged_siege_good.vpcf", context)
	PrecacheResource("particle", "particles/base_attacks/ranged_siege_bad.vpcf", context)



	-- Commander

	-- Worker
	PrecacheResource("model", "models/heroes/beastmaster/beastmaster.vmdl", context)

	PrecacheResource("model", "models/heroes/beastmaster/beastmaster_weapon.vmdl", context)

	-- Footman
	PrecacheResource("model", "models/heroes/dragon_knight/dragon_knight.vmdl", context)

	PrecacheResource("model", "models/items/dragon_knight/shield_timedragon.vmdl", context)
	PrecacheResource("model", "models/items/dragon_knight/skirt_timedragon.vmdl", context)
	PrecacheResource("model", "models/items/dragon_knight/pauldrons_timedragon.vmdl", context)
	PrecacheResource("model", "models/items/dragon_knight/helmet_timedragon.vmdl", context)
	PrecacheResource("model", "models/items/dragon_knight/bracers_timedragon.vmdl", context)
	PrecacheResource("model", "models/items/dragon_knight/weapon_dragonmaw.vmdl", context)

	-- Gunner
	PrecacheResource("model", "models/heroes/sniper/sniper.vmdl", context)

	PrecacheResource("model", "models/items/sniper/snipers_grandfather_rifle_3/snipers_grandfather_rifle_3.vmdl", context)
	PrecacheResource("model", "models/items/sniper/sharpshooter_arms/sharpshooter_arms.vmdl", context)
	PrecacheResource("model", "models/items/sniper/sharpshooter_shoulder/sharpshooter_shoulder.vmdl", context)
	PrecacheResource("model", "models/items/sniper/sharpshooter_cloak/sharpshooter_cloak.vmdl", context)
	PrecacheResource("model", "models/items/sniper/sharpshooter_stache/sharpshooter_stache.vmdl", context)

	PrecacheResource("particle", "particles/units/heroes/hero_sniper/sniper_base_attack.vpcf", context)



	-- Furion

	-- Worker
	PrecacheResource("model", "models/items/furion/treant/father_treant/father_treant.vmdl", context)

	-- Treant Warrior
	PrecacheResource("model", "models/heroes/furion/treant.vmdl", context)

	PrecacheResource("model", "models/items/ursa/savage_bracer.vmdl", context)

	-- Dryad
	PrecacheResource("model", "models/heroes/enchantress/enchantress.vmdl", context)

	PrecacheResource("model", "models/items/enchantress/anuxi_summer_arms/anuxi_summer_arms.vmdl", context)
	PrecacheResource("model", "models/items/enchantress/anuxi_summer_head/anuxi_summer_head.vmdl", context)
	PrecacheResource("model", "models/items/enchantress/anuxi_summer_shoulder/anuxi_summer_shoulder.vmdl", context)
	PrecacheResource("model", "models/items/enchantress/anuxi_summer_skirt/anuxi_summer_skirt.vmdl", context)
	PrecacheResource("model", "models/items/enchantress/anuxi_summer_spear/anuxi_summer_spear.vmdl", context)

	PrecacheResource("particle" ,"particles/units/heroes/hero_enchantress/enchantress_base_attack.vpcf", context)



	-- Geomancer

	-- Worker
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_c/n_creep_kobold_c.vmdl", context)

	-- Guard
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_b/n_creep_kobold_b.vmdl", context)

	-- Flame Thrower
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_c/n_creep_kobold_frost.vmdl", context)



	-- King of the Dead

	-- Worker
	PrecacheResource("model", "models/heroes/undying/undying_minion.vmdl", context)

	-- Warrior
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", context)

	-- Archer
	PrecacheResource("model", "models/heroes/clinkz/clinkz.vmdl", context)

	PrecacheResource("model", "models/heroes/clinkz/clinkz_head.vmdl", context)
	PrecacheResource("model", "models/heroes/clinkz/clinkz_bow.vmdl", context)
	PrecacheResource("model", "models/items/clinkz/clinkz_skeleton_hands/clinkz_skeleton_hands.vmdl", context)
	PrecacheResource("model", "models/items/clinkz/guard/guard.vmdl", context)
	PrecacheResource("model", "models/items/clinkz/justpicsnothingmnew/justpicsnothingmnew.vmdl", context)
	PrecacheResource("model", "models/items/clinkz/clinkzhead/clinkzhead.vmdl", context)

	PrecacheResource("particle", "particles/units/heroes/hero_clinkz/clinkz_base_attack.vpcf", context)



	-- Warlord

	-- Worker
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_high_priest.vmdl", context)

	-- Guard
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_berserker.vmdl", context)

	-- Axe Thrower
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_dark_a/n_creep_troll_dark_a.vmdl", context)

	PrecacheResource("particle", "particles/units/heroes/hero_troll_warlord/troll_warlord_base_attack.vpcf", context)


	print("Precache done!")
end

function Activate()
	GameRules.SimpleRTSGameMode = SimpleRTSGameMode:new()
	GameRules.SimpleRTSGameMode:InitGameMode()
end



--[[
-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')
statcollection.addStats({
	modID = 'f80936eabbb70043c658c7e6ed9f5246' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

-- Load the options module (GDSOptions should now be available from the global scope)
require('lib.optionsmodule')
GDSOptions.setup('f80936eabbb70043c658c7e6ed9f5246', function(err, options)  -- Your modID goes here, GET THIS FROM http://getdotastats.com/#d2mods__my_mods
    -- Check for an error
    if err then
        print('Something went wrong and we got no options: '..err)
        return
    end

    -- Success, store options as you please
    print('THIS IS INSIDE YOUR CALLBACK! YAY!')

    -- This is a test to print a select few options
    local toTest = {
        test = true,
        test2 = true,
        modID = true,
        steamID = true
    }
    for k,v in pairs(toTest) do
        print(k..' = '..GDSOptions.getOption(k, 'doesnt exist'))
    end
end)

print( "stat collection loaded." )]]