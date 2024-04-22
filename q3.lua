-- this method kicks a member (with membername) from the player's (with playerId) party
-- unsure of specifications, but if player names can be duplicated, using id of member instead of name would eliminate kicking all members with the same name
function kickMemberFromPlayerParty(playerId, membername)
    -- player is only needed locally, so add local keyword to not affect a global player if any
    local player = Player(playerId)
    local party = player:getParty()

    -- discard the key for clarity since it's not needed
    -- also rename v to member for readability
    for _, member in pairs(party:getMembers()) do
        -- we can compare name strings instead of querying a new Player and comparing by reference
        if member:getName() == membername then
            party:removeMember(Player(membername))
        end
    end
end
