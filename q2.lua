function printSmallGuildNames(memberCount)
    -- this method is supposed to print names of all guilds that have less than memberCount max members
    -- max_members is not a field in the default tfs schema, will assume the necessary changes to db schema and guild creation code have been made
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))

    -- first check whether the query returns anything
    if resultId ~= false then
        -- loop through each result since it is very likely that multiple small guilds exist
        repeat
            -- pass in resultId
            local guildName = result.getString(resultId, "name")
            print(guildName)
        until not result.next(resultId)
    end
end
