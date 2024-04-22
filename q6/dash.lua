local dashTick = 50 -- time (ms) between dashing across each tile
local distance = 6  -- number tiles to dash across


local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)


-- store reference to creature player between function calls
player = nil

-- wrapper for addEvent
local function teleportPlayerTo(position)
	player:teleportTo(position)
end

-- a rewrite of position:getNextPosition as a local function
-- get a next position from position in direction for step(s)
local function getNextPosition(position, direction, step)
	if step == nil then
		step = 1
	end

	if direction == DIRECTION_NORTH then
		return Position(position.x, position.y - step, position.z)
	elseif direction == DIRECTION_EAST then
		return Position(position.x + step, position.y, position.z)
	elseif direction == DIRECTION_SOUTH then
		return Position(position.x, position.y + step, position.z)
	elseif direction == DIRECTION_WEST then
		return Position(position.x - step, position.y, position.z)
	end
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant, isHotkey)
	player = creature

	-- schedule a move event for each step
	for i = 1, distance do
		-- get the position to move to for this step, in the direction of the creature faces
		local movePosition = getNextPosition(creature:getPosition(), creature:getDirection(), i)

		-- get the tile at position, and check if tile is walkable
		local tile = Tile(movePosition)
		if (tile:isWalkable() == true) then
			-- schedule event to teleport to the position
			addEvent(teleportPlayerTo, (i - 1) * dashTick, movePosition)
		else
			-- break loop if any tile is not walkable
			break
		end
	end

	return combat:execute(creature, variant)
end

spell:name("Dash")
spell:words("dash")
spell:group("attack")
spell:vocation("sorcerer", "master sorcerer")
spell:id(25)
spell:cooldown(2000)
spell:groupCooldown(2000)
spell:level(8)
spell:mana(10)
spell:isSelfTarget(true)
spell:isPremium(false)
spell:register()
