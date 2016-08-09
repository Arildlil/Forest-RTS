

--// ----- | Tower related |----- \\--

function FlipTowerSpell(tower)
     local enterSpellName = "srts_enter_tower"
     local leaveSpellName = "srts_leave_tower"
     local enterSpell = tower:FindAbilityByName(enterSpellName)
     local leaveSpell = tower:FindAbilityByName(leaveSpellName)
     if enterSpell then
            tower:RemoveAbility(enterSpellName)
            tower:AddAbility(leaveSpellName)
            leaveSpell = tower:FindAbilityByName(leaveSpellName)
            leaveSpell:SetLevel(1)
     else
            tower:RemoveAbility(leaveSpellName)
            tower:AddAbility(enterSpellName)
            enterSpell = tower:FindAbilityByName(enterSpellName)
            enterSpell:SetLevel(1)
     end
end

function EnterTower(keys)
     local caster = keys.caster
     local target = keys.target
     local ability = keys.ability
     local modifier = keys.modifier

     if IsBuilding(target) or not IsRanged(target) then
            SendErrorMessage(caster:GetPlayerOwnerID(), "#error_target_must_be_ranged_unit")
            return
     end
     local towerOrigin = caster:GetOrigin()
     local newUnitOrigin = Vector(towerOrigin.x, towerOrigin.y, towerOrigin.z + 200)
     target:SetOrigin(newUnitOrigin)
     ability:ApplyDataDrivenModifier(caster, target, modifier, {})
     
     target._tower = caster
     caster._inside = target

    -- To make sure that the unit automatically attacks enemies in range.
    Timers:CreateTimer({
        endTime = 0.05,
        callback = function()
            target:MoveToPositionAggressive(towerOrigin)
    end})

     FlipTowerSpell(caster)
end

function CastEnterTower(keys)
    local tower = EntIndexToHScript(keys.towerIndex)
    local unit = EntIndexToHScript(keys.unitIndex)
    local abilityName = "srts_enter_tower"
    local ability = GetAbilityByName(tower, abilityName)
    if ability then
        tower:CastAbilityOnTarget(unit, ability, tower:GetOwnerID())
        local towerAbs = tower:GetAbsOrigin()
        -- For some reason the timer is needed for make the unit bother to execute the order!
        Timers:CreateTimer({
            endTime = 0.05,
            callback = function()
                unit:MoveToPosition(towerAbs)
            end}
        )
    end
end

function LeaveTower(keys)
     local caster = keys.caster
     RemoveUnitFromTower(caster)
end

function TowerIsEmpty(tower)
    return (tower._inside == nil)
end

function TowerHasUnitInside(tower)
    return (tower._inside ~= nil)
end

function UnitIsInsideTower(unit)
    return (unit._tower ~= nil)
end


function RemoveUnitFromTower(tower)
     local unit = tower._inside
     if not unit:IsNull() and unit:IsAlive() then
            unit:RemoveModifierByName("modifier_inside_tower_buff")
            unit._tower = nil
            FindClearSpaceForUnit(unit, tower:GetOrigin(), true)
     end
     tower._inside = nil
     FlipTowerSpell(tower)
end

function RemoveIfBuilding(keys) 
     local caster = keys.caster
     local modifier = keys.modifier
     if IsBuilding(caster) then
            caster:RemoveModifierByName(modifier)
     end
end



function HeroAttackSpeedAura(keys)
     local caster = keys.caster
     local target = keys.target
     local ability = keys.ability
     local abilityLevel = ability:GetLevel() - 1
     local modifier = keys.modifier
     local duration = ability.GetLevelSpecialValueFor("think_interval", ability_level)
     local casterOwner = caster:GetPlayerOwner()
     local targetOwner = target:GetPlayerOwner()
     
     print("Come on!")

     if casterOwner == targetOwner then
            ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = duration})
     end
end



--// ----- | Training related |----- \\--




--// ----- | Upgrade related |----- \\--

function ApplyUpgradeUnits(keys)
    local caster = keys.caster
    local ability = keys.ability
    local abilityName = ability:GetAbilityName()
    local ownerHero = caster:GetOwnerHero()
    local itemName = ownerHero.TT.techDef[abilityName].item
    ownerHero:SetAbilityLevelFor(abilityName, 0)
    ownerHero:SetUnitCountFor(abilityName, 1)
    local canGetUpgrade = {}
    local playerID = caster:GetOwnerID()

    print("ApplyUpgradeUnits called! Stats")
    Stats:OnResearchFinished(playerID, abilityName)
    Stats:SpendGold(playerID, keys.goldCost)
    Stats:SpendLumber(playerID, keys.lumberCost)

    local function AddUpgradeBool(itemName, unit)
        print("AddUpgradeBool called!")
        local unitName = unit:GetUnitName()
        local upgrades = GetUpgradesForUnit(unit)
        for _,upgradeConst in pairs(upgrades) do
            local upgradeItemName = ownerHero.TT.techDef[upgradeConst].item
            if itemName == upgradeItemName then
                canGetUpgrade[unitName] = true
                return
            end
        end
        canGetUpgrade[unitName] = false
    end

    for _,unit in pairs(ownerHero:GetUnits()) do
        local unitName = unit:GetUnitName()
        if canGetUpgrade[unitName] == nil then
            AddUpgradeBool(itemName, unit)
        end
        if canGetUpgrade[unitName] then
            local newItem = CreateItem(itemName, unit, unit)
            unit:AddItem(newItem)
        end
    end

    TechTree:UpdateTechTree(ownerHero, ownerHero, true)
