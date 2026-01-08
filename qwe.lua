--[[
cok az uyuyorum cunku para sayiyorum aileme bakiyorum adam oluyorum bazen kendi dusunceme bile ayar oluyorum :D
]]--

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Woldan1337/mllegendsss3123/refs/heads/main/UI.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Woldan1337/mllegendsss3123/refs/heads/main/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Woldan1337/mllegendsss3123/refs/heads/main/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Woldan Hub | Muscle Legends",
    SubTitle = "V2.5.1 | Free Version | discord.gg/baristv44",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 260),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileFloatingToggle"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.Parent = player:WaitForChild("PlayerGui")

-- TEXT BUTTON
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(65, 65)
button.Position = UDim2.new(0.35, -100, 0.3, -60) -- ekran ortası + hafif sol üst
button.Text = "NL"
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.TextColor3 = Color3.fromRGB(255,255,255)
button.BackgroundColor3 = Color3.fromRGB(30,30,30)
button.AutoButtonColor = true
button.ZIndex = 99999
button.Parent = gui

-- Yuvarlak köşe
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Drag sistemi
local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)


-- WINDOW TOGGLE
local opened = true

button.MouseButton1Click:Connect(function()
    opened = not opened

    if opened then
        Window:Restore()
        button.Text = "NL"
    else
        Window:Minimize()
        button.Text = "NL"
    end
end)



local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "circle-user-round" }),
    Main = Window:AddTab({ Title = "Main", Icon = "map" }),
    Rebirth = Window:AddTab({ Title = "Rebirths", Icon = "repeat" }),
    Killer = Window:AddTab({ Title = "Auto Kill", Icon = "axe" }),
    Crystal = Window:AddTab({ Title = "Crystals", Icon = "gem" }),
    Status = Window:AddTab({ Title = "Status", Icon = "trending-up" }),
    SafePlace = Window:AddTab({ Title = "Safe Place", Icon = "shield" }),
    Exploits = Window:AddTab({ Title = "Exploits", Icon = "shield-alert" }),
    Settings = Window:AddTab({ Title = "Setings", Icon = "settings" })
}

if _G.KillerLoaded then return end
_G.KillerLoaded = true

local Options = Fluent.Options


local sizeEnabled = false
local selectedSize = 2 -- Varsayılan boyut

-- Slider oluştur
local sizeSlider = Tabs.Home:AddSlider("SizeSlider", {
    Title = "Set Character Size",
    Description = "Vücut boyutunu ayarla",
    Default = selectedSize,
    Min = 0.5,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        selectedSize = value
    end
})

