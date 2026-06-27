local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Track active animation connections so we can disconnect on re-init (prevents stacking)
local activeConnections = {}

local function disconnectAll()
    for _, conn in ipairs(activeConnections) do
        conn:Disconnect()
    end
    activeConnections = {}
end

local function trackConnection(conn)
    table.insert(activeConnections, conn)
end

-- Helper: get torso for R6 and R15
local function getTorso(character)
    return character:FindFirstChild("Torso")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("HumanoidRootPart")
end

-- Helper: stop all playing animation tracks
local function stopAllAnimations(humanoid)
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

-- Helper: load and play a custom animation via Animator
local function playCustomAnimation(humanoid, animId, speed, timePosition)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    local track = animator:LoadAnimation(anim)
    track:Play()

    if speed ~= nil then track:AdjustSpeed(speed) end
    if timePosition ~= nil then track.TimePosition = timePosition end

    return track
end

-- Helper: create and play a sound at a part (with nil guard)
local function playSound(soundId, volume, parent)
    if not parent then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = parent
    sound:Play()
    return sound
end

-- ============================================================
-- MAIN SETUP — called on start and after each respawn
-- ============================================================
local function initializeSetup()
    disconnectAll() -- Clear old listeners before re-binding

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- 1. Hotbar UI — wait properly so the UI has time to load
    task.spawn(function()
        task.wait(1) -- Give the game UI time to initialize

        local hotbarGui = playerGui:WaitForChild("Hotbar", 10)
        if not hotbarGui then return end

        local backpack = hotbarGui:WaitForChild("Backpack", 5)
        if not backpack then return end

        local hotbar = backpack:WaitForChild("Hotbar", 5)
        if not hotbar then return end

        local slotNames = { "Justice", "Hatred Slash's", "Error Force", "Perseverance" }
        for i, name in ipairs(slotNames) do
            local slot = hotbar:FindFirstChild(tostring(i))
            if slot then
                local base = slot:FindFirstChild("Base")
                local toolName = base and base:FindFirstChild("ToolName")
                if toolName then
                    toolName.Text = name
                end
            end
        end
    end)

    -- 2. Magic Health Bar UI
    task.spawn(function()
        local screenGui = playerGui:FindFirstChild("ScreenGui")
        local magicHealth = screenGui and screenGui:FindFirstChild("MagicHealth")

        if magicHealth then
            local textLabel = magicHealth:FindFirstChild("TextLabel")
            local healthFrame = magicHealth:FindFirstChild("Health")
            local barFrame = healthFrame and healthFrame:FindFirstChild("Bar")
            local bar = barFrame and barFrame:FindFirstChild("Bar")

            if textLabel then textLabel.Text = "HATE" end
            if bar then bar.ImageColor3 = Color3.fromRGB(0, 0, 0) end
        end
    end)

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- 3. Animation Listener — Fang OneInch
    trackConnection(humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId ~= "rbxassetid://10468665991" then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        stopAllAnimations(hum)
        playCustomAnimation(hum, "rbxassetid://13073745835", 1)
        task.wait(0.6)

        local resources = ReplicatedStorage:FindFirstChild("Resources")
        local dash3 = resources
            and resources:FindFirstChild("Fang")
            and resources.Fang:FindFirstChild("OneInch")
            and resources.Fang.OneInch:FindFirstChild("dash3")

        if dash3 then
            local function colorPE(part)
                if part and part:IsA("ParticleEmitter") then
                    part.Color = ColorSequence.new(Color3.new(1, 1, 0))
                end
            end
            colorPE(dash3:FindFirstChild("Flash"))
            colorPE(dash3:FindFirstChild("Smoke"))
            local vfx = dash3:FindFirstChild("VFX")
            if vfx then
                colorPE(vfx:FindFirstChild("Strik5"))
                colorPE(vfx:FindFirstChild("Strike1"))
                colorPE(vfx:FindFirstChild("Strike2"))
                colorPE(vfx:FindFirstChild("Strike3"))
            end
        end

        playSound("rbxassetid://455251724", 7, getTorso(char))

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local oneInch = resources
            and resources:FindFirstChild("Fang")
            and resources.Fang:FindFirstChild("OneInch")

        if hrp and oneInch then
            for _ = 1, 20 do
                for _, child in ipairs(oneInch:GetDescendants()) do
                    if child:IsA("ParticleEmitter") then
                        local clone = child:Clone()
                        clone.Parent = hrp
                        clone:Emit(15)
                    end
                end
                task.wait(0.001)
            end
        end
    end))

    -- 4. Animation Listener — FiveSeasonsFX
    trackConnection(humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId ~= "rbxassetid://10466974800" then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        stopAllAnimations(hum)
        local animTrack = playCustomAnimation(hum, "rbxassetid://15436668469", 1)
        animTrack.TimePosition = 0
        animTrack:AdjustSpeed(2.1)

        local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local resources = ReplicatedStorage:FindFirstChild("Resources")
        local jumpMeshes = resources
            and resources:FindFirstChild("FiveSeasonsFX")
            and resources.FiveSeasonsFX:FindFirstChild("JumpMeshes")
        local torso = getTorso(char)

        for _ = 1, 13 do
            playSound("rbxassetid://9113213247", 3, torso)

            if leftArm and jumpMeshes then
                for _, child in ipairs(jumpMeshes:GetDescendants()) do
                    if child:IsA("ParticleEmitter") then
                        local clone = child:Clone()
                        clone.Parent = leftArm
                        clone:Emit(3)
                    end
                end
            end
            task.wait(0.1)
        end
    end))

    -- 5. Animation Listener — Camera Dash Forward
    --    FIX: speed was 0 (animation was frozen), changed to 1
    trackConnection(humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId ~= "rbxassetid://10471336737" then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        stopAllAnimations(hum)
        playCustomAnimation(hum, "rbxassetid://17838006839", 1, 0.5) -- FIX: was speed=0
        task.wait(0.5)

        playSound("rbxassetid://942127495", 7, getTorso(char))

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lookVector = workspace.CurrentCamera.CFrame.LookVector
            local direction = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * 50
            local targetPosition = hrp.Position + Vector3.new(direction.X, 0, direction.Z)

            TweenService:Create(
                hrp,
                TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { CFrame = CFrame.new(targetPosition) }
            ):Play()
        end
    end))

    -- 6. Animation Listener — Meteor Purple Particles
    --    FIX: speed was 0 (animation was frozen), changed to 1
    trackConnection(humanoid.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId ~= "rbxassetid://12510170988" then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        stopAllAnimations(hum)
        playCustomAnimation(hum, "rbxassetid://16699717165", 1, 3.5) -- FIX: was speed=0

        playSound("rbxassetid://3140268287", 7, getTorso(char))
        task.wait(0.5)

        local resources = ReplicatedStorage:FindFirstChild("Resources")
        local manfrick = resources
            and resources:FindFirstChild("Meteor")
            and resources.Meteor:FindFirstChild("MANFRICK")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if manfrick then
            local manfrickPart = manfrick:FindFirstChild("MANFRICK")
            local attachment = manfrickPart and manfrickPart:FindFirstChild("Attachment")
            if attachment then
                for _, child in ipairs(attachment:GetChildren()) do
                    if child:IsA("ParticleEmitter") then
                        child.Color = ColorSequence.new(Color3.fromRGB(128, 0, 128))
                    end
                end
            end

            if hrp then
                for _, child in ipairs(manfrick:GetDescendants()) do
                    if child:IsA("ParticleEmitter") then
                        local clone = child:Clone()
                        clone.Parent = hrp
                        clone:Emit(5)
                    end
                end
            end
        end
    end))

    -- 7. Error Tool — FIX: check for existing tool before creating to avoid duplicates
    local existingTool = LocalPlayer.Backpack:FindFirstChild("Error")
        or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Error"))

    if not existingTool then
        local mouse = LocalPlayer:GetMouse()
        local tool = Instance.new("Tool")
        tool.Name = "Error"
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer.Backpack

        tool.Activated:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum then
                local animTrack = playCustomAnimation(hum, "rbxassetid://15957361339", 1)
                task.delay(0.7, function()
                    if animTrack then animTrack:Stop() end
                end)
            end

            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    playSound("rbxassetid://15956555583", 1, hrp) -- FIX: nil guard

                    if mouse.Hit then
                        hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    end
                end
            end
        end)
    end
