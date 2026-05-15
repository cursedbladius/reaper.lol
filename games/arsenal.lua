local Arsenal = {}

function Arsenal:GetToolTargets(playerName)
    local targets = {}

    local repStorage = game:GetService("ReplicatedStorage")
    local viewmodels = nil
    for _, child in pairs(repStorage:GetChildren()) do
        if child.Name == "Viewmodels" then
            viewmodels = child
            break
        end
    end
    if not viewmodels then
        warn("[Arsenal] Viewmodels folder NOT found")
        return targets
    end

    for _, child in pairs(viewmodels:GetChildren()) do
        if child.Name:sub(1, 2) == "v_" then
            table.insert(targets, child)
        end
    end

    warn("[Arsenal] Found", #targets, "viewmodel targets")
    return targets
end

return Arsenal
