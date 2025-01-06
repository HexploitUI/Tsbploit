repeat wait() until game:IsLoaded()

-- Initialize the global state variable if it does not exist
if _G.ToggleCounter == nil then
    _G.ToggleCounter = 1 -- First execution state
end

-- Function to show notifications
local function showNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- Check for toggle state based on the counter
if _G.ToggleCounter == 1 then
    showNotification("Hitbox Expander Enabled", "🎭  Hexploit 🎭")
    _G.Disabled = true -- Enable the effect
    _G.ToggleCounter = 2 -- Move to the next state (disable)
elseif _G.ToggleCounter == 2 then
    showNotification("Hitbox Expander Disabled", "🎭  Hexploit 🎭")
    _G.Disabled = false -- Disable the effect
    _G.ToggleCounter = 3 -- Move to the next state (enable)
elseif _G.ToggleCounter == 3 then
    showNotification("Hitbox Expander Enabled", "🎭  Hexploit 🎭")
    _G.Disabled = true -- Enable the effect
    _G.ToggleCounter = 4 -- Move to the next state (disable)
elseif _G.ToggleCounter == 4 then
    showNotification("Hitbox Expander Disabled", "🎭  Hexploit 🎭")
    _G.Disabled = false -- Disable the effect
    _G.ToggleCounter = 1 -- Reset to the first state (enable)
end

-- The logic for the rest of your functionality
_G.HeadSize = 16 -- Default size of the hitbox

game:GetService('RunService').RenderStepped:connect(function()
    -- Only proceed with the logic if the effect is enabled
    if not _G.Disabled then
        -- When disabled, reset all hitbox visual properties
        for i, v in next, game:GetService('Players'):GetPlayers() do
            if v.Name ~= game:GetService('Players').LocalPlayer.Name then
                pcall(function()
                    local character = v.Character
                    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart then
                        -- Reset hitbox to its default state when disabled
                        humanoidRootPart.Size = Vector3.new(2, 2, 1)  -- Reset to default size
                        humanoidRootPart.Transparency = 1  -- Make it fully invisible (no box)
                    end
                end)
            end
        end
        return -- Exit early if disabled
    end

    -- If Disabled is true, the effect will be active
    for i, v in next, game:GetService('Players'):GetPlayers() do
        if v.Name ~= game:GetService('Players').LocalPlayer.Name then
            pcall(function()
                local character = v.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoidRootPart then
                    if humanoid.Health <= 10 then
                        -- Hide the hitbox when health is 10 or lower
                        humanoidRootPart.Size = Vector3.new(0, 0, 0)
                        humanoidRootPart.Transparency = 1
                    else
                        -- Default hitbox size is 25
                        humanoidRootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        humanoidRootPart.Transparency = 0.8
                        humanoidRootPart.BrickColor = BrickColor.new("White")
                        humanoidRootPart.Material = "Neon"
                        humanoidRootPart.CanCollide = false
                    end
                end
            end)
        end
    end
end)
