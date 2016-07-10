
function AI:IdleHeroAction(bot)
    local hero = bot.hero
    if not hero:IsChanneling() and not hero:HasItemInInventory("item_stack_of_lumber") then
        AI:HarvestLumber(bot, hero)
    end
end

---------------------------------------------------------------------------
-- Predicates for buildingchecks.
---------------------------------------------------------------------------
function HasTent(bot)
    return AI:HasEntity(bot, "TENT_SMALL")
end 

function HasGoldMine(bot)
    return AI:HasEntity(bot, "GOLD_MINE")
end

function HasBarracks(bot)
    return AI:HasEntity(bot, "BARRACKS")
end

function HasHealingCrystal(bot)
    return AI:HasEntity(bot, "HEALING_CRYSTAL")
end

function HasMarket(bot)
    return AI:HasEntity(bot, "MARKET")
end

function Has5Workers(bot)
    local workerName = AI:GetWorkerName(bot)
    local hasEnough = AI:HasAtLeast(bot, workerName, 5)
    return hasEnough
end

function Has10Workers(bot)
    local workerName = AI:GetWorkerName(bot)
    local hasEnough = AI:HasAtLeast(bot, workerName, 10)
    return hasEnough
end

function HasMiniForce(bot)
    local hero = bot.hero

    local meleeCount = AI:GetCountFor(bot, "MELEE")
    local rangedCount = AI:GetCountFor(bot, "RANGED")
    local sum = meleeCount + rangedCount
    local requirement = 5

    --AI:BotPrint(bot, "meleeCount: "..meleeCount..", rangedCount: "..rangedCount..", sum: "..sum)

    return (sum >= requirement)
end

function HasBaseDefences(bot)
    local hero = bot.hero
    local maxTowerLocations = #bot.base.locations.WATCH_TOWER
    local maxWallLocations = #bot.base.locations.WOODEN_WALL

    local towerCount = AI:GetCountFor(bot, "WATCH_TOWER")
    local wallCount = AI:GetCountFor(bot, "WOODEN_WALL")

    return (towerCount == maxTowerLocations and wallCount == maxWallLocations)
end

function HasTowerDefenders(bot)
    local towers = AI:GetCertainBuildings(bot, "WATCH_TOWER")
    for k,tower in pairs(towers) do
        if AI:IsTowerEmpty(bot, tower) then
            return false
        end
    end
    return true
end

function HasMixedForce(bot)
    local towerUnitCount = AI:GetTowerUnitsCount(bot)
    return (AI:HasAtLeast(bot, "MELEE", bot.mixedMinimumEach) and
            AI:HasAtLeast(bot, "RANGED", bot.mixedMinimumEach + towerUnitCount))
end

---------------------------------------------------------------------------
-- Construction of buildings.
---------------------------------------------------------------------------
function ConstructTent(bot)
    if AI:ConstructBuildingWrapper(bot, "TENT_SMALL") then
        bot.state = "busy"
        return true
    end
end

function ConstructGoldMine(bot)
    return AI:ConstructBuildingWrapper(bot, "GOLD_MINE")
end

function ConstructBarracks(bot)
    return AI:ConstructBuildingWrapper(bot, "BARRACKS")
end

function ConstructHealingCrystal(bot)
    return AI:ConstructBuildingWrapper(bot, "HEALING_CRYSTAL")
end

function ConstructMarket(bot)
    return AI:ConstructBuildingWrapper(bot, "MARKET")
end

function ConstructWatchTower(bot)
    return AI:ConstructBuildingWrapper(bot, "WATCH_TOWER")
end

function ConstructWoodenWall(bot)
    return AI:ConstructBuildingWrapper(bot, "WOODEN_WALL")
end

function ConstructBaseDefences(bot)
    local maxTowerLocations = #bot.base.locations.WATCH_TOWER
    local maxWallLocations = #bot.base.locations.WOODEN_WALL
    local towerCount = AI:GetCountFor(bot, "WATCH_TOWER") 
    local wallCount = AI:GetCountFor(bot, "WOODEN_WALL")

    local enoughTowers = (towerCount == maxTowerLocations)
    if not enoughTowers then
        return ConstructWatchTower(bot)
    end
    local enoughtWalls = (wallCount == maxWallLocations)
    if not enoughWalls then
        return ConstructWoodenWall(bot)
    end
    return false
end

function FillTowers(bot)
    local rangedUnits = AI:GetCertainUnits(bot, "RANGED")
    if not rangedUnits or #rangedUnits == 0 then
        TrainRanged(bot)
        return false
    end
    for k,unit in pairs(rangedUnits) do
        if not AI:IsUnitInside(bot, unit) and unit.AI.state == "idle" then
            local emptyTower = AI:GetEmptyTower(bot)
            if emptyTower then
                AI:EnterTower(bot, unit, emptyTower)
                emptyTower._occupied = true
                unit._enteringTower = true
            else
                break
            end
        end
    end
    local emptyTower = AI:GetEmptyTower(bot)
    if emptyTower then
        TrainRanged(bot)
        return false
    end
    return true
end

function TrainMixedForce(bot)
    local towerUnitCount = AI:GetTowerUnitsCount(bot)
    if not AI:HasAtLeast(bot, "MELEE", bot.mixedMinimumEach) then
        TrainMelee(bot)
        return false
    elseif not AI:HasAtLeast(bot, "RANGED", bot.mixedMinimumEach + towerUnitCount) then
        TrainRanged(bot)
        return false
    end
    return true
end

---------------------------------------------------------------------------
-- Training of units.
---------------------------------------------------------------------------

function TrainWorker(bot)
    local unitName = AI:GetWorkerName(bot)
    return AI:TrainUnit(bot, unitName)
end

function TrainMelee(bot)
    local unitName = AI:GetMeleeName(bot)
    return AI:TrainUnit(bot, unitName)
end

function TrainRanged(bot)
    local unitName = AI:GetRangedName(bot)
    return AI:TrainUnit(bot, unitName)
end

function TrainSiege(bot)
    local unitName = AI:GetSiegeName(bot)
    return AI:TrainUnit(bot, unitName)
end

function TrainCaster(bot)
    local unitName = AI:GetCasterName(bot)
    return AI:TrainUnit(bot, unitName)
end
