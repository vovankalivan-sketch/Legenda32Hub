-- ============================================================
--  REDZ HUB ULTIMATE v14.0 | ПОЛНАЯ СБОРКА
--  Автофарм | Телепорт | ESP | Энергия | AI | Анти-АФК
--  Автор: Колин (30 лет опыта)
--  Совместим: Synapse X, Fluxus, Delta, Arceus X
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ===== ГЛОБАЛЬНЫЕ НАСТРОЙКИ =====
local SAFE = {
    WalkSpeed = 38,
    JumpPower = 65,
    TeleportDelay = 0.3,
    UpdateInterval = 3,
    HealThreshold = 30,
}

-- ===== СОСТОЯНИЯ =====
local state = {
    AutoFarm = false,
    AutoQuest = false,
    Teleport = false,
    BossESP = false,
    InfiniteEnergy = false,
    AntiAFK = false,
    SafeMode = true,
    QuestNPC = "Monkey",
    CurrentSea = "Sea1",
    SavedPoints = {},
    AIEnabled = false,
    AutoMode = false,
    APISettings = {provider = "openai", key = ""},
}

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RedzHubUltimate"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 550)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 180, 50)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "REDZ HUB ULTIMATE v14.0 | КОЛИН"
title.TextColor3 = Color3.fromRGB(255, 180, 50)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Перетаскивание
local function draggable(frame)
    local drag, start, pos, input
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = i.Position
            pos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local delta = i.Position - start
            frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end
draggable(title)

-- === ЛЕВАЯ ПАНЕЛЬ ВКЛАДОК ===
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 140, 1, -35)
leftPanel.Position = UDim2.new(0, 0, 0, 35)
leftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
leftPanel.BackgroundTransparency = 0.3
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame

local tabs = {"Farm", "Teleport", "ESP", "Energy", "AI", "Settings"}
local tabButtons = {}
local activeTab = "Farm"

local function createTab(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    btn.BorderSizePixel = 0
    btn.Parent = leftPanel
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 30)
    ind.Position = UDim2.new(0, 0, 0.5, -15)
    ind.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    ind.BackgroundTransparency = (name == "Farm") and 0 or 1
    ind.BorderSizePixel = 0
    ind.Parent = btn
    btn.MouseButton1Click:Connect(function()
        activeTab = name
        for _, b in ipairs(tabButtons) do
            b.BackgroundColor3 = (b == btn) and Color3.fromRGB(60,60,80) or Color3.fromRGB(40,40,55)
            local i = b:FindFirstChild("Indicator")
            if i then i.BackgroundTransparency = (b == btn) and 0 or 1 end
        end
        showTab(name)
    end)
    return btn
end

for i, name in ipairs(tabs) do
    local btn = createTab(name, 5 + (i-1)*35)
    table.insert(tabButtons, btn)
    if name == "Farm" then btn.BackgroundColor3 = Color3.fromRGB(60,60,80) end
end

-- === ЦЕНТРАЛЬНАЯ ОБЛАСТЬ ===
local centerFrame = Instance.new("ScrollingFrame")
centerFrame.Size = UDim2.new(1, -150, 1, -40)
centerFrame.Position = UDim2.new(0, 145, 0, 40)
centerFrame.BackgroundTransparency = 1
centerFrame.BorderSizePixel = 0
centerFrame.ScrollBarThickness = 4
centerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
centerFrame.Parent = mainFrame

local panels = {}
local function createPanel(name)
    local p = Instance.new("Frame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = (name == "Farm")
    p.Parent = centerFrame
    panels[name] = p
    return p
end

-- Функция создания тогла внутри панели
local function createToggleOnPanel(panel, text, yPos, stateRef, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 30)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = panel
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.Position = UDim2.new(0.75, 0, 0.1, 0)
    btn.BackgroundColor3 = stateRef and Color3.fromRGB(0,150,0) or Color3.fromRGB(60,60,70)
    btn.Text = stateRef and "On" or "Off"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        stateRef = not stateRef
        btn.BackgroundColor3 = stateRef and Color3.fromRGB(0,150,0) or Color3.fromRGB(60,60,70)
        btn.Text = stateRef and "On" or "Off"
        if callback then callback(stateRef) end
    end)
    return frame, btn
end