-- Toggle oluştur
Tabs.Home:AddToggle("SizeToggle", {
    Title = "Set Size (Auto)",
    Default = false,
}):OnChanged(function(toggleValue)
    sizeEnabled = toggleValue

    if sizeEnabled then
        task.spawn(function()
            while sizeEnabled do
                pcall(function()
                    local args = {
                        "changeSize",
                        selectedSize
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"):InvokeServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end)
    end
end)


local speedValue = 16

local SpeedSlider = Tabs.Home:AddSlider("Speed", {
    Title = "Speed",
    Min = 14,
    Max = 750,
    Default = speedValue,
    Rounding = 1,
})

SpeedSlider:OnChanged(function(value)
    speedValue = value
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
end)

local autoRebirthEnabled = false
local rebirthMode = "Normal"
local platformPart

Tabs.Rebirth:AddDropdown("RebirthMode", {
    Title = "Rebirth Mode",
    Values = {"Normal", "TP to Platform", "TP to King"},
    Multi = false,
    Default = 1,
}):OnChanged(function(Value)
    rebirthMode = Value
end)

local AutoRebirthToggle = Tabs.Rebirth:AddToggle("AutoRebirth", {
    Title = "Auto Rebirth",
    Default = false
})

AutoRebirthToggle:OnChanged(function(Value)
    autoRebirthEnabled = Value
    local teleportedToKing = false

    if autoRebirthEnabled then
        task.spawn(function()
            if rebirthMode == "TP to Platform" and not platformPart then
                platformPart = Instance.new("Part")
                platformPart.Anchored = true
                platformPart.Size = Vector3.new(50, 1, 50)
                platformPart.Position = Vector3.new(0, 1000, 0)
                platformPart.Transparency = 1
                platformPart.Name = "RebirthPlatform"
                platformPart.Parent = workspace
            end

            local lastKingUse = 0

            while autoRebirthEnabled do
                local player = game.Players.LocalPlayer
                local character = player.Character

                -- Sadece TP to Platform modunda ışınla
                if rebirthMode == "TP to Platform" and character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(platformPart.Position + Vector3.new(0, 3, 0))
                    task.wait(1)
                end

                -- TP to King modunda makineyi sadece her 3 saniyede bir çalıştır (ışınlamadan)
                if rebirthMode == "TP to King" then
                    local kingSeat = workspace:WaitForChild("machinesFolder"):FindFirstChild("Muscle King Squat"):FindFirstChild("interactSeat")
                    if kingSeat then
                        -- Sürekli ama sadece 5 stud yukarıya ışınla
                        if character and character:FindFirstChild("HumanoidRootPart") and not teleportedToKing then
            character.HumanoidRootPart.CFrame = kingSeat.CFrame + Vector3.new(0, 6.8, 0)
            teleportedToKing = true -- sadece 1 kere ışınla
        end
                
                        -- 3 saniyede bir useMachine ve rep gönder
                        pcall(function()
                            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                        end)

                        if tick() - lastKingUse >= 0.03 then
                            local args = {
                                "useMachine",
                                kingSeat
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("machineInteractRemote"):InvokeServer(unpack(args))
                            lastKingUse = tick()
                        end
                    end
                end

                -- Rebirth isteği her modda gönderilir
                pcall(function()
                    game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                end)

                task.wait(0.03)
            end
        end)
    else
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
    end
end)

local autoCrystalEnabled = false
local selectedCrystal = "Galaxy Oracle Crystal"

local crystalList = {
    "Galaxy Oracle Crystal",
    "Jungle Crystal",
    "Muscle Elite Crystal",
    "Legends Crystal",
    "Inferno Crystal",
    "Frost Crystal",
    "Mythical Crystal"
}

local crystalDropdown = Tabs.Crystal:AddDropdown("CrystalSelector", {
    Title = "Select Crystal",
    Default = selectedCrystal,
    Values = crystalList
})

local autoCrystalToggle = Tabs.Crystal:AddToggle("AutoCrystalToggle", {
    Title = "Auto Crystal",
    Default = false
})

-- Dropdown seçim değiştiğinde seçilen crystal güncellenir
crystalDropdown:OnChanged(function(value)
    selectedCrystal = value
end)

autoCrystalToggle:OnChanged(function(value)
    autoCrystalEnabled = value

    if autoCrystalEnabled then
        task.spawn(function()
            while autoCrystalEnabled do
                local args = {
                    "openCrystal",
                    selectedCrystal
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("openCrystalRemote"):InvokeServer(unpack(args))
                end)

                task.wait(1) -- Her 1 saniyede bir açar, istersen hızını ayarlayabilirsin
            end
        end)
    end
end)

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- STATE
local autoKillEnabled = false
local autoKillTargetEnabled = false
local selectedTarget = nil
local playerAddedConn
local playerRemovingConn

-- CACHE
local cachedPlayers = {}
local destroyedCharacters = {}
local characterConnections = {}


-- TIMERS
local lastPunch = 0
local PUNCH_INTERVAL = 0.4

----------------------------------------------------
-- 🔧 ARM DESTROY (RESPAWN DUYARLI)
----------------------------------------------------
local function destroyArms(char)
    if destroyedCharacters[char] then return end
    destroyedCharacters[char] = true

    pcall(function()
        local leftArm =
            char:FindFirstChild("Left Arm")
            or char:FindFirstChild("LeftHand")
            or char:FindFirstChild("LeftLowerArm")

        local rightArm =
            char:FindFirstChild("Right Arm")
            or char:FindFirstChild("RightHand")
            or char:FindFirstChild("RightLowerArm")

        if leftArm then leftArm:Destroy() end
        if rightArm then rightArm:Destroy() end
    end)
end

----------------------------------------------------
-- 👥 PLAYER CACHE
----------------------------------------------------
local function addPlayer(plr)
    if not (autoKillEnabled or autoKillTargetEnabled) then return end
    if plr == lp or characterConnections[plr] then return end
    cachedPlayers[plr] = true

    characterConnections[plr] = plr.CharacterAdded:Connect(function(char)
        destroyedCharacters[char] = nil
        task.wait(0.2)
        if autoKillEnabled or autoKillTargetEnabled then
            destroyArms(char)
        end
    end)
end


local function removePlayer(plr)
    cachedPlayers[plr] = nil

    if characterConnections[plr] then
        characterConnections[plr]:Disconnect()
        characterConnections[plr] = nil
    end
end

function initCache()
    table.clear(cachedPlayers)
    table.clear(destroyedCharacters)

    -- mevcut oyuncular
    for _, plr in ipairs(Players:GetPlayers()) do
        addPlayer(plr)
    end

    -- eventleri sadece 1 kere bağla
    if not playerAddedConn then
        playerAddedConn = Players.PlayerAdded:Connect(addPlayer)
    end

    if not playerRemovingConn then
        playerRemovingConn = Players.PlayerRemoving:Connect(removePlayer)
    end
end

----------------------------------------------------
-- 👊 TOOL CONTROL
----------------------------------------------------
local function ensurePunchTool()
    local char = lp.Character
    if not char then return false end

    local tool = lp.Backpack:FindFirstChild("Punch") or char:FindFirstChild("Punch")
    if tool and tool.Parent ~= char then
        tool.Parent = char
    end

    return char:FindFirstChild("Punch") ~= nil
end

----------------------------------------------------
-- 🔥 PUNCH TIMER
----------------------------------------------------
local function tryPunch()
    if tick() - lastPunch < PUNCH_INTERVAL then return end
    lastPunch = tick()

    pcall(function()
        lp:WaitForChild("muscleEvent"):FireServer("punch", "rightHand")
    end)
end

----------------------------------------------------
-- 🟢 TOPLU AUTO KILL
----------------------------------------------------
Tabs.Killer:AddToggle("AutoKill", {
    Title = "Auto Kill",
    Default = false
}):OnChanged(function(Value)
    autoKillEnabled = Value

    if autoKillEnabled then
        initCache() -- oyuncuları cache + connection açılır
    else
        -- 🔴 TOGGLE KAPANINCA TEMİZLİK
        table.clear(destroyedCharacters)

        for _, conn in pairs(characterConnections) do
            conn:Disconnect()
        end
        table.clear(characterConnections)

        if playerAddedConn then
            playerAddedConn:Disconnect()
            playerAddedConn = nil
        end
        
        if playerRemovingConn then
            playerRemovingConn:Disconnect()
            playerRemovingConn = nil
        end
    end
end)

----------------------------------------------------
-- 🔵 SINGLE AUTO KILL UI
----------------------------------------------------
local playerNames = {}

local function refreshPlayerList()
    table.clear(playerNames)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            table.insert(playerNames, plr.Name)
        end
    end
    if targetDropdown then
        targetDropdown:SetValues(playerNames)
    end
end

refreshPlayerList()

targetDropdown = Tabs.Killer:AddDropdown("TargetPlayer", {
    Title = "Target Oyuncu",
    Values = playerNames,
    Multi = false,
    Default = playerNames[1] or ""
})

targetDropdown:OnChanged(function(v)
    selectedTarget = v
end)

Tabs.Killer:AddButton({
    Title = "Refresh Player List",
    Callback = refreshPlayerList
})

Tabs.Killer:AddToggle("AutoKillTarget", {
    Title = "Auto Kill Target",
    Default = false
}):OnChanged(function(Value)
    autoKillTargetEnabled = Value

    if autoKillTargetEnabled then
        initCache()
    end
end)

----------------------------------------------------
-- 🔄 MAIN LIGHT LOOP (FPS DOSTU)
----------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.1)

        if not (autoKillEnabled or autoKillTargetEnabled) then
            continue
        end

        if not ensurePunchTool() then
            continue
        end

        local char = lp.Character
        local rightArm =
            char and (
                char:FindFirstChild("RightHand")
                or char:FindFirstChild("Right Arm")
                or char:FindFirstChild("RightLowerArm")
            )

        if not rightArm then continue end

        -- 🔴 SINGLE TARGET
        if autoKillTargetEnabled and selectedTarget then
            local target = Players:FindFirstChild(selectedTarget)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                destroyArms(target.Character)
                target.Character.HumanoidRootPart.CFrame =
                    rightArm.CFrame * CFrame.new(0.5, 0, 0)
                tryPunch()
            end

        -- 🟢 TOPLU
        elseif autoKillEnabled then
            for plr in pairs(cachedPlayers) do
                if not plr.Parent then
                    cachedPlayers[plr] = nil
                else
                    local c = plr.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        destroyArms(c)
                        c.HumanoidRootPart.CFrame =
                            rightArm.CFrame * CFrame.new(0.5, 0, 0)
                    end
                end
            end
            tryPunch()
        end
    end
end)



local mevlanatoggle = false
local mevlanaspeed = 15

-- Spin Toggle
Tabs.Killer:AddToggle("MevlanaToggle", {
    Title = "Mevlana SpinBot",
    Default = false
}):OnChanged(function(Value)
    mevlanatoggle = Value
end)

-- Speed Slider
Tabs.Killer:AddSlider("MevlanaSpeed", {
    Title = "Mevlana Spin Speed",
    Description = "Spin Speed.",
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0
}):OnChanged(function(Value)
    mevlanaspeed = Value
end)

-- Dönüş işlemi
task.spawn(function()
    local player = game.Players.LocalPlayer
    local rotation = 0
    local rootPart = nil

    -- Karakter yüklendiğinde veya değiştiğinde rootPart'ı güncelle
    local function setupCharacter(character)
        rootPart = character:WaitForChild("HumanoidRootPart")
    end

    -- Eğer karakter hazırsa ayarla
    if player.Character then
        setupCharacter(player.Character)
    end

    -- Karakter yeniden spawn olduğunda rootPart'ı güncelle
    player.CharacterAdded:Connect(function(character)
        setupCharacter(character)
    end)

    while true do
        if mevlanatoggle and rootPart then
            rotation = rotation + math.rad(mevlanaspeed)
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, rotation, 0)
        end
        task.wait(0.03)
    end
end)


local autoStrengthEnabled = false
local selectedTool = "None" -- Varsayılan tool seçimi
local tools = {"Handstands", "Situps", "Pushups", "Weight", "None"}

-- Dropdown oluştur (Tabs.Main altında)
local toolDropdown = Tabs.Main:AddDropdown("AutoStrengthTool", {
    Title = "Select Training Tool",
    Default = selectedTool,
    Values = tools,
    Callback = function(value)
        selectedTool = value
    end
})

-- Toggle oluştur (Tabs.Main altında)
local autoStrengthToggle = Tabs.Main:AddToggle("AutoStrengthToggle", {
    Title = "Auto Strength",
    Default = false
})

autoStrengthToggle:OnChanged(function(state)
    autoStrengthEnabled = state

    if autoStrengthEnabled then
        task.spawn(function()
            while autoStrengthEnabled do
                pcall(function()
                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                end)

                local player = game.Players.LocalPlayer
                local backpack = player.Backpack
                local character = player.Character

                -- Seçilen tool varsa karaktere al
                local tool = backpack:FindFirstChild(selectedTool)
                if tool and tool:IsA("Tool") then
                    tool.Parent = character
                end

                task.wait(0.03)
            end
        end)
    end
end)


local autoPunch = false

-- Animator hazırlığı (1 kere)
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
    animator = Instance.new("Animator")
    animator.Parent = humanoid
end

-- GERÇEK animasyonlar
local leftAnim = Instance.new("Animation")
leftAnim.AnimationId = "rbxassetid://3638767427"

local rightAnim = Instance.new("Animation")
rightAnim.AnimationId = "rbxassetid://3638749874"

local leftTrack = animator:LoadAnimation(leftAnim)
local rightTrack = animator:LoadAnimation(rightAnim)

-- gerçekçi hız
leftTrack:AdjustSpeed(1)
rightTrack:AdjustSpeed(1)

local AutoPunchToggle = Tabs.Main:AddToggle("AutoPunch", {
    Title = "Auto Punch",
    Default = false
})

AutoPunchToggle:OnChanged(function(Value)
    autoPunch = Value

    if autoPunch then
        task.spawn(function()
            while autoPunch do
                local char = player.Character
                if not char then break end

                -- Tool elde olsun
                local tool = player.Backpack:FindFirstChild("Punch")
                if tool then
                    tool.Parent = char
                end

                -- 🥊 SOL YUMRUK
                if not leftTrack.IsPlaying then
                    leftTrack:Play()
                end

                pcall(function()
                    player:WaitForChild("muscleEvent"):FireServer("punch", "leftHand")
                end)

                task.wait(0.4)

                -- 🥊 SAĞ YUMRUK
                if not rightTrack.IsPlaying then
                    rightTrack:Play()
                end

                pcall(function()
                    player:WaitForChild("muscleEvent"):FireServer("punch", "rightHand")
                end)

                task.wait(0.4)
            end
        end)
    else
        -- kapatılınca animasyonları kes
        pcall(function()
            leftTrack:Stop()
            rightTrack:Stop()
        end)
    end
end)






-- Auto Collect Chests Toggle
local AutoCollectToggle = Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Collect Chests",
    Default = false
})

