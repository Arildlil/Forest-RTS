
if not TechTree then
   TechTree = {}
   TechTree.__index = TechTree
end

function TechTree:new(o)
   o = o or {}
   setmetatable(o, self)
   SIMPLETECHTREE_REFERENCE = o
   return o
end

print("[TechTree] Loading Tech Tree Definitions...")

require('tech_def')

print("[TechTree] Creating Tech Tree Structures...")

---------------------------------------------------------------------------
-- Init the tech tree for the hero.
--- * hero: The unit to init the tech tree for.
---------------------------------------------------------------------------
function TechTree:InitTechTree(hero)
   if not hero then
      -- Crash
      hero:GetUnitName()
   end
   if not TechTree:IsHero(hero) then
      print_simple_tech_tree("TechTree:InitTechTree", "hero was not a hero! ("..hero:GetUnitName()..")!")
   end

   -- Init tables for unit.
   hero.TT = {
      unitCount = {},
      buildings = {},
      units = {},
      abilityLevels = {}
   }


   --					-----| UnitCount table |-----


   ---------------------------------------------------------------------------
   -- Returns the total number of units.
   ---------------------------------------------------------------------------
   function hero:GetUnitCount()
      return hero.TT.unitCount
   end

   ---------------------------------------------------------------------------
   -- Returns the count of units with 'name' as unitName.
   ---------------------------------------------------------------------------
   function hero:GetUnitCountFor(name)
      return hero.TT.unitCount[name]
   end

   ---------------------------------------------------------------------------
   -- Sets the count of units with 'name' as unitName.
   ---------------------------------------------------------------------------
   function hero:SetUnitCountFor(name, value)
      if name and value then
	 hero.TT.unitCount[name] = value
      else
	 -- Crash
	 print(name.." "..value)
      end
   end

   ---------------------------------------------------------------------------
   -- Increments the count of units with 'name' as unitName.
   ---------------------------------------------------------------------------
   function hero:IncUnitCountFor(name)
      if name then
	 if not hero.TT.unitCount[name] then
	    hero.TT.unitCount[name] = 0
	 end
	 hero.TT.unitCount[name] = hero.TT.unitCount[name] + 1
	 return hero.TT.unitCount[name]
      else
	 -- Crash
	 print("IncUnitCountFor: "..name)
      end
   end

   ---------------------------------------------------------------------------
   -- Decrements the count of units with 'name' as unitName.
   ---------------------------------------------------------------------------
   function hero:DecUnitCountFor(name)
      if name then
	 if not hero.TT.unitCount[name] then
	    hero.TT.unitCount[name] = 0
	 end
	 hero.TT.unitCount[name] = hero.TT.unitCount[name] - 1
	 return hero.TT.unitCount[name]
      else
	 -- Crash
	 print("DecUnitCountFor: "..name)
      end
   end


   --					-----| Buildings and Units tables |-----


   ---------------------------------------------------------------------------
   -- Gets the ability level for the entities with the
   -- specified name.
   ---------------------------------------------------------------------------
   function hero:GetAbilityLevelFor(name)
      local level = hero.TT.abilityLevels[name]
      if level then
	 return level
      else
	 print("Note: hero did not have ability level for "..name.."!")
	 return 1
      end
   end

   ---------------------------------------------------------------------------
   -- Sets the ability level for the entities with the
   -- specified name.
   ---------------------------------------------------------------------------
   function hero:SetAbilityLevelFor(name, level)
      hero.TT.abilityLevels[name] = level
   end


   --					-----| Buildings and Units tables |-----


   ---------------------------------------------------------------------------
   -- Get the table with handles to all the buildings of the hero.
   ---------------------------------------------------------------------------
   function hero:GetBuildings()
      return hero.TT.buildings
   end

   ---------------------------------------------------------------------------
   -- Get the table with handles to all the units of the hero.
   ---------------------------------------------------------------------------
   function hero:GetUnits()
      return hero.TT.units
   end

   ---------------------------------------------------------------------------
   -- Add the building handle to the building table.
   ---------------------------------------------------------------------------
   function hero:AddBuilding(building)
      if building then
	 table.insert(hero.TT.buildings, building)
      else
	 -- Crash
	 unit:GetUnitName()
      end
   end

   ---------------------------------------------------------------------------
   -- Add the unit handle to the unit table.
   ---------------------------------------------------------------------------
   function hero:AddUnit(unit)
      if unit then
	 table.insert(hero.TT.units, unit)
      else
	 -- Crash
	 unit:GetUnitName()
      end
   end

   ---------------------------------------------------------------------------
   -- Remove the building from the building table by index.
   ---------------------------------------------------------------------------
   function hero:RemoveBuildingByIndex(index)
      if index then
	 table.remove(hero.TT.buildings, index)
      else
	 -- Crash
	 print(index)
      end
   end

   ---------------------------------------------------------------------------
   -- Remove the unit from the unit table by index.
   ---------------------------------------------------------------------------
   function hero:RemoveUnitByIndex(index)
      if index then
	 table.remove(hero.TT.units, index)
      else
	 -- Crash
	 print(index)
      end
   end

   ---------------------------------------------------------------------------
   -- Remove the reference to the building from the building table.
   ---------------------------------------------------------------------------
   function hero:RemoveBuilding(building)
      local index = -1
      for k,v in pairs(hero:GetBuildings()) do
	 if v == building then
	    index = k
	    break
	 end
      end
      if index ~= -1 then
	 hero:RemoveBuildingByIndex(index)
	 return true
      end
      return false
   end

   ---------------------------------------------------------------------------
   -- Remove the reference to unit from the unit table.
   ---------------------------------------------------------------------------
   function hero:RemoveUnit(unit)
      local index = -1
      for k,v in pairs(hero:GetUnits()) do
	 if v == unit then
	    index = k
	    break
	 end
      end
      if index ~= -1 then
	 hero:RemoveUnitByIndex(index)
	 return true
      end
      return false
   end

   ---------------------------------------------------------------------------
   -- Print the count of units and buildings for the owner of that unit.
   ---------------------------------------------------------------------------
   function hero:PrintUnitCount()
      local player = unit:GetOwner()
      local playerID = player:GetPlayerID()
      local playerHero = GetPlayerHero(playerID)

      if DEBUG_SIMPLE_TECH_TREE then
	 print("\n------------------")
	 print("Printing unit count for "..playerID..":")
	 print("------------------")
	 for index,count in pairs(playerHero.TT._unitCount) do
	    if index ~= "none" then
	       print(index..": "..count)
	    end
	 end
	 print("------------------")
      end
   end
   ---------------------------------------------------------------------------
   TechTree:RemoveDescriptionSpells(hero)

   local heroName = hero:GetUnitName()

   TechTree:ReadTechDef(hero)

   -- Update tech tree.
   TechTree:UpdateTechTree(hero, nil, "init")

   -- Set current page to the main one.
   GoToPage(hero, "PAGE_MAIN")
