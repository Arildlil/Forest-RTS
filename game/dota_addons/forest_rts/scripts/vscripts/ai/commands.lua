
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

function Has5Workers(bot)
    local workerName = GetWorkerStructFor(bot.heroname).name
    local hasEnough = AI:HasAtLeast(bot, workerName, 5)
    AI:BotPrint(bot, "Has5Workers: "..tostring(hasEnough))
    return hasEnough
end

function Has10Workers(bot)
    local workerName = GetWorkerStructFor(bot.heroname).name
    local hasEnough = AI:HasAtLeast(bot, workerName, 10)
    return hasEnough
end

function HasBarracks(bot)
    local bool = AI:HasEntityTeamSpecific(bot, "BARRACKS")
    return bool
end

function HasMiniForce(bot)

end

---------------------------------------------------------------------------
-- Construction of buildings.
---------------------------------------------------------------------------
function ConstructTent(bot)
    AI:BotPrint(bot, "Constructing Main Tent")
    if AI:ConstructBuildingWrapper(bot, "TENT_SMALL") then
        bot.state = "busy"
        return true
    end
end

function ConstructGoldMine(bot)
    AI:BotPrint(bot, "Constructing Gold Mine")
    if AI:ConstructBuildingWrapper(bot, "GOLD_MINE") then
        bot.state = "constructing"
        return true
    end
end

function ConstructBarracks(bot)
    AI:BotPrint(bot, "Constructing Barracks")
    if AI:ConstructBuildingWrapper(bot, "BARRACKS") then
        bot.state = "constructing"
        return true
    end
end

function TrainWorker(bot)
    AI:BotPrint(bot, "Training Worker")
    local unitConst = GetWorkerConstFor(bot.heroname)
    AI:TrainUnit(bot, unitConst)
    return true
end
