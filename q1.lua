-- make function takes in a storageKey as well, and encapsulate the entire logic including the conditional check for better readability
local function releaseStorage(player, storageKey)
    -- suppose -1 means invalid for storage item 1000,
    -- we should compare whether the value IS NOT -1 instead of IS 1 in case that the item can take on other values
    if player:getStorageValue(storageKey) ~= -1 then
        -- remove addEvent as it adds an unnecessary 1000ms delay to the execution
        player:setStorageValue(storageKey, -1)
    end
end

function onLogout(player)
    -- ideally, the arbitrary key 1000 should be a useful constant stored in a table of constants somewhere
    -- this line just presents such a common doing to improve readability
    local CONSTSTORAGEKEY_SOMETHING = 1000
    releaseStorage(player, CONSTSTORAGEKEY_SOMETHING)
    return true
end