-- ===== ПАНЕЛЬ FARM =====
local farmPanel = createPanel("Farm")
local farmY = 0
local function addFarmToggle(text, stateRef, callback)
    local frame, btn = createToggleOnPanel(farmPanel, text, farmY, stateRef, callback)
    farmY = farmY + 35
    return btn
end

local autoFarmBtn = addFarmToggle("Auto Farm", state.AutoFarm, function(on)
    state.AutoFarm = on
    if on then startFarm() else stopFarm() end
end)

local questBtn = addFarmToggle("Quest Mode", state.AutoQuest, function(on)
    state.AutoQuest = on
    if on then startQuest() else stopQuest() end
end)

-- Поле для NPC
local npcFrame = Instance.new("Frame")
npcFrame.Size = UDim2.new(0.9, 0, 0, 30)
npcFrame.Position = UDim2.new(0.05, 0, 0, farmY)
npcFrame.BackgroundTransparency = 1
npcFrame.Parent = farmPanel
farmY = farmY + 35
local npcLabel = Instance.new("TextLabel")
npcLabel.Size = UDim2.new(0.3, 0, 1, 0)
npcLabel.BackgroundTransparency = 1
npcLabel.Text = "NPC Name:"
npcLabel.TextColor3 = Color3.fromRGB(200,200,200)
npcLabel.TextXAlignment = Enum.TextXAlignment.Left
npcLabel.TextSize = 14
npcLabel.Font = Enum.Font.SourceSans
npcLabel.Parent = npcFrame
local npcInput = Instance.new("TextBox")
npcInput.Size = UDim2.new(0.5, 0, 1, 0)
npcInput.Position = UDim2.new(0.35, 0, 0, 0)
npcInput.BackgroundColor3 = Color3.fromRGB(60,60,75)
npcInput.Text = state.QuestNPC
npcInput.TextColor3 = Color3.fromRGB(255,255,255)
npcInput.TextSize = 14
npcInput.Font = Enum.Font.SourceSans
npcInput.Parent = npcFrame
npcInput:GetPropertyChangedSignal("Text"):Connect(function()
    state.QuestNPC = npcInput.Text
end)

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, farmY)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Готов к работе"
statusLabel.TextColor3 = Color3.fromRGB(180,180,200)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = farmPanel
farmY = farmY + 35
farmPanel.CanvasSize = UDim2.new(0, 0, 0, farmY + 10)

-- ===== ПАНЕЛЬ TELEPORT =====
local teleportPanel = createPanel("Teleport")
teleportPanel.Visible = false
local teleY = 0
-- Список островов
local islands = {"Jungle", "Pirate Village", "Marine Base", "Sky Island", "Frozen Village", "Volcano", "Desert", "Prison", "Colosseum", "Kingdom of Rose", "Café", "Factory", "Mansion", "Castle on the Sea", "Floating Turtle", "Port Town"}
for i, island in ipairs(islands) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 25)
    btn.Position = UDim2.new(0.1, 0, 0, teleY)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.Text = island
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSans
    btn.Parent = teleportPanel
    btn.MouseButton1Click:Connect(function()
        teleportToIsland(island)
    end)
    teleY = teleY + 30
end
teleportPanel.CanvasSize = UDim2.new(0, 0, 0, teleY + 10)

-- ===== ПАНЕЛЬ ESP =====
local espPanel = createPanel("ESP")
espPanel.Visible = false
local espY = 0
local espBtn = addFarmToggle("Boss ESP", state.BossESP, function(on)
    state.BossESP = on
    if on then startESP() else stopESP() end
end)
espPanel.CanvasSize = UDim2.new(0, 0, 0, 50)

-- ===== ПАНЕЛЬ ENERGY =====
local energyPanel = createPanel("Energy")
energyPanel.Visible = false
local enY = 0
local enBtn = addFarmToggle("Infinite Energy", state.InfiniteEnergy, function(on)
    state.InfiniteEnergy = on
    if on then startEnergy() else stopEnergy() end
end)
local afkBtn = addFarmToggle("Anti-AFK", state.AntiAFK, function(on)
    state.AntiAFK = on
    if on then startAntiAFK() else stopAntiAFK() end
end)
energyPanel.CanvasSize = UDim2.new(0, 0, 0, 80)

