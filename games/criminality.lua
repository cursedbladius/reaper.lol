local Criminality = {}

function Criminality:GetToolTargets(playerName)
    local targets = {}
    local localPlayer = game:GetService("Players").LocalPlayer

    local charsFolder = nil
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "Characters" then
            charsFolder = child
            break
        end
    end
    if not charsFolder then return targets end

    local charFolder = nil
    for _, child in pairs(charsFolder:GetChildren()) do
        if child.Name == playerName then
            charFolder = child
            break
        end
    end
    if not charFolder then return targets end

    local displayItems = charFolder:FindFirstChild("DisplayItems")
    if displayItems then
        table.insert(targets, displayItems)
    end

    local character = localPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local wsTool = charFolder:FindFirstChild(tool.Name)
            if wsTool then
                table.insert(targets, wsTool)
            end
        end
    end

    return targets
end

return Criminality
