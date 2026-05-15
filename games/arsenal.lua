local Arsenal = {}

function Arsenal:GetToolTargets(playerName)
    local targets = {}

    local wrapName = "HWRAP_" .. playerName
    local wrap = nil
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == wrapName then
            wrap = child
            break
        end
    end
    if not wrap then return targets end

    for _, child in pairs(wrap:GetChildren()) do
        if child.Name == "Gun" then
            table.insert(targets, child)
            break
        end
    end

    return targets
end

return Arsenal