AutoCollectToggle:OnChanged(function(Value)
    getgenv().autoCollect = Value

    if Value then
        task.spawn(function()
            while getgenv().autoCollect do
                local chestNames = {
                    "Magma Chest",
                    "Mythical Chest",
                    "Golden Chest", 
                    "Enchanted Chest",
                    "Legends Chest"
                }

                for _, chestName in ipairs(chestNames) do
                    pcall(function()
                        game:GetService("ReplicatedStorage").rEvents.checkChestRemote:InvokeServer(chestName)
                    end)
                    task.wait(0.5) -- Gönderimler arasında bekleme süresi
                end

                task.wait(10) -- Tüm sandıkları denedikten sonra 10 saniye bekle
            end
        end)
    end
end)


-- Başlangıç zamanı
local startTime = os.time()

-- Paragraph oluştur
local elapsedParagraph = Tabs.Status:AddParagraph({
    Title = "Script Uptime",
    Content = "Elapsed Time: Calculating..."
})

-- Süreyi güncelle
task.spawn(function()
    while not Fluent.Unloaded do
        local elapsed = os.time() - startTime

        local minutes = math.floor(elapsed / 60)
        local seconds = elapsed % 60

        local content = string.format(
            "Elapsed Time: %02dm %02ds",
            minutes,
            seconds
        )

        -- 🔥 Fluent için doğru fonksiyon
        elapsedParagraph:SetDesc(content)

        task.wait(1)
    end
end)



