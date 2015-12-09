--[[
   Contains the code related to units orders. 
   Credit to MNoya for writing most of the code.
]]



function SimpleRTSGameMode:FilterExecuteOrder( filterTable )
   --[[
      print("-----------------------------------------")
      for k, v in pairs( filterTable ) do
      print("Order: " .. k .. " " .. tostring(v) )
      end
   ]]

   local units = filterTable["units"]
   local order_type = filterTable["order_type"]
   local issuer = filterTable["issuer_player_id_const"]
   local abilityIndex = filterTable["entindex_ability"]
   local targetIndex = filterTable["entindex_target"]
   local queue = tobool(filterTable["queue"])
   local x = tonumber(filterTable["position_x"])
   local y = tonumber(filterTable["position_y"])
   local z = tonumber(filterTable["position_z"])
   local point = Vector(x,y,z)

   -- Skip Prevents order loops
   local unit = EntIndexToHScript(units["0"])
   if unit and unit.skip then
      unit.skip = false
      return true
   end

   local numUnits = 0
   local numBuildings = 0
   if units then
      for n,unit_index in pairs(units) do
	 local unit = EntIndexToHScript(unit_index)
	 if unit and IsValidEntity(unit) then
	    if not unit:IsBuilding() and not IsCustomBuilding(unit) then
	       numUnits = numUnits + 1
	       
	       -- Set hold position
	       if order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
		  unit.bHold = true
	       end
	    elseif unit:IsBuilding() or IsCustomBuilding(unit) then
	       numBuildings = numBuildings + 1
	    end
	 end
      end
   end


   if units and (order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE) and numUnits > 1 then
      
      -- Get buildings out of the units table
      local _units = {}
      for n, unit_index in pairs(units) do 
	 local unit = EntIndexToHScript(unit_index)
	 if not unit:IsBuilding() and not IsCustomBuilding(unit) then
	    _units[#_units+1] = unit_index
	 end
      end
      units = _units

      local x = tonumber(filterTable["position_x"])
      local y = tonumber(filterTable["position_y"])
      local z = tonumber(filterTable["position_z"])

      ------------------------------------------------
      --           Grid Unit Formation              --
      ------------------------------------------------
      -- EDIT
      local DEBUG = false --If enabled it'll show circles and grid positions
      local SQUARE_FACTOR = 1.5 --1.5 --1 is a perfect square, higher numbers will increase

      local navPoints = {}
      local first_unit = EntIndexToHScript(units[1])
      local origin = first_unit:GetAbsOrigin()

      local point = Vector(x,y,z) -- initial goal

      if DEBUG then DebugDrawCircle(point, Vector(255,0,0), 100, 18, true, 3) end

      local unitsPerRow = math.floor(math.sqrt(numUnits/SQUARE_FACTOR))
      local unitsPerColumn = math.floor((numUnits / unitsPerRow))
      local remainder = numUnits - (unitsPerRow*unitsPerColumn) 
      --print(numUnits.." units = "..unitsPerRow.." rows of "..unitsPerColumn.." with a remainder of "..remainder)

      local start = (unitsPerColumn-1)* -.5

      local curX = start
      local curY = 0

      local offsetX = 100
      local offsetY = 100
      local forward = (point-origin):Normalized()
      local right = RotatePosition(Vector(0,0,0), QAngle(0,90,0), forward)

      for i=1,unitsPerRow do
	 for j=1,unitsPerColumn do
	    --print ('grid point (' .. curX .. ', ' .. curY .. ')')
	    local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
	    if DEBUG then 
	       DebugDrawCircle(newPoint, Vector(0,0,0), 255, 25, true, 5)
	       DebugDrawText(newPoint, curX .. ', ' .. curY, true, 10) 
	    end
	    navPoints[#navPoints+1] = newPoint
	    curX = curX + 1
	 end
	 curX = start
	 curY = curY - 1
      end

      local curX = ((remainder-1) * -.5)

      for i=1,remainder do 
	 --print ('grid point (' .. curX .. ', ' .. curY .. ')')
	 local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
	 if DEBUG then 
	    DebugDrawCircle(newPoint, Vector(0,0,255), 255, 25, true, 5)
	    DebugDrawText(newPoint, curX .. ', ' .. curY, true, 10) 
	 end
	 navPoints[#navPoints+1] = newPoint
	 curX = curX + 1
      end

      for i=1,#navPoints do 
	 local point = navPoints[i]
	 --print(i,navPoints[i])
      end

      -- Sort the units by distance to the nav points
      sortedUnits = {}
      for i=1,#navPoints do
	 local point = navPoints[i]
	 local closest_unit_index = GetClosestUnitToPoint(units, point)
	 if closest_unit_index then
	    --print("Closest to point is ",closest_unit_index," - inserting in table of sorted units")
	    table.insert(sortedUnits, closest_unit_index)

	    --print("Removing unit of index "..closest_unit_index.." from the table:")
	    --DeepPrintTable(units)
	    units = RemoveElementFromTable(units, closest_unit_index)
	 end
      end

      -- Sort the units by rank (0,1,2,3)
      unitsByRank = {}
      for i=0,3 do
	 local units = GetUnitsWithFormationRank(sortedUnits, i)
	 if units then
	    unitsByRank[i] = units
	 end
      end

      -- Order each unit sorted to move to its respective Nav Point
      local n = 0
      for i=0,3 do
	 if unitsByRank[i] then
	    for _,unit_index in pairs(unitsByRank[i]) do
	       local unit = EntIndexToHScript(unit_index)
	       --print("Issuing a New Movement Order to unit index: ",unit_index)

	       local pos = navPoints[tonumber(n)+1]
	       --print("Unit Number "..n.." moving to ", pos)
	       n = n+1
	       
	       ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = order_type, Position = pos, Queue = false})
	    end
	 end
      end
      return false
   end

   ------------------------------------------------
   --           Ability Multi Order              --
   ------------------------------------------------
   if abilityIndex and abilityIndex ~= 0 and IsMultiOrderAbility(EntIndexToHScript(abilityIndex)) then
      print("Multi Order Ability")

      local ability = EntIndexToHScript(abilityIndex) 
      local abilityName = ability:GetAbilityName()
      local entityList = GetSelectedEntities(unit:GetPlayerOwnerID())
      for _,entityIndex in pairs(entityList) do
	 local caster = EntIndexToHScript(entityIndex)
	 -- Make sure the original caster unit doesn't cast twice
	 if caster and caster ~= unit and caster:HasAbility(abilityName) then
	    
	    local abil = caster:FindAbilityByName(abilityName)
	    if abil and abil:IsFullyCastable() then

	       caster.skip = true
	       if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
		  ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, Position = point, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

	       elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET then
		  ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, TargetIndex = targetIndex, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

	       else --order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
		  ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
	       end
	    end
	 end
      end
      return true
      
      ------------------------------------------------
      --              ClearQueue Order              --
      ------------------------------------------------
      -- Cancel queue on Stop and Hold
   elseif order_type == DOTA_UNIT_ORDER_STOP or order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
      for n, unit_index in pairs(units) do 
	 local unit = EntIndexToHScript(unit_index)
	 if IsBuilder(unit) then
	    BuildingHelper:ClearQueue(unit)
	 end
      end
      return true
      
      -- Cancel builder queue when casting non building abilities
   elseif (abilityIndex and abilityIndex ~= 0) and IsBuilder(unit) then
      local ability = EntIndexToHScript(abilityIndex)
      --print("ORDER FILTER",ability:GetAbilityName(), IsBuildingAbility(ability))
      if not IsBuildingAbility(ability) then
	 BuildingHelper:ClearQueue(unit)
      end
      return true
   end
   
   return true
end

------------------------------------------------
--             Repair Right-Click             --
------------------------------------------------
function SimpleRTSGameMode:RepairOrder( event )
   local pID = event.pID
   local entityIndex = event.mainSelected
   local targetIndex = event.targetIndex
   local building = EntIndexToHScript(targetIndex)
   local selectedEntities = GetSelectedEntities(pID)
   local queue = tobool(event.queue)

   local unit = EntIndexToHScript(entityIndex)
   local repair_ability = unit:FindAbilityByName("repair")

   -- Repair
   if repair_ability and repair_ability:IsFullyCastable() and not repair_ability:IsHidden() then
      ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = targetIndex, AbilityIndex = repair_ability:GetEntityIndex(), Queue = queue})
   end