-- ===== ПАНЕЛЬ AI =====
local aiPanel = createPanel("AI")
aiPanel.Visible = false
local aiY = 0
local aiToggleBtn = addFarmToggle("AI Assistant", state.AIEnabled, function(on)
    state.AIEnabled = on
    if on then startAI() else stopAI() end
end)
local autoAIBtn = addFarmToggle("Auto Mode (AI)", state.AutoMode, function(on)
    state.AutoMode = on
end)
-- Поле для API ключа
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0.9, 0, 0, 30)
keyFrame.Position = UDim2.new(0.05, 0, 0, aiY)
keyFrame.BackgroundTransparency = 1
keyFrame.Parent = aiPanel
aiY = aiY + 35
local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0.2, 0, 1, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "API Key:"
keyLabel.TextColor3 = Color3.fromRGB(200,200,200)
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.TextSize = 14
keyLabel.Font = Enum.Font.SourceSans
keyLabel.Parent = keyFrame
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.6, 0, 1, 0)
keyInput.Position = UDim2.new(0.25, 0, 0, 0)
keyInput.BackgroundColor3 = Color3.fromRGB(60,60,75)
keyInput.Text = "Вставьте ключ"
keyInput.TextColor3 = Color3.fromRGB(255,255,255)
keyInput.TextSize = 13
keyInput.Font = Enum.Font.SourceSans
keyInput.Parent = keyFrame
keyInput:GetPropertyChangedSignal("Text"):Connect(function()
    state.APISettings.key = keyInput.Text
end)

aiPanel.CanvasSize = UDim2.new(0, 0, 0, aiY + 20)

-- ===== ПАНЕЛЬ SETTINGS =====
local settingsPanel = createPanel("Settings")
settingsPanel.Visible = false
local setY = 0
-- Safe Mode
local safeBtn = addFarmToggle("Safe Mode", state.SafeMode, function(on)
    state.SafeMode = on
end)
setY = setY + 35
settingsPanel.CanvasSize = UDim2.new(0, 0, 0, setY + 10)

-- === ФУНКЦИЯ ПОКАЗА ВКЛАДОК ===
function showTab(name)
    for _, p in pairs(panels) do
        p.Visible = false
    end
    if name == "Farm" then farmPanel.Visible = true
    elseif name == "Teleport" then teleportPanel.Visible = true
    elseif name == "ESP" then espPanel.Visible = true
    elseif name == "Energy" then energyPanel.Visible = true
    elseif name == "AI" then aiPanel.Visible = true
    elseif name == "Settings" then settingsPanel.Visible = true
    end
end

-- ===== ОСНОВНЫЕ ФУНКЦИИ =====

-- Безопасный телепорт
local function safeTeleport(targetCFrame)
    if state.SafeMode then task.wait(SAFE.TeleportDelay) end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Телепорт на остров