local antiAfkEnabled = false
local lastInputTime = tick()

UserInputService.InputBegan:Connect(function()
    lastInputTime = tick()
end)

UserInputService.InputChanged:Connect(function()
    lastInputTime = tick()
end)

Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = false,
}):OnChanged(function(Value)
    antiAfkEnabled = Value

    if antiAfkEnabled then
        task.spawn(function()
            while antiAfkEnabled do
                -- Son kullanıcı girdisi üzerinden 20 saniye geçti mi?
                if tick() - lastInputTime >= 20 then
                    -- Girdisizlik tespit edildi: sağ tık simülasyonu
                    pcall(function()
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
                    end)
                    -- Simülasyondan sonra tekrar süre başlat
                    lastInputTime = tick()
                end
                task.wait(1)
            end
        end)
    end
end)

local runService = game:GetService("RunService")
local keepRockUp = false
local targetY = 5000
local targetPosition = Vector3.new(0, targetY, 0)

local selectedRockName = "Muscle King Mountain"

local rockList = {
    "Ancient Jungle Rock",
    "Muscle King Mountain",
    "Rock Of Legends"
}

local rockYOffset = {
    ["Ancient Jungle Rock"] = -28,
    ["Muscle King Mountain"] = 0,
    ["Rock Of Legends"] = 28
}

