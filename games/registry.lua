local Registry = {}

local GameAdapters = {}

function Registry:Register(placeId, adapter)
    GameAdapters[placeId] = adapter
end

function Registry:Get()
    return GameAdapters[game.PlaceId] or nil
end

return Registry
