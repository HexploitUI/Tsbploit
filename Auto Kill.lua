-- AutoKill (Execution and Hotkey Behavior)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local spammingM1 = false
local spammingKeys = false
local spamM1Connection
local spamKeysConnection
local teleportConnection

local lastKeyPressTime = 0  -- To track the last key press time for cooldown (5 seconds)
local lockedPlayer = nil    -- Variable to store the locked player

-- Ensure _G.AutoKill is set and initialize it
if _G.AutoKill == nil then
    _G.AutoKill = false  -- Default value if not previously set
end

-- Function to update character reference
local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
end

-- Call updateCharacter on character respawn
player.CharacterAdded:Connect(updateCharacter)

local function getClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health >= 2 then  -- Only consider players with 2 or more health
                local distance = (character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end

    return closestPlayer
end

local function teleportToBehindLockedPlayer()
    if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = lockedPlayer.Character.HumanoidRootPart
        local targetPosition = targetHRP.Position
        local targetLookVector = targetHRP.CFrame.LookVector

        -- Calculate the position 2 studs behind the target
        local behindPosition = targetPosition - (targetLookVector * 3)

        -- Set your character's position and make it face the target
        character.HumanoidRootPart.CFrame = CFrame.new(behindPosition, targetPosition)
        print("Teleported instantly to 2 studs behind " .. lockedPlayer.Name)
    else
        warn("Locked player is no longer available.")
        lockedPlayer = nil  -- Reset locked player if no longer available
    end
end

local function startTeleporting()
    teleportConnection = RunService.Stepped:Connect(function()
        -- If no player is locked or the locked player's health is 1 or less, get the closest player and lock onto them
        if not lockedPlayer or (lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("Humanoid") and lockedPlayer.Character.Humanoid.Health <= 1) then
            -- Unlock current player and immediately lock onto the next closest player
            lockedPlayer = getClosestPlayer()
            if lockedPlayer then
                print("Locked onto new player: " .. lockedPlayer.Name)
                -- Send notification for locking onto a new player
                game.StarterGui:SetCore("SendNotification", {Title="Auto Kill"; Text="Locked onto " .. lockedPlayer.Name; Duration=5;})


                -- Send "Destroyed" message when a new player is locked onto
                game.StarterGui:SetCore("SendNotification", {Title="Auto Kill"; Text=lockedPlayer.Name .. " Destroyed"; Duration=5;})


            else
                print("No players nearby to lock onto.")
            end
        end

        -- Continue teleporting to the locked player instantly once their humanoid health is 1 or lower
        if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = lockedPlayer.Character.Humanoid
            if humanoid.Health <= 1 then
                -- Unlock the current player and find a new one
                print(lockedPlayer.Name .. " has reached 1 health or less. Unlocking target and locking onto next closest player.")
                lockedPlayer = nil  -- Unlock the current player
                lockedPlayer = getClosestPlayer()  -- Lock onto the next player immediately
                if lockedPlayer then
                    -- Send notification when locking onto a new player
                    game.StarterGui:SetCore("SendNotification", {Title="Auto Kill"; Text="Locked onto " .. lockedPlayer.Name; Duration=5;})
                    print("Locked onto new player: " .. lockedPlayer.Name)
                else
                    print("No players nearby to lock onto.")
                end
            else
                teleportToBehindLockedPlayer()
            end
        end
        wait(0.1) -- Adjust delay as needed
    end)
    print("Started teleporting 2 studs behind the locked player instantly.")
end

local function stopTeleporting()
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    print("Stopped teleporting.")
end

local function startSpamM1()
    spammingM1 = true
    spamM1Connection = RunService.RenderStepped:Connect(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    print("Started spamming M1.")
end

local function stopSpamM1()
    spammingM1 = false
    if spamM1Connection then
        spamM1Connection:Disconnect()
        spamM1Connection = nil
    end
    print("Stopped spamming M1.")
end

local function startSpamKeys()
    spammingKeys = true
    spamKeysConnection = RunService.RenderStepped:Connect(function()
        -- Check if enough time has passed for cooldown (5 seconds)
        if tick() - lastKeyPressTime >= 5 then
            -- Spam keys 1, 2, 3, 4, and Q
            for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Q, Enum.KeyCode.G}) do
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                lastKeyPressTime = tick()  -- Update the last key press time
            end
        end
        wait(0.1) -- Adjust delay as needed
    end)
    print("Started spamming keys 1, 2, 3, 4, and Q.")
end

local function stopSpamKeys()
    spammingKeys = false
    if spamKeysConnection then
        spamKeysConnection:Disconnect()
        spamKeysConnection = nil
    end
    print("Stopped spamming keys 1, 2, 3, 4, and Q.")
end

-- Function to instantly stop all actions
local function stopAllActions()
    stopTeleporting()
    stopSpamM1()
    stopSpamKeys()
end

-- Enable and Disable script via hotkey (T)
local function toggleHotkey()
    if _G.AutoKill then
        -- Disable the script
        stopAllActions()
        game.StarterGui:SetCore("SendNotification", {Title="Auto Kill Disabled"; Text="🎭  Hexploit 🎭"; Duration=5;})
        print("Auto Kill Disabled")
        _G.AutoKill = false  -- Set AutoKill to false (disabled)
    else
        -- Enable the script
        game.StarterGui:SetCore("SendNotification", {Title="Auto Kill Enabled"; Text="🎭  Hexploit 🎭"; Duration=5;})
        print("Auto Kill Enabled")
        _G.AutoKill = true  -- Set AutoKill to true (enabled)
        lockedPlayer = getClosestPlayer()  -- Lock onto the nearest player
        if lockedPlayer then
            print("Locked onto new player: " .. lockedPlayer.Name)
            -- Send notification for locking onto a new player
            game.StarterGui:SetCore("SendNotification", {Title="Auto Kill"; Text="Locked onto " .. lockedPlayer.Name; Duration=5;})
        else
            print("No players nearby to lock onto.")
        end
        startTeleporting()
        startSpamM1()
        startSpamKeys()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.T then
            toggleHotkey()
        end
    end
end)

-- Load and Unload script notifications (do not change _G.AutoKill state)
local function toggleScriptExecution()
    if _G.AutoKill then
        game.StarterGui:SetCore("SendNotification", {Title="Auto Kill Unloaded"; Text="🎭  Hexploit 🎭"; Duration=5;})
        -- Unload the script
        stopAllActions()
        print("Auto Kill Unloaded")
    else
        game.StarterGui:SetCore("SendNotification", {Title="Auto Kill Loaded"; Text="🎭  Hexploit 🎭"; Duration=5;})
        print("Auto Kill Loaded")
    end
end

-- Run this script once for execution state (loads and unloads on first/second execution)
toggleScriptExecution()