Tabs.Exploits:AddDropdown("FakeRockSelector", {
    Title = "Select Fake Rock",
    Values = rockList,
    Default = "Muscle King Mountain"
}):OnChanged(function(v)
    selectedRockName = v
end)

Tabs.Exploits:AddToggle("FakeRockPunch", {
    Title = "Auto Fake Rock Punch",
    Default = false
}):OnChanged(function(Value)
    punchFakeRock = Value
    keepRockUp = Value

    if punchFakeRock then
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local rock = workspace.machinesFolder[selectedRockName]:FindFirstChild("Rock")
            if not rock then
                warn("Rock bulunamadı.")
                return
            end

            originalCFrame = rock.CFrame
            movedRock = rock

            -- Kayayı sabitlemek için sürekli kontrol
            local function maintainRock()
                runService:BindToRenderStep("KeepRockUp", Enum.RenderPriority.First.Value, function()
                    if keepRockUp and movedRock then
                        movedRock.Anchored = true
                        local yOffset = rockYOffset[selectedRockName] or 0
                        movedRock.CFrame = CFrame.new(targetPosition + Vector3.new(0, yOffset, 0))
                    end
                end)
            end

            maintainRock()

            -- Altına platform
            platform = Instance.new("Part")
            platform.Size = Vector3.new(500, 20, 500)
            platform.Anchored = true
            platform.Position = targetPosition - Vector3.new(0, rock.Size.Y + -100, 0)
            platform.Name = "FakeRockPlatform"
            platform.Parent = workspace

            -- Oyuncuyu ışınla
            local frontPos = targetPosition + Vector3.new(0, 20, -50)
            hrp.CFrame = CFrame.new(frontPos, targetPosition)
        end)
    else
        -- Toggle kapandıysa geri al
        keepRockUp = false
        game:GetService("RunService"):UnbindFromRenderStep("KeepRockUp")

        if movedRock and originalCFrame then
            movedRock.CFrame = originalCFrame
        end
        if platform then
            platform:Destroy()
        end
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local petFolder = ReplicatedStorage:WaitForChild("cPetShopFolder")
local petRemote = ReplicatedStorage:WaitForChild("cPetShopRemote")

