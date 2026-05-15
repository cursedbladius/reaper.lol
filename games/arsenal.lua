local Arsenal = {}

function Arsenal:GetToolTargets(playerName)
    local targets = {}
    local viewmodels = game:GetService("ReplicatedStorage"):FindFirstChild("Viewmodels")
    if not viewmodels then return targets end

    for _, child in pairs(viewmodels:GetChildren()) do
        if child.Name:sub(1, 2) == "v_" then
            table.insert(targets, child)
        end
    end

    return targets
end

return Arsenal
