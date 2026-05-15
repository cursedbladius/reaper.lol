local Registry = {}

local GameAdapters = {}

function Registry:Register(id, adapter)
    GameAdapters[id] = adapter
end

function Registry:Get()
    return GameAdapters[game.PlaceId] or GameAdapters[game.GameId] or nil
end

return Registry