end

-- Run initial setup
initializeSetup()

-- ============================================================
-- 8. BodyVelocity lock — strip vertical velocity from constraints
-- ============================================================
local function lockBodyVelocity(instance)
    if instance:IsA("BodyVelocity") then
        instance.Velocity = Vector3.new(instance.Velocity.X, 0, instance.Velocity.Z)
    end
end

local function hookVelocityLocks(char)
    char.DescendantAdded:Connect(lockBodyVelocity)
    for _, descendant in ipairs(char:GetDescendants()) do
        lockBodyVelocity(descendant)
    end
end

if LocalPlayer.Character then
    hookVelocityLocks(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(hookVelocityLocks)

-- ============================================================
-- 9. "But it refused." — Respawn overlay mechanic
-- ============================================================
local lastDeathCFrame = nil
local currentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local currentHumanoid = currentCharacter:WaitForChild("Humanoid")

currentHumanoid.Died:Connect(function()
    local hrp = currentCharacter:FindFirstChild("HumanoidRootPart")
    if hrp then lastDeathCFrame = hrp.CFrame end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    currentCharacter = newCharacter
    currentHumanoid = newCharacter:WaitForChild("Humanoid")

    currentHumanoid.Died:Connect(function()
        local hrp = newCharacter:FindFirstChild("HumanoidRootPart")
        if hrp then lastDeathCFrame = hrp.CFrame end
    end)

    if lastDeathCFrame then
        local hrp = newCharacter:WaitForChild("HumanoidRootPart")
        hrp.CFrame = lastDeathCFrame
        lastDeathCFrame = nil

        task.delay(0.01, function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = playerGui

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.Parent = screenGui

            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Size = UDim2.new(0.2, 0, 0.2, 0)
            imageLabel.Position = UDim2.new(0.4, 0, 0.3, 0)
            imageLabel.Image = "rbxassetid://17570156948" -- FIX: was http://www.roblox.com/asset/?id=
            imageLabel.BackgroundTransparency = 1
            imageLabel.Parent = frame

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 0.1, 0)
            textLabel.Position = UDim2.new(0, 0, 0.6, 0)
            textLabel.Text = "But it refused."
            textLabel.TextColor3 = Color3.new(1, 0, 0)
            textLabel.TextSize = 48
            textLabel.Font = Enum.Font.Arcade
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextTransparency = 1
            textLabel.Parent = frame

            task.wait(2)

            local torso = getTorso(newCharacter)
            playSound("rbxassetid://7022295490", 7, torso)

            imageLabel.Image = "rbxassetid://6532468448" -- FIX: was http://www.roblox.com/asset/?id=

            for _ = 1, 50 do
                imageLabel.Position = imageLabel.Position
                    + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
                task.wait(0.05)
            end

            -- Re-bind all listeners for the new character
            initializeSetup()

            imageLabel.Image = "rbxassetid://17570156948" -- FIX: was http://www.roblox.com/asset/?id=
            playSound("rbxassetid://8500212950", 7, torso)

            textLabel.TextTransparency = 0
            task.wait(2)

            for i = 0, 1, 0.05 do
                frame.BackgroundTransparency = i
                imageLabel.ImageTransparency = i
                textLabel.TextTransparency = i
                textLabel.TextStrokeTransparency = i
                task.wait(0.05)
            end

            screenGui:Destroy()
        end)
    end
end)