end


--					-----| Init Helper Methods |-----


---------------------------------------------------------------------------
-- Read the tech definition for the hero and initialize
-- ability levels, unit count and the spell table.
--- * ownerhero: The hero of a player.
---------------------------------------------------------------------------
function TechTree:ReadTechDef(ownerHero)
   -- Crash
   if not ownerHero:IsRealHero() then print(ownerHero) end
   if not defs then print(defs.abc) end

   -- Init TT vars of hero.
   local heroName = ownerHero:GetUnitName()
   ownerHero.TT.techDef = tech[heroName]
   ownerHero._spells = {}
   local heroTT = ownerHero.TT.techDef

   -- Add owner methods to hero.
   local owner = ownerHero:GetOwner()
   TechTree:AddPlayerMethods(ownerHero, owner)

   -- Set ability pages for the unit.
   for key,page in pairs(tech[heroName].heropages) do
      InitAbilityPage(ownerHero, key, page)
   end

   -- Set ability levels and unitCount for the player.
   for key,value in pairs(heroTT) do
      if key ~= "heroname" and key ~= "heropages" then
	 -- Set unit count and ability level.
	 local cat = value.category
	 if cat == "unit" or cat == "building" then
	    ownerHero:SetUnitCountFor(value.name, 0)
	 elseif value.category == "spell" then
	    ownerHero:SetUnitCountFor(value.spell, 0)
	 end
	 ownerHero:SetAbilityLevelFor(value.spell, 0)
	 
	 -- Debug print
	 if value.req then
	    print("\nLooking at reqs for "..value.spell.." (#req: "..#value.req.."):")
	    for k,v in pairs(value.req) do
	       if type(v) == "string" then
	       --if v.category then
		  print("\tSinglechoice:")
		  print("\t\t"..heroTT[v].name)
	       elseif type(v) == "table" then  -- Note
		  print("\tMultichoice (#v = "..#v.."):")
		  for i,v2 in pairs(v) do
		     print("\t\t"..i..": "..heroTT[v2].name)
		  end
	       end
	    end
	 end

	 local curSpellName = value.spell
	 ownerHero._spells[curSpellName] = value
	 --table.insert(ownerHero._spells, value)
      end
   end

   -- Set more keys for easier usage.
   for k,v in pairs(heroTT) do
      if k ~= "heropages" and k ~= "heroname" then
	 heroTT[v.spell] = v
	 local cat = v.category
	 if cat == "unit" or cat == "building" then
	    heroTT[v.name] = v
	 end
      end
   end
end



---------------------------------------------------------------------------
-- Removes all the description spells of the hero.
--- * hero: The hero to work with.
---------------------------------------------------------------------------
function TechTree:RemoveDescriptionSpells(hero)
   for i=0,6 do
      local curAbility = hero:GetAbilityByIndex(i)
      if curAbility then
	 local curAbilityName = curAbility:GetAbilityName()
	 hero:RemoveAbility(curAbilityName)
      end
   end
end


--					-----| On Training or Death |-----


---------------------------------------------------------------------------
-- Adds useful methods to the newly training unit or 
-- constructed building.
--- * entity: The entity to add methods to.
---------------------------------------------------------------------------
function TechTree:AddPlayerMethods(entity, owner)
   local ownerID = owner:GetPlayerID()
   local ownerHero = GetPlayerHero(ownerID)

   entity._ownerPlayer = owner
   entity._ownerPlayerID = ownerID
   entity._ownerHero = ownerHero
      
   -- Get the player object of the owner.
   function entity:GetOwnerPlayer()
      return entity._ownerPlayer or entity:GetOwner()
   end
   
   -- Get the player id of the owner.
   function entity:GetOwnerID()
      return entity._ownerPlayerID or entity:GetOwner():GetPlayerID()
   end
   
   -- Get the hero of the owner.
   function entity:GetOwnerHero()
      return entity._ownerHero or GetPlayerHero(entity:GetOwner():GetPlayerID())
   end
end

---------------------------------------------------------------------------
-- Returns all the abilityPages for the unit.
--- * unit: The unit to get the pages for.
--- * ownerHero: The hero of the owning player.
---------------------------------------------------------------------------
function TechTree:GetAbilityPagesForUnit(unit, ownerHero)
   if unit:IsRealHero() then 
      return unit.TT.techDef.heropages 
   end
   local unitName = unit:GetUnitName()
   local unitPages = ownerHero.TT.techDef[unitName].pages
   for pageName,page in pairs(unitPages) do
      for i,curSpell in pairs(page) do
	 if type(curSpell) == "string" then
	    -- Replace string with ref to actual spell.
	    page[i] = ownerHero.TT.techDef[curSpell]
	 end
      end
   end
   return unitPages
end

---------------------------------------------------------------------------
-- Makes sure to unlearn the construction spell of a building if the max
-- has been met at construction start.
--- * unit: The unit whose construction just started.
--- * spellname: Name of the spell used to create the building.
---------------------------------------------------------------------------
function TechTree:RegisterConstruction(unit, spellname)
   if not unit then
      -- Crash
      print("IsBuilding: "..tostring(IsBuilding))
      print(unit)
   end

   unit._finished = false
   local ownerHero = unit:GetOwnerPlayer()
   local unitName = unit:GetUnitName()
   local newUnitCount = ownerHero:GetUnitCountFor(unitName) + 1
   local maxUnitCount = TechTree:GetMaxCountFor(unitName, ownerHero)
   ownerHero:IncUnitCountFor(unitName)
   if maxUnitCount and newUnitCount >= maxUnitCount then
      ownerHero:SetAbilityLevelFor(spellname, 0)
      TechTree:UpdateSpellsAllEntities(ownerHero)
   end
end

---------------------------------------------------------------------------
-- Adds the abilities of an entity, setting them to level 0.
--- * entity: The entity to learn abilities.
---------------------------------------------------------------------------
function TechTree:AddAbilitiesToEntity(entity)
   local ownerHero = entity:GetOwnerHero()
   local heroName = ownerHero:GetUnitName()
   local entityName = entity:GetUnitName()
   local abilities = TechTree:GetAbilityPagesForUnit(entity, ownerHero)
   --print("Adding abilities to new "..entityName)
   for pageName,page in pairs(abilities) do
      --[=[
      print("CurPage: "..pageName)
      for k,v in pairs(page) do
	 local val = "(table)"
	 if type(v) == "string" then
	    val = v
	 end
	 print("\t"..k..": type(v): "..type(v).." "..val)
      end
      ]=]
      InitAbilityPage(entity, pageName, page)
   end
   GoToPage(entity, "PAGE_MAIN")
end

---------------------------------------------------------------------------
-- Add or removes a unit from the tables upon construction/training or
-- destruction/termination.
--- * unit: The unit that was either constructed/trained or killed/destroyed.
--- * state: Should be true if construction/training, false if killed/destroyed.
---------------------------------------------------------------------------
function TechTree:RegisterIncident(unit, state)
   if not unit then print("TechTree:RegisterIncident: unit was nil!"); return end
   -- Don't want this to trigger if state is fales
   if state == nil then	print("TechTree:RegisterIncident: state was nil!"); return end

   local isBuilding = IsBuilding(unit)
   local unitName = unit:GetUnitName()
   local ownerHero = unit:GetOwnerHero()
   local oldUnitCount = ownerHero:GetUnitCountFor(unitName) or 0
   local wasUnfinished = false

   -- On creation.
   if state == true then
      if isBuilding == true then
	 oldUnitCount = oldUnitCount - 1
	 ownerHero:AddBuilding(unit)
	 if unit._finished == false then
	    unit._finished = true
	    --ownerHero:IncUnitCountFor(unitName)
	 else
	    print("\n\tWARNING: UNIT._FINISHED WAS TRUE!\n")
	 end
      else
	 ownerHero:AddUnit(unit)
	 ownerHero:IncUnitCountFor(unitName)
      end

      -- On death.
   elseif state == false then
      if isBuilding == true then
	 ownerHero:RemoveBuilding(unit)
	 ownerHero:DecUnitCountFor(unitName)
	 --if unit._finished == true then
	 --else
	 if unit.finished == false then
	    --print("Note: building was destroyed before finished...")
	    wasUnfinished = true
	    unit._interrupted = true
	 end
      else
	 ownerHero:RemoveUnit(unit)
	 ownerHero:DecUnitCountFor(unitName)
      end
   end

   local needsUpdate = false
   local maxUnitCount = TechTree:GetMaxCountFor(unitName, ownerHero)
   local newUnitCount = ownerHero:GetUnitCountFor(unitName)

   if maxUnitCount then
      if (oldUnitCount >= maxUnitCount and newUnitCount < maxUnitCount) or
	 (oldUnitCount < maxUnitCount and newUnitCount >= maxUnitCount) or
      wasUnfinished then

	 --print("\tUpdate triggered by maxUnitCount or wasUnfinished!")
	 needsUpdate = true
      end
   elseif (oldUnitCount == 0 and newUnitCount > 0) or
   (oldUnitCount > 0 and newUnitCount == 0) then

      --print("\t\tUpdate triggered by unitCount entering or leaving 0!")
      needsUpdate = true
   end

   if needsUpdate == true then
      print("Note: Needed update!")
      TechTree:UpdateTechTree(ownerHero, unit, state)
   end
end


--					-----| Update Methods |-----


---------------------------------------------------------------------------
-- Update the level on all the spells of all entities of
-- a player.
--- * ownerHero: The hero of the player.
---------------------------------------------------------------------------
function TechTree:UpdateSpellsAllEntities(ownerHero)
   -- Update hero.
   TechTree:UpdateSpellsForHero(ownerHero)

   -- Update entities of hero.
   for _,building in pairs(ownerHero:GetBuildings()) do
      TechTree:UpdateSpellsForEntity(building, ownerHero)
   end
   for _,unit in pairs(ownerHero:GetUnits()) do 
      TechTree:UpdateSpellsForEntity(unit, ownerHero)
   end
end

---------------------------------------------------------------------------
-- Wrapper function for heroes.
---------------------------------------------------------------------------
function TechTree:UpdateSpellsForHero(ownerHero) 
   TechTree:UpdateSpellsForEntity(ownerHero, ownerHero)
end

---------------------------------------------------------------------------
-- Updates all the spells for the given entity.
---------------------------------------------------------------------------
function TechTree:UpdateSpellsForEntity(entity, ownerHero)
   if entity:IsRealHero() then
      ownerHero = entity
   else
      ownerHero = ownerHero or entity:GetOwnerHero()
   end

   for i=0,6 do
      local curAbility = entity:GetAbilityByIndex(i)
      if curAbility and not curAbility:IsNull() then
	 local curAbilityName = curAbility:GetAbilityName()
	 local level = ownerHero:GetAbilityLevelFor(curAbilityName)
	 
	 if not level then
	    curAbility:SetLevel(1)
	 else
	    curAbility:SetLevel(level)
	 end
      end
   end
end

---------------------------------------------------------------------------
-- Updates the tech tree if necessary. action is true if construction,
-- false if destruction.
--
--	* hero: The hero of the player that owns the building.
--	* building: The building that triggered the call of this function.
--	* action: Specifies whether the call was called by a construction
--		or destruction of a building or unit, or even just an init.
--
---------------------------------------------------------------------------
function TechTree:UpdateTechTree(hero, building, action)
   if hero and TechTree:IsHero(hero) == false then
      -- Crash
      print(abc.def)
      return false
   end
   if not building and action == "init" then
      print("\nTechTree:UpdateTechTree: Initing tech tree...")
   elseif not building then
      print("\nTechTree:UpdateTechTree: building was nil!")
      return false
   elseif action == nil then
      print("\nTechTree:UpdateTechTree: action was nil!")
      return false
   end
   if not hero.TT then
      print("ERROR: hero did have have hero.TT! This most likely means TechTree:InitTechTree(hero) hasn't been called yet!")
      return false
   end

   -- Print info.
   local playerID = hero:GetOwnerID()
   print("[TechTree] Updating tech tree for player with ID "..playerID.."!")
   local needsUpdate = true

   -- Check through all the spells.
   for i,curSpell in pairs(hero._spells) do
      local curSpellName = curSpell.spell

      local curUnitName = curSpell.name or "none"
      local curUnitCount = "-"
      local curUnitMax = curSpell.max

      -- Count the number of units or buildings of this type if training or construction spell.
      if curUnitName then
	 curUnitCount = hero:GetUnitCountFor(curUnitName)
	 if not curUnitCount then
	    hero:SetUnitCountFor(curUnitName, 0)
	    curUnitCount = 0
	 end
      end

      -- Check if all reqs for the spell are met.
      local unlock = true
      if curUnitMax and curUnitCount >= curUnitMax then
	 unlock = false
      else
	 if not curSpell["req"] then
	    unlock = true
	 else
	    -- Check requirements table for current spells if it has one.
	    for _,curReqConst in ipairs(curSpell["req"]) do
	       unlock = true

	       -- Old way of checking current requirement.
	       if type(curReqConst) == "string" then
		  local curReq = hero.TT.techDef[curReqConst]
		  local curReqName = curReq["name"] or "none"
		  local curReqCount = hero:GetUnitCountFor(curReqName) or 0

		  -- If req count not met.
		  if not curReqCount or curReqCount <= 0 then
		     unlock = false
		     break
		  end
	       elseif type(curReqConst) == "table" then   
		  -- New way! Looking at ..., curReq, ... or ..., {curOption1, curOption2}, ...
		  -- Insert the current req or table with choosable reqs into a new one.
		  local curReqTable = {}

		  -- Check the reqs in the cur req options table.
		  for _,curOptReqName in ipairs(curReqConst) do
		     local curReq = hero.TT.techDef[curOptReqName]
		     local curReqName = curReq.name
		     local curOptReqCount = hero:GetUnitCountFor(curReqName)
		     if curOptReqCount and curOptReqCount > 0 then
			unlock = true
			break
		     else
			unlock = false
		     end
		  end

		  -- Stop if neither of the options for the current req has been met.
		  --if not oneOptionMet then
		  if not unlock then
		     break
		  end
	       end
	    end
	 end
      end
      
      -- Set spell level.
      if unlock == true then
	 hero:SetAbilityLevelFor(curSpellName, 1)
      elseif unlock == false then
	 hero:SetAbilityLevelFor(curSpellName, 0)
      else
	 print("TechTree:UpdateTechTree: unlock was neither true nor false!-----------------")
      end

      local curSpellLevel = hero:GetAbilityLevelFor(curSpellName)
   end

   print("Updating all spells.")
   TechTree:PrintAbilityLevels(hero:GetOwnerPlayer())
   --DEBUG_SIMPLE_TECH_TREE = true
   TechTree:UpdateSpellsAllEntities(hero)

   print_simple_tech_tree("UpdateTechTree", "\n\tTech tree update done!")
end





--					-----| Utility |-----





---------------------------------------------------------------------------
-- Prints the ability levels for the hero.
--- * player: The player whose ability levels to print.
---------------------------------------------------------------------------
function TechTree:PrintAbilityLevels(player)
   if DEBUG_SIMPLE_TECH_TREE ~= true then
      return
   end

   local playerID = player:GetPlayerID()
   local hero = GetPlayerHero(playerID)

   local spells = {
      building = {},
      unit = {},
      spell = {}
   }

   for key,curSpell in pairs(hero.TT.techDef) do
      if key ~= "heropages" and key ~= "heroname" then
	 local category = curSpell.category
	 local found = false
	 for _,v in pairs(spells[category]) do
	    if v == curSpell then
	       found = true
	       break
	    end
	 end
	 if not found then
	    if category then
	       table.insert(spells[category], curSpell)
	    else
	       print("TechTree:PrintAbilityLevels: invalid category found!")
	    end
	 end
      end
   end

   print("---------------------------------------------------------------------------")
   print("PrintAbilityLevels for player with ID "..playerID..":")
   print("---------------------------------------------------------------------------")
   print("")
   print("							-----| Buildings |-----							  ")
   print("")
   print("            Spell Name             | Level | Count | Name")
   print("---------------------------------------------------------------------------")
   for _,curSpell in pairs(spells.building) do
      local spellLevel = hero:GetAbilityLevelFor(curSpell.spell) or "nil"
      local unitName = curSpell.name
      if not unitName or unitName == "none" then unitName = "-" end
      local unitCount = hero:GetUnitCountFor(unitName) or "-"
      print(string.format("%35s    %d      %3s     %s", curSpell.spell, spellLevel, unitCount, unitName))
   end
   print("---------------------------------------------------------------------------")
   print("")
   print("							-----| Units |-----							  ")
   print("")
   print("            Spell Name             | Level | Count | Name")
   print("---------------------------------------------------------------------------")
   for _,curSpell in pairs(spells.unit) do
      local spellLevel = hero:GetAbilityLevelFor(curSpell.spell) or "nil"
      local unitName = curSpell.name
      if not unitName or unitName == "none" then unitName = "-" end
      local unitCount = hero:GetUnitCountFor(unitName) or "-"
      print(string.format("%35s    %d      %3s     %s", curSpell.spell, spellLevel, unitCount, unitName))
   end
   print("---------------------------------------------------------------------------")
   print("")
   print("							-----| Spells |-----							  ")
   print("")
   print("            Spell Name             | Level | Count | Name")
   print("---------------------------------------------------------------------------")
   for _,curSpell in pairs(spells.spell) do
      local spellLevel = hero:GetAbilityLevelFor(curSpell.spell) or "nil"
      local unitName = curSpell.name
      if not unitName or unitName == "none" then unitName = "-" end
      local unitCount = hero:GetUnitCountFor(unitName) or "-"
      print(string.format("%35s    %d      %3s     %s", curSpell.spell, spellLevel, unitCount, unitName))
   end
   print("---------------------------------------------------------------------------")
end



---------------------------------------------------------------------------
-- Returns the max count for the building or unit with the specified
-- unit or building name if it has a max count, nil otherwise.
--- * name: The name of the unit or building to get the max count for.
--- * ownerHero: The hero of the caller.
---------------------------------------------------------------------------
function TechTree:GetMaxCountFor(name, ownerHero)
   if not ownerHero.TT.techDef[name] then
      print("ownerHero.TT.techDef["..name.."] was nil!")
   end
   return ownerHero.TT.techDef[name].max
end



---------------------------------------------------------------------------
-- Returns true if the unit is a hero.
--- * unit: The unit to check.
---------------------------------------------------------------------------
function TechTree:IsHero(unit)
   local heroName = unit:GetUnitName()
   if heroName == COMMANDER or heroName == FURION or heroName == GEOMANCER or heroName == KING_OF_THE_DEAD or heroName == WARLORD then
      return true
   else
      return false
   end
end



---------------------------------------------------------------------------
-- Print text if debug mode is on.
--
--	* funcName: The name of the function calling this.
--	* text: The text to print after funcName.
--
---------------------------------------------------------------------------
function print_simple_tech_tree(funcName, text)

   if DEBUG_SIMPLE_TECH_TREE == true then
      print("AbilityPages:"..funcName.."\t"..text)
   end
end