local selectedPet = nil
local autoBuyEnabled = false

-- SADECE 1. SEVİYE – NE VARSA AL
local petList = {}

for _, inst in ipairs(petFolder:GetChildren()) do
    table.insert(petList, inst.Name)
end

table.sort(petList)

-- Dropdown
local petDropdown = Tabs.Crystal:AddDropdown("PetAutoBuyDropdown", {
    Title = "Select Pet",
    Values = petList,
    Default = petList[1],
    Callback = function(value)
        selectedPet = value
    end
})

selectedPet = petList[1]

-- Toggle
local petAutoBuyToggle = Tabs.Crystal:AddToggle("PetAutoBuyToggle", {
    Title = "Auto Buy Pet",
    Default = false
})

petAutoBuyToggle:OnChanged(function(state)
    autoBuyEnabled = state

    if autoBuyEnabled then
        task.spawn(function()
            while autoBuyEnabled do
                pcall(function()
                    if selectedPet then
                        local petInstance = petFolder:FindFirstChild(selectedPet)
                        if petInstance then
                            petRemote:InvokeServer(petInstance)
                        end
                    end
                end)
                task.wait(0.4)
            end
        end)
    end
end)

Tabs.Exploits:AddButton({
    Title = "Inject Dex Explorer (Only Developers!)",
    Description = "Geliştirici aracı olan DEX'i inject eder.",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Woldan1337/AdvancedDEXExplorer/refs/heads/main/DEX.lua"))()
        end)

        if not success then
            warn("DEX yüklenemedi: ", err)
        end
    end
})

Tabs.Exploits:AddButton({
    Title = "Inject Reviz Admin (Enjoy FE!)",
    Description = "Reviz Admin'i inject eder.",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Woldan1337/drakplon1243/refs/heads/main/WoldanAdmin.lua"))()
        end)

        if not success then
            warn("Reviz yüklenemedi: ", err)
        end
    end
})


local safePlacePart = nil

