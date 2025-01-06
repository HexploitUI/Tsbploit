-- Teleport to 2 Studs Behind the Closest Player and Toggle M1 + Key Spamming (Including Q) Script
-- Ensure this script is run in Roblox: Da Hood

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local spammingM1 = false
local spammingKeys = false
local spamM1Connection
local spamKeysConnection
local teleportConnection

local lastKeyPressTime = 0  -- To track the last key press time for cooldown
local lockedPlayer = nil    -- Variable to store the locked player

-- Function to update the character reference
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
            local distance = (character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = otherPlayer
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
        local behindPosition = targetPosition - (targetLookVector * 2)

        -- Set your character's position and make it face the target
        character.HumanoidRootPart.CFrame = CFrame.new(behindPosition, targetPosition)
        print("Teleported to 2 studs behind " .. lockedPlayer.Name)
    else
        warn("Locked player is no longer available.")
        lockedPlayer = nil  -- Reset locked player if no longer available
    end
end

local function startTeleporting()
    teleportConnection = game:GetService("RunService").Stepped:Connect(function()
        -- If no player is locked, get the closest player and lock onto them
        if not lockedPlayer or (lockedPlayer and lockedPlayer.Character and lockedPlayer.Character.Humanoid.Health <= 0) then
            lockedPlayer = getClosestPlayer()
            if lockedPlayer then
                print("Locked onto " .. lockedPlayer.Name)
            else
                print("No players nearby to lock onto.")
            end
        end

        -- Continue teleporting to the locked player until their humanoid health is 0
        if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = lockedPlayer.Character.Humanoid
            if humanoid.Health <= 0 then
                print(lockedPlayer.Name .. " has died. Unlocking target and locking onto next closest player.")
                lockedPlayer = getClosestPlayer()  -- Lock onto the next closest player
                if lockedPlayer then
                    print("Locked onto " .. lockedPlayer.Name)
                else
                    print("No players nearby to lock onto.")
                end
            else
                teleportToBehindLockedPlayer()
            end
        end
        wait(0.1)
    end)
    print("Started teleporting 2 studs behind the locked player every 0.1 seconds.")
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
    spamM1Connection = game:GetService("RunService").RenderStepped:Connect(function()
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
    spamKeysConnection = game:GetService("RunService").RenderStepped:Connect(function()
        -- Check if enough time has passed for cooldown (5 seconds)
        if tick() - lastKeyPressTime >= 5 then
            -- Spam keys 1, 2, 3, 4, and Q
            for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Q}) do
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then -- Press 'T' to toggle teleport, M1 spam, and key spamming
        if spammingM1 or spammingKeys or teleportConnection then
            stopAllActions()  -- Instantly stop all actions if they are active
        else
            startTeleporting()
            startSpamM1()
            startSpamKeys()
        end
    end
end)

print("Teleport, M1, and Keybind Spamming script loaded. Press 'T' to teleport 2 studs behind the locked player every 0.1 seconds and spam M1 + keys 1, 2, 3, 4, and Q.")
