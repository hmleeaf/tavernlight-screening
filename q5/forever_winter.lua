-- default tfs combatArea encoding: 0 = ignore, 1 = send effect, 2 = player but no effect, 3 = player and effect
local damageArea = {
	{ 0, 0, 0, 1, 0, 0, 0 },
	{ 0, 0, 1, 0, 1, 0, 0 },
	{ 0, 1, 0, 1, 0, 1, 0 },
	{ 1, 0, 1, 0, 3, 0, 1 },
	{ 0, 1, 0, 1, 0, 1, 0 },
	{ 0, 0, 1, 0, 1, 0, 0 },
	{ 0, 0, 0, 1, 0, 0, 0 },
}

-- custom encoding for scheduling tornado effects
-- 0 = ignore /// 1 to maxGroups = group number /// > maxGroups = also ignore
-- 100 = player but no effect /// 100 + N = player and effect in group N
local visualArea = {
	{ 0, 0, 0, 4, 0,   0, 0 },
	{ 0, 0, 2, 0, 2,   0, 0 },
	{ 0, 1, 0, 4, 0,   2, 0 },
	{ 1, 0, 3, 0, 101, 0, 1 },
	{ 0, 1, 0, 2, 0,   2, 0 },
	{ 0, 0, 1, 0, 3,   0, 0 },
	{ 0, 0, 0, 1, 0,   0, 0 },
}

local maxGroups = 4       -- number of groups in the visual area grid, should correspond to the maximum number in the grid (consider with player value - 100)
local delayPerGroup = 250 -- time (ms) of delay per group (dpg), e.g. if dpg = 250 and maxGroups = 4, then group 1 = 0ms, group 2 = 250ms, etc
local cycles = 3          -- number of times all groups repeat, if cycles = 3, each group will execute 3 times, with maxGroups * delayPerGroup between each cycle



local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE) -- set damage element type
combat:setArea(createCombatArea(damageArea))             -- set damage area

-- a random damage value copied from another file
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 8) + 50
	local max = (level / 5) + (magicLevel * 12) + 75
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")



local spell = Spell("instant")

-- a local function wrapper for the Position:sendMagicEffect function to be sent in addEvent
local function sendWinterEffect(position)
	position:sendMagicEffect(CONST_ME_ICETORNADO)
end

-- schedules effect to be sent to position in group
local function scheduleWinterEffect(group, position)
	for c = 1, cycles do
		-- (group - 1) * delayPerGroup: calculates the stagger/delay between different groups
		-- 		e.g. group 1 gets 0ms delay, group 2 gets 250ms delay, etc
		-- (c - 1) * delayPerGroup * maxGroups: calculates the delay between complete cycles
		-- 		e.g. cycle 1 group 1 gets 0ms delay, cycle 2 group 1 gets 1000ms delay
		addEvent(sendWinterEffect, (group - 1) * delayPerGroup + (c - 1) * delayPerGroup * maxGroups, position)
	end
end

-- execution callback
function spell.onCastSpell(creature, variant)
	-- first cache the position of the creature
	local creaturePosition = creature:getPosition()

	-- find and store the x and y index of the creature in the visualArea grid
	local creatureXIdx = 0
	local creatureYIdx = 0

	for j = 1, #visualArea do
		for i = 1, #visualArea[j] do
			local cellValue = visualArea[j][i]

			-- [100, 100 + maxGroups] = player
			if (cellValue >= 100 and cellValue <= 100 + maxGroups) then
				creatureXIdx = i
				creatureYIdx = j
			end
		end
	end

	-- for each cell in the visualArea grid, calculate its screen position and push that into the corresponding group table
	for j = 1, #visualArea do
		for i = 1, #visualArea[j] do
			local cellValue = visualArea[j][i]

			-- only act on the non-ignore cells
			if (cellValue > 0 and cellValue <= maxGroups) then
				-- find index offset relative to creature's position
				local xOffset = i - creatureXIdx
				local yOffset = j - creatureYIdx

				-- calculate cell's screen position relative to creature's screen position using relative index offset
				local cellPosition = Position(creaturePosition.x - xOffset, creaturePosition.y - yOffset,
					creaturePosition.z)

				-- schedule effect
				scheduleWinterEffect(cellValue, cellPosition)
			end

			-- also check the case that an effect should be placed on the player's cell
			if (cellValue > 100 and cellValue <= 100 + maxGroups) then
				scheduleWinterEffect(cellValue - 100, creaturePosition)
			end
		end
	end

	-- finally send execute for sending damage
	return combat:execute(creature, variant)
end

spell:name("Forever Winter")
spell:words("frigo")
spell:group("attack")
spell:vocation("sorcerer", "master sorcerer")
spell:id(24)
spell:cooldown(2000)
spell:groupCooldown(2000)
spell:level(8)
spell:mana(10)
spell:isSelfTarget(true)
spell:isPremium(false)
spell:register()