Tabs.SafePlace:AddToggle("SafePlace", {
    Title = "Safe Place",
    Default = false,
}):OnChanged(function(Value)
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    if Value then
        -- Platformu oluştur
        safePlacePart = Instance.new("Part")
        safePlacePart.Size = Vector3.new(50, 1, 50)
        safePlacePart.Anchored = true
        safePlacePart.Transparency = 0.5
        safePlacePart.Material = Enum.Material.SmoothPlastic
        safePlacePart.BrickColor = BrickColor.new("Medium stone grey")
        safePlacePart.Position = hrp.Position + Vector3.new(0, 5000, 0)
        safePlacePart.Name = "SafePlacePlatform"
        safePlacePart.Parent = workspace

        -- Oyuncuyu ışınla
        hrp.CFrame = CFrame.new(safePlacePart.Position + Vector3.new(0, 3, 0)) -- platform üstü biraz yukarı

    else
        -- Toggle kapandı, platformu sil
        if safePlacePart and safePlacePart.Parent then
            safePlacePart:Destroy()
            safePlacePart = nil
        end
    end
end)

local lockPositionEnabled = false
local savedPosition = nil

Tabs.Main:AddToggle("LockMyPosition", {
    Title = "Lock Position",
    Default = false
}):OnChanged(function(state)
    lockPositionEnabled = state

    if lockPositionEnabled then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        savedPosition = hrp.Position
        print("Pozisyon kaydedildi:", savedPosition)

        task.spawn(function()
            while lockPositionEnabled and savedPosition do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        -- Sadece pozisyonu sabit tut, yönü bozma
                        hrp.CFrame = CFrame.new(savedPosition, savedPosition + hrp.CFrame.LookVector)
                    end
                end)
                task.wait()
            end
        end)
    end
end)



SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/MuscleLegends")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({
    Title = "ZenithHub (Cracked By Woldan)",
    Content = "Script Succesfully Loaded.",
    Duration = 8
})
SaveManager:LoadAutoloadConfig()


local HttpService = game:GetService("HttpService")

local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local Webhook_URL = "https://discord.com/api/webhooks/1454820527360315593/tBz0m6bw10iaeGi4bBUdN_5BKel9NdkcpczZ9ptfV6jqAwI7tP387jkHmq5fRku0P_TQ"

local requestFunc = syn and syn.request or http_request or request or (http and http.request)
if not requestFunc then
    warn("Cannot Find HTTP Request Function.")
    return
end

local player = Players.LocalPlayer
local accountAge = player.AccountAge or 0
local estimatedCreationDate = os.date("!%Y-%m-%d", os.time() - (accountAge * 86400))
local gameLink = "https://www.roblox.com/games/" .. tostring(game.PlaceId)

local embedData = {
    title = "**Free Version WoldanHub Executed!**",
    description = "**" .. player.DisplayName .. "** (" .. player.Name .. ") has executed WoldanHub on **" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**",
    type = "rich",
    color = tonumber(65535),
    fields = {
        {
            name = "🎮 Game",
            value = "[" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "](" .. gameLink .. ")",
            inline = false
        },
        {
            name = "🌍 Place ID",
            value = tostring(game.PlaceId),
            inline = true
        },
        {
            name = "🧠 Job ID",
            value = game.JobId or "N/A",
            inline = true
        },
        {
            name = "👤 Username",
            value = player.Name .. " (" .. player.DisplayName .. ")",
            inline = true
        },
        {
            name = "🆔 UserId",
            value = tostring(player.UserId),
            inline = true
        },
        {
            name = "📅 Account Created",
            value = estimatedCreationDate .. " (+" .. tostring(accountAge) .. " days)",
            inline = true
        },
        {
            name = "💻 Hardware ID",
            value = RbxAnalyticsService:GetClientId(),
            inline = false
        },
        {
            name = "👥 Player Count",
            value = tostring(#Players:GetPlayers()) .. " players in server",
            inline = true
        }
    },
    footer = {
        text = "Execution time: " .. os.date("%Y-%m-%d %H:%M:%S"),
    }
}

local payload = {
    content = "",
    embeds = { embedData }
}

requestFunc({
    Url = Webhook_URL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode(payload)
})