end

function GetUpgradesForUnit(unit)
    local unitName = unit:GetUnitName()
    return defs[unitName].upgrades
end

function GetUpgradeItem(hero, upgradeSpellName)
    upgradeSpellName = hero.TT.techDef[upgradeSpellName].spell
    local upgradeLevel = hero:GetUnitCountFor(upgradeSpellName)
    if upgradeLevel > 0 then
        return hero.TT.techDef[upgradeSpellName].item
    else
        return nil
    end
end

function GetUpgradeLevel(hero, upgradeSpellName)
    return hero:GetUnitCountFor(upgradeSpellName)
end

function ApplyUpgradesOnTraining(unit)
    local ownerHero = unit:GetOwnerHero()
     
    -- Add upgrade item to newly trained unit if unlocked.
    local function AddUpgradeItem(upgradeItemName)
        local newItem = CreateItem(upgradeItemName, unit, unit)
        unit:AddItem(newItem)
    end
     
    local upgrades = GetUpgradesForUnit(unit)
    if upgrades then
        for _,upgradeConst in pairs(upgrades) do
            local upgradeItem = GetUpgradeItem(ownerHero, upgradeConst)
            if upgradeItem then
                AddUpgradeItem(upgradeItem)
            end
        end
    end

    -- Combine
    --[[
    if not IsWorker(unit) then
        local armorUpgradeItem = UpgradeItem("srts_upgrade_light_armor")
        if armorUpgradeItem then
            AddUpgradeItem(armorUpgradeItem)
        end
        local damageUpgradeItem = UpgradeItem("srts_upgrade_light_damage")
        if damageUpgradeItem then
            AddUpgradeItem(damageUpgradeItem)
        end
    end]]
end



function ToggleOnAutocast(keys)
    local caster = keys.caster
    local ability = keys.ability

    if not ability:GetAutoCastState() then
        ability:ToggleAutoCast()
    end
end

function PayManaCost(keys)
    local ability = keys.ability
    ability:PayManaCost()
end



--// ----- | Economy related |----- \\--

function CanAfford(player, gold, wood)
    local playerID
    if type(player) == "number" then
        playerID = player
    else
        playerID = player:GetPlayerID()
    end
    local hero = GetPlayerHero(playerID)
    local curGold = PlayerResource:GetGold(playerID)
    local curLumber = hero:GetLumber()
    if curGold >= gold and curLumber >= wood then
        return true
    else
        return false
    end
end

function GiveResources(player, gold, wood)
    local playerID = player:GetPlayerID()
    local hero = GetPlayerHero(playerID)
    hero:IncLumber(wood)
    --local curGold = PlayerResource:GetReliableGold(playerID)
    hero:IncGold(gold)
    --PlayerResource:SetGold(playerID, curGold + gold, true)
end

function RefundGoldTooltip(player, gold)
    local playerID = player:GetPlayerID()
    local hero = GetPlayerHero(playerID)
    local curGold = PlayerResource:GetReliableGold(playerID)
    hero:IncGoldNoStats(gold)
end

function RefundResourcesSpell(keys)
    RefundResourcesID(keys.caster:GetOwnerID(), keys.goldCost, keys.lumberCost)
end

function RefundResources(player, gold, lumber)
    RefundResourcesID(player:GetPlayerID(), gold, lumber)
end

function RefundResourcesID(playerID, gold, lumber)
    local hero = GetPlayerHero(playerID)
    hero:IncGoldNoStats(gold)
    hero:IncLumberNoStats(lumber)   
end

function SpendResourcesNew(player, goldCost, lumberCost, trackStats)
    print("SpendResourcesNew called!")
    local playerID = player:GetPlayerID()
    local hero = GetPlayerHero(playerID)
    local curGold = PlayerResource:GetReliableGold(playerID)
    if trackStats then
        hero:DecGold(goldCost)
        hero:DecLumber(lumberCost)
    else
        hero:DecGoldNoStats(goldCost)
        hero:DecLumberNoStats(lumberCost)
    end
end

function BuyItem(keys)
    local shop = keys.caster
    local ability = keys.ability
    local itemName = keys.item
    local goldCost = keys.goldCost or 0
    local lumberCost = keys.lumberCost or 0
    local buyRange = 900.0
    local amount = keys.amount or 1
    local buyerHero = shop:GetOwnerHero()
    local buyerPlayer = shop:GetOwnerPlayer()
    local buyerHeroLocation = buyerHero:GetAbsOrigin()
    local buyerID = shop:GetOwnerID()
     
    shop._canAfford = nil
    -- We need to give back the gold before checking.
    RefundGoldTooltip(buyerPlayer, goldCost)

    if not CanAfford(buyerPlayer, goldCost, lumberCost) then
        SendErrorMessage(buyerID, "#error_not_enough_resources")
        print("Cannot afford, retuning from BuyItem.")
        return
    end

    if shop:GetRangeToUnit(buyerHero) > buyRange then
        SendErrorMessage(buyerID, "#error_hero_outside_shop_range")
        return
    end

    SpendResourcesNew(buyerPlayer, goldCost, lumberCost, true)
    GiveCharges(buyerHero, amount, itemName)
end