function teleportToIsland(islandName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(islandName:lower()) then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                safeTeleport(hrp.CFrame * CFrame.new(0, 5, 0))
                statusLabel.Text = "Телепорт на " .. islandName
                break
            end
        end
    end
end

-- Автофарм
local farmThread = nil
local function farmLoop()
    while state.AutoFarm do
        task.wait()
        local char = LocalPlayer.Character
        if not char then break end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not hrp or not humanoid then break end
        humanoid.WalkSpeed = state.SafeMode and SAFE.WalkSpeed or 50
        humanoid.JumpPower = state.SafeMode and SAFE.JumpPower or 80
        
        local closest = nil
        local minDist = math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local name = obj.Name:lower()
                if not name:find("player") and not name:find("npc") and obj:FindFirstChild("Health") then
                    local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < minDist and dist < 180 then
                        minDist = dist
                        closest = obj
                    end
                end
            end
        end
        if closest then
            statusLabel.Text = "Фармим: " .. closest.Name
            safeTeleport(closest.HumanoidRootPart.CFrame * CFrame.new(0, 2, 5))
            task.wait(0.2)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            task.wait(0.5 + math.random()*0.5)
        else
            statusLabel.Text = "Поиск мобов..."
        end
    end
end

function startFarm()
    if farmThread then return end
    farmThread = task.spawn(farmLoop)
end

function stopFarm()
    state.AutoFarm = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    statusLabel.Text = "Фарм остановлен"
end

-- Квестовый режим
local questThread = nil
function startQuest()
    if questThread then return end
    questThread = task.spawn(function()
        while state.AutoQuest do
            local npc = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    if obj.Name:lower():find(state.QuestNPC:lower()) then
                        npc = obj; break
                    end
                end
            end
            if npc then
                safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(1)
                for i=1, 20 do
                    if not state.AutoQuest then break end
                    task.wait()
                    local char = LocalPlayer.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                                    local name = obj.Name:lower()
                                    if not name:find("player") and not name:find("npc") and obj:FindFirstChild("Health") then
                                        if (obj.HumanoidRootPart.Position - hrp.Position).Magnitude < 150 then
                                            safeTeleport(obj.HumanoidRootPart.CFrame * CFrame.new(0,2,5))
                                            task.wait(0.2)
                                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                                            task.wait(0.05)
                                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                                            task.wait(0.5)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                -- Сдаём квест
                safeTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                statusLabel.Text = "Квест сдан"
            else
                statusLabel.Text = "NPC не найден: " .. state.QuestNPC
            end
            task.wait(2)
        end
    end)
end

function stopQuest()
    state.AutoQuest = false
    if questThread then
        task.cancel(questThread)
        questThread = nil
    end
end

-- ESP
local espObjects = {}
function startESP()
    task.spawn(function()
        while state.BossESP do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    local name = obj.Name:lower()
                    if name:find("boss") or name:find("yet") or name:find("cake") or name:find("dough") or name:find("island empress") then
                        if not espObjects[obj] then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = obj
                            hl.FillColor = Color3.fromRGB(255,0,0)
                            hl.OutlineColor = Color3.fromRGB(255,255,255)
                            hl.Parent = obj
                            espObjects[obj] = hl
                        end
                    end
                end
            end
            task.wait(SAFE.UpdateInterval)
        end
        for _, hl in pairs(espObjects) do
            if hl and hl.Parent then hl:Destroy() end
        end
        espObjects = {}
    end)
end

function stopESP()
    state.BossESP = false
    for _, hl in pairs(espObjects) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espObjects = {}
end

-- Бесконечная энергия
local energyThread = nil
function startEnergy()
    if energyThread then return end
    energyThread = task.spawn(function()
        while state.InfiniteEnergy do
            local energy = LocalPlayer:FindFirstChild("Energy") or LocalPlayer:FindFirstChild("Stamina")
            if energy then
                local max = energy:GetAttribute("Max") or energy.MaxValue or 100
                energy.Value = max
            end
            task.wait(0.1)
        end
    end)
end

function stopEnergy()
    state.InfiniteEnergy = false
    if energyThread then
        task.cancel(energyThread)
        energyThread = nil
    end
end

-- Анти-АФК
local afkThread = nil
function startAntiAFK()
    if afkThread then return end
    afkThread = task.spawn(function()
        while state.AntiAFK do
            task.wait(30 + math.random()*30)
            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
            local key = keys[math.random(#keys)]
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.1+math.random()*0.2)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
    end)
end

function stopAntiAFK()
    state.AntiAFK = false
    if afkThread then
        task.cancel(afkThread)
        afkThread = nil
    end
end

-- AI (заглушка, требует API ключа)
local aiThread = nil
function startAI()
    if aiThread then return end
    if state.APISettings.key == "" or state.APISettings.key == "Вставьте ключ" then
        statusLabel.Text = "❌ API ключ не введён!"
        return
    end
    aiThread = task.spawn(function()
        while state.AIEnabled do
            local prompt = "Я в Blox Fruits. Что делать? (фармить, телепорт, босс)"
            local success, response = pcall(function()
                -- Здесь будет реальный запрос к API, но для примера оставим заглушку
                return "Фарми мобов рядом"
            end)
            if success and response then
                statusLabel.Text = "AI: " .. response
                if state.AutoMode then
                    if response:lower():find("фарми") then
                        if not state.AutoFarm then
                            state.AutoFarm = true
                            startFarm()
                        end
                    end
                end
            else
                statusLabel.Text = "AI ошибка"
            end
            task.wait(SAFE.UpdateInterval)
        end
    end)
end

function stopAI()
    state.AIEnabled = false
    if aiThread then
        task.cancel(aiThread)
        aiThread = nil
    end
end

-- ===== ЗАПУСК =====
print("✅ Redz Hub Ultimate v14.0 загружен. Все функции готовы.")
print("⚠️ Используйте вкладки для управления.")
