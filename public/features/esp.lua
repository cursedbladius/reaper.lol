local Players = game:GetService("Players")
        if humanoid.Health <= 0 then
            continue
        end

        if self.Flags.visuals_teamcheck then
            if player.Team == LocalPlayer.Team then

                local existing = self.Objects[player]

                if existing then
                    existing.Highlight.Enabled = false
                    existing.Billboard.Enabled = false
                end

                continue
            end
        end

        local localCharacter = LocalPlayer.Character

        if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then

            local distance = (
                localCharacter.HumanoidRootPart.Position - root.Position
            ).Magnitude

            if distance > (self.Flags.visuals_distance or 2500) then

                local existing = self.Objects[player]

                if existing then
                    existing.Highlight.Enabled = false
                    existing.Billboard.Enabled = false
                end

                continue
            end

        end

        self:Create(player)

        local objects = self.Objects[player]

        if self.Flags.visuals_occluded then

            if not self:IsVisible(character) then
                objects.Highlight.Enabled = false
                objects.Billboard.Enabled = false
                continue
            end

        end

        objects.Highlight.Enabled = self.Flags.visuals_chams
        objects.Highlight.FillColor = self.Flags.visuals_chams_color or Color3.fromRGB(255,0,0)
        objects.Highlight.OutlineColor = self.Flags.visuals_boxes_color or Color3.fromRGB(255,255,255)

        local materialName = self.Flags.visuals_chams_material or "Plastic"
        local material = MaterialMap[materialName]

        if material then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = material
                end
            end
        end

        objects.Billboard.Enabled = self.Flags.visuals_names
        objects.Text.Text = player.Name
        objects.Text.TextColor3 = self.Flags.visuals_names_color or Color3.fromRGB(255,255,255)

    end

end

Players.PlayerRemoving:Connect(function(player)

    if ESP.Objects[player] then
        ESP:Remove(player)
    end

end)

return ESP