end

ORDERS = {
   [0] = "DOTA_UNIT_ORDER_NONE",
   [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
   [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
   [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
   [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
   [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
   [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
   [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
   [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
   [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
   [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
   [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
   [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
   [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
   [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
   [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
   [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
   [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
   [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
   [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
   [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
   [21] = "DOTA_UNIT_ORDER_STOP",
   [22] = "DOTA_UNIT_ORDER_TAUNT",
   [23] = "DOTA_UNIT_ORDER_BUYBACK",
   [24] = "DOTA_UNIT_ORDER_GLYPH",
   [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
   [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
   [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
   [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
}



------------------------------------------------
--              Utility functions             --
------------------------------------------------

-- Returns the closest unit to a point from a table of unit indexes
function GetClosestUnitToPoint( units_table, point )
   local closest_unit = units_table["0"]
   if not closest_unit then
      closest_unit = units_table[1]
   end
   if closest_unit then   
      local min_distance = (point - EntIndexToHScript(closest_unit):GetAbsOrigin()):Length()

      for _,unit_index in pairs(units_table) do
	 local distance = (point - EntIndexToHScript(unit_index):GetAbsOrigin()):Length()
	 if distance < min_distance then
	    closest_unit = unit_index
	    min_distance = distance
	 end
      end
      return closest_unit
   else
      return nil
   end
end

-- Returns a table of units by index with the rank passed
function GetUnitsWithFormationRank( units_table, rank )
   local allUnitsOfRank = {}
   for _,unit_index in pairs(units_table) do
      if GetFormationRank( EntIndexToHScript(unit_index) ) == rank then
	 table.insert(allUnitsOfRank, unit_index)
      end
   end
   if #allUnitsOfRank == 0 then
      return nil
   end
   return allUnitsOfRank
end

-- Returns the FormationRank defined in npc_units_custom
function GetFormationRank( unit )
   local rank = 0
   if unit:IsHero() then
      rank = GameRules.HeroKV[unit:GetUnitName()]["FormationRank"]
   elseif unit:IsCreature() then
      rank = GameRules.UnitKV[unit:GetUnitName()]["FormationRank"]
   end
   return rank
end

-- Does awful table-recreation because table.remove refuses to work. Lua pls
function RemoveElementFromTable(table, element)
   local new_table = {}
   for k,v in pairs(table) do
      if v and v ~= element then
	 new_table[#new_table+1] = v
      end
   end

   return new_table
end
