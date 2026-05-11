-- =======================================================
-- ★ Legenda32Hub — Версия 4.0 (Noclip + Crystal Chest) ★
-- =======================================================

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Сетевой обход для вызова функций игры
local RawRemoteFunc = nil
local RawRemoteEvent = nil

pcall(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network", 5)
    if networkFolder then
        for _, obj in ipairs(networkFolder:GetChildren()) do
            if obj:IsA("RemoteFunction") then RawRemoteFunc = obj end
            if obj:IsA("RemoteEvent") then RawRemoteEvent = obj end
        end
    end
end)

local function FireNetworkEvent(...)
    if RawRemoteEvent then RawRemoteEvent:FireServer(...) end
end

local function InvokeNetworkFunc(...)
    if RawRemoteFunc then return RawRemoteFunc:InvokeServer(...) end
end

-- Безопасное определение папки интерфейса для Delta Executor
local targetGuiFolder = player:WaitForChild("PlayerGui", 5) or game:GetService("CoreGui")

if targetGuiFolder:FindFirstChild("Legenda32Hub_Gui") then
    targetGuiFolder:FindFirstChild("Legenda32Hub_Gui"):Destroy()
end

_G.Legenda32Settings = {
    WalkSpeedBoost = 0,
    Noclip = false,
    AutoFarmZone = false,
    FarmZoneTarget = "Last",
    AutoRankQuests = false,
    AutoCollectRewards = false,
    AutoBeggingBot = false,
    AutoServerHop = false,
    AutoPlaceFlags = false,
    AutoOpenCrystalChest = false,
    AntiAfk = false
}

local russianPhrases = {
    "можешь пожалуйста чем то помочь хочу дойти с нуля до гаргантюа",
    "можешь пожалуйста что нибудь подарить я новичек",
    "привет! я только зашел в игру, подкиньте плиз любого пета для старта",
    "ребята, помогите подняться с нуля, буду очень благодарен за гемы или алмазы",
    "коплю на гаргантюа, не хватает совсем немного, выручите алмазами пожалуйста",
    "ребят, дайте плиз любого ненужного пета, хочу собрать нормальную команду"
}

local englishPhrases = {
    "hi! i am new here, can anyone spare some diamonds or low tier pets please?",
    "hey friend, just started from scratch, any trash pet or gems helps a lot!",
    "road to gargantua! please help me reach my dream, any diamonds help!",
    "please be my hero today! nobody wants to help a beginner on this server :(",
    "can you please help me with something? I want to get to gargantua from scratch",
    "i will pray for your titanic luck if you can give me some free gems or pets!"
}

local processedPlayers = {}
local activeToggles = {} 

Players.PlayerRemoving:Connect(function(leftPlayer)
    processedPlayers[leftPlayer.UserId] = nil
end)

-- 1. Создание основы интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Legenda32Hub_Gui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGuiFolder

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 450)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "★ Legenda32Hub ★"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton
closeButton.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -50)
sidebar.Position = UDim2.new(0, 10, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = sidebar
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 3)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -150, 1, -50)
container.Position = UDim2.new(0, 140, 0, 45)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local pages = {}
local tabButtons = {}

local function createTab(name, icon, order)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 28)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = icon .. "  " .. name
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 12
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.LayoutOrder = order
    tabButton.Parent = sidebar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.Parent = tabButton

    local pageScroll = Instance.new("ScrollingFrame")
    pageScroll.Size = UDim2.new(1, 0, 1, 0)
    pageScroll.BackgroundTransparency = 1
    pageScroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    pageScroll.ScrollBarThickness = 4
    pageScroll.Visible = false
    pageScroll.Parent = container

    local pageList = Instance.new("UIListLayout")
    pageList.Parent = pageScroll
    pageList.Padding = UDim.new(0, 8)

    pages[name] = pageScroll
    tabButtons[name] = tabButton

    tabButton.MouseButton1Click:Connect(function()
        for pageName, frame in pairs(pages) do
            frame.Visible = (pageName == name)
            tabButtons[pageName].TextColor3 = (pageName == name) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
            tabButtons[pageName].BackgroundTransparency = (pageName == name) and 0 or 1
            if pageName == name then tabButtons[pageName].BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        end
    end)
end

-- Инициализация 5 мобильных вкладок
createTab("Farm", "🌾", 1)
createTab("Items", "🎒", 2)
createTab("Player", "⚡", 3)
createTab("Trading", "🏪", 4) 
createTab("Misc", "⚙️", 5)

pages["Farm"].Visible = true
tabButtons["Farm"].TextColor3 = Color3.fromRGB(0, 255, 150)
tabButtons["Farm"].BackgroundTransparency = 0
tabButtons["Farm"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function createToggle(parent, text, configKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local function updateVisuals(state)
        if state then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    activeToggles[configKey] = { Button = btn, Update = updateVisuals, Callback = callback }

    btn.MouseButton1Click:Connect(function()
        _G.Legenda32Settings[configKey] = not _G.Legenda32Settings[configKey]
        updateVisuals(_G.Legenda32Settings[configKey])
        task.spawn(callback, _G.Legenda32Settings[configKey])
    end)
end

-- =======================================================
-- 📍 ВКЛАДКА [ ITEMS ] (Сундуки и Флаги)
-- =======================================================
createToggle(pages["Items"], "Auto Place Flags", "AutoPlaceFlags", function(toggled)
    while toggled and _G.Legenda32Settings.AutoPlaceFlags do
        FireNetworkEvent("Flags: Activate", "Magnet Flag")
        task.wait(1)
        FireNetworkEvent("Flags: Activate", "Fortune Flag")
        task.wait(295) 
    end
end)

createToggle(pages["Items"], "Auto Open Crystal Chest", "AutoOpenCrystalChest", function(toggled)
    while toggled and _G.Legenda32Settings.AutoOpenCrystalChest do
        -- Отправка пакетного запроса на открытие хрустального сундука (Crystal Chest)
        FireNetworkEvent("CrystalChest: Open", "Crystal Key")
        task.wait(1.5) -- Небольшая задержка анимации во избежание кика за спам
    end
end)

createToggle(pages["Items"], "Auto Use Potions (Luck)", "Dummy1", function() end)
createToggle(pages["Items"], "Auto Vending Machines", "Dummy2", function() end)

-- =======================================================
-- 📍 ВКЛАДКА [ FARM ]
-- =======================================================
local function getTargetZoneFolder()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    local targetInput = string.lower(tostring(_G.Legenda32Settings.FarmZoneTarget))
    
    if targetInput == "last" or targetInput == "0" or targetInput == "" then
        local lastZone = nil
        local maxNum = -1
        for _, zone in ipairs(mapFolder:GetChildren()) do
            local num = tonumber(string.match(zone.Name, "^(%d+)"))
            if num and num > maxNum then maxNum = num lastZone = zone end
        end
        return lastZone
    end
    
    for _, zone in ipairs(mapFolder:GetChildren()) do
        local zoneNameLower = string.lower(zone.Name)
        if string.find(zoneNameLower, targetInput) then
            return zone
        end
    end
    return nil
end

local zoneTitleText = Instance.new("TextLabel")
zoneTitleText.Size = UDim2.new(1, -5, 0, 20)
zoneTitleText.BackgroundTransparency = 1
zoneTitleText.Text = "Target Zone Name / Number (0 or Last = Auto)"
zoneTitleText.TextColor3 = Color3.fromRGB(150, 150, 150)
zoneTitleText.Font = Enum.Font.SourceSansBold
zoneTitleText.TextSize = 13
zoneTitleText.Parent = pages["Farm"]

local zoneInput = Instance.new("TextBox")
zoneInput.Size = UDim2.new(1, -5, 0, 38)
zoneInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
zoneInput.Text = "Last"
zoneInput.TextColor3 = Color3.fromRGB(0, 255, 150)
zoneInput.Font = Enum.Font.SourceSansBold
zoneInput.TextSize = 14
zoneInput.Parent = pages["Farm"]
local zic = Instance.new("UICorner") zic.CornerRadius = UDim.new(0, 6) zic.Parent = zoneInput

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, -5, 0, 35)
zoneLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
zoneLabel.Text = "Detecting Target Zone..."
zoneLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneLabel.Font = Enum.Font.SourceSansItalic
zoneLabel.TextSize = 14
zoneLabel.Parent = pages["Farm"]
local zc = Instance.new("UICorner") zc.CornerRadius = UDim.new(0, 6) zc.Parent = zoneLabel

zoneInput.FocusLost:Connect(function()
    local text = tostring(zoneInput.Text)
    if text ~= "" then _G.Legenda32Settings.FarmZoneTarget = text else _G.Legenda32Settings.FarmZoneTarget = "Last" zoneInput.Text = "Last" end
end)

task.spawn(function()
    while true do
        if mainFrame.Visible and pages["Farm"].Visible then
            local currentZone = getTargetZoneFolder()
            if currentZone then
                zoneLabel.Text = "📍 Farming Location: " .. string.gsub(currentZone.Name, "^%d+%.%s*", "")
            else zoneLabel.Text = "❌ Location Not Found / Locked" end
        end
        task.wait(1.5)
    end
end)

createToggle(pages["Farm"], "Auto Farm Selected Zone", "AutoFarmZone", function(toggled)
    while toggled and _G.Legenda32Settings.AutoFarmZone do
        local farmZone = getTargetZoneFolder()
        if farmZone and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = farmZone:FindFirstChild("PERSISTENT") or farmZone:FindFirstChild("Collider") or farmZone:FindFirstChildOfClass("Part")
            if targetPart then
                InvokeNetworkFunc("Hoverboard: Set State", true)
                player.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
        task.wait(4)
    end
end)

createToggle(pages["Farm"], "Auto Rank Quests", "AutoRankQuests", function(toggled)
    while toggled and _G.Legenda32Settings.AutoRankQuests do
        local breakables = workspace:FindFirstChild("Breakables")
        if breakables then
            for _, obj in ipairs(breakables:GetChildren()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - obj:GetModelCFrame().Position).Magnitude
                    if dist < 150 then 
                        FireNetworkEvent("Breakables: Player Click", obj.Name) 
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

createToggle(pages["Farm"], "Auto Collect Rewards", "AutoCollectRewards", function(toggled)
    while toggled and _G.Legenda32Settings.AutoCollectRewards do
        for i = 1, 12 do 
            FireNetworkEvent("Playtime Rewards: Claim", i) 
        end
        task.wait(45)
    end
end)

-- =======================================================
-- 📍 ВКЛАДКА [ PLAYER ] (WalkSpeed и Обновленный Noclip)
-- =======================================================
createToggle(pages["Player"], "Noclip (Walk Through Walls)", "Noclip", function(toggled)
    -- Функция полностью отключает коллизию всех частей тела персонажа
    local noclipConnection
    if toggled then
        noclipConnection = RunService.Stepped:Connect(function()
            if _G.Legenda32Settings.Noclip and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end)

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -5, 0, 20)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "WalkSpeed Increase (%)"
speedTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
speedTitle.Font = Enum.Font.SourceSansBold
speedTitle.TextSize = 14
speedTitle.Parent = pages["Player"]

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -5, 0, 38)
speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedInput.Text = "0"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 14
speedInput.Parent = pages["Player"]
local sic = Instance.new("UICorner") sic.CornerRadius = UDim.new(0, 6) sic.Parent = speedInput

local baseSpeed = 16
speedInput.FocusLost:Connect(function()
    local num = tonumber(speedInput.Text)
    if num then _G.Legenda32Settings.WalkSpeedBoost = num else speedInput.Text = tostring(_G.Legenda32Settings.WalkSpeedBoost) end
end)

task.spawn(function()
    while true do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = baseSpeed + (baseSpeed * (_G.Legenda32Settings.WalkSpeedBoost / 100))
        end
        task.wait(0.2)
    end
end)

createToggle(pages["Player"], "Anti-AFK (No Disconnect)", "AntiAfk", function(toggled)
    if toggled then
        antiAfkConnection = player.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else if antiAfkConnection then antiAfkConnection:Disconnect() end end
end)

-- =======================================================
-- 📍 ВКЛАДКА [ TRADING ]
-- =======================================================
createToggle(pages["Trading"], "Auto Begging Bot", "AutoBeggingBot", function(toggled)
    task.spawn(function()
        while toggled and _G.Legenda32Settings.AutoBeggingBot do
            local incomingRequest = player:FindFirstChild("IncomingTradeRequest") or player:FindFirstChild("TradeRequest")
            if incomingRequest and incomingRequest.Value then
                FireNetworkEvent("Trading: Accept Request", incomingRequest.Value)
                task.wait(1)
            end
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while toggled and _G.Legenda32Settings.AutoBeggingBot do
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and toggled and not processedPlayers[otherPlayer.UserId] then
                    local inTrade = player:FindFirstChild("InTrade") or player:FindFirstChild("TradingState")
                    if not inTrade then
                        FireNetworkEvent("Trading: Send Request", otherPlayer)
                        processedPlayers[otherPlayer.UserId] = true
                    end
                    task.wait(3)
                end
            end
            task.wait(5)
        end
    end)

    task.spawn(function()
        local lastTradeState = false
        local currentPartner = nil
        while toggled and _G.Legenda32Settings.AutoBeggingBot do
            local currentTrade = player:FindFirstChild("ActiveTrade") or workspace:FindFirstChild("ActiveTrades")
            if currentTrade and not lastTradeState then
                lastTradeState = true
                task.wait(1.5)
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and (currentTrade:FindFirstChild(p.Name) or workspace:FindFirstChild("ActiveTrades")) then currentPartner = p break end
                end
                if currentPartner then
                    local playerLang = player.LocaleId or "en-us"
                    local selectedPhrase = string.find(string.lower(playerLang), "ru") and russianPhrases[math.random(1, #russianPhrases)] or englishPhrases[math.random(1, #englishPhrases)]
                    FireNetworkEvent("Trading: Send Message", selectedPhrase)
                end
            end
            
            if currentTrade and lastTradeState then
                local partnerOffer = currentTrade:FindFirstChild("PartnerOffer") or currentTrade:FindFirstChild("Offer2")
                local partnerGems = currentTrade:FindFirstChild("PartnerGems") or currentTrade:FindFirstChild("Gems2") or (partnerOffer and partnerOffer:FindFirstChild("Diamonds"))
                local hasItems = false local hasGems = false
                if partnerOffer and #partnerOffer:GetChildren() > 0 then
                    if #partnerOffer:GetChildren() == 1 and partnerOffer:FindFirstChild("Diamonds") then hasItems = false else hasItems = true end
                end
                if partnerGems and partnerGems:IsA("ValueBase") and partnerGems.Value > 0 then hasGems = true
                elseif partnerOffer and partnerOffer:FindFirstChild("Diamonds") and partnerOffer.Diamonds.Value > 0 then hasGems = true end
                if hasItems or hasGems then
                    FireNetworkEvent("Trading: Accept Trade")
                end
            end
            if not currentTrade then lastTradeState = false currentPartner = nil end
            task.wait(0.5)
        end
    end)
end)

createToggle(pages["Trading"], "Auto Server Hop", "AutoServerHop", function(toggled)
    if toggled then
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing and server.playing < server.maxPlayers and server.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, player)
                    break
                end
            end
        end
    end
end)

-- =======================================================
-- 📍 ВКЛАДКА [ MISC ] (Локальная ИИ-Матрица)
-- =======================================================
local aiHeader = Instance.new("TextLabel")
aiHeader.Size = UDim2.new(1, -5, 0, 20)
aiHeader.BackgroundTransparency = 1
aiHeader.Text = "🤖 AI Optimization Matrix"
aiHeader.TextColor3 = Color3.fromRGB(130, 50, 250)
aiHeader.Font = Enum.Font.SourceSansBold
aiHeader.TextSize = 14
aiHeader.Parent = pages["Misc"]

local aiGenerateBtn = Instance.new("TextButton")
aiGenerateBtn.Size = UDim2.new(1, -5, 0, 40)
aiGenerateBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 150)
aiGenerateBtn.Text = "⚡ Run AI Diagnostics"
aiGenerateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aiGenerateBtn.Font = Enum.Font.SourceSansBold
aiGenerateBtn.TextSize = 13
aiGenerateBtn.Parent = pages["Misc"]
local aicb = Instance.new("UICorner") aicb.CornerRadius = UDim.new(0, 6) aicb.Parent = aiGenerateBtn

aiGenerateBtn.MouseButton1Click:Connect(function()
    aiGenerateBtn.Text = "🧠 AI Engine: Настройка коллизий и сундуков..."
    task.wait(1.5)
    
    _G.Legenda32Settings.AutoCollectRewards = true
    _G.Legenda32Settings.AutoPlaceFlags = true
    _G.Legenda32Settings.AntiAfk = true
    
    for key, val in pairs(_G.Legenda32Settings) do
        if activeToggles[key] then activeToggles[key].Update(val) task.spawn(activeToggles[key].Callback, val) end
    end
    aiGenerateBtn.Text = "System Stabilized!"
    task.wait(1.5) aiGenerateBtn.Text = "⚡ Run AI Diagnostics"
end)

-- =======================================================
-- ⚙️ МОБИЛЬНОЕ УПРАВЛЕНИЕ ХАБОМ (Только сенсорная кнопка L)
-- =======================================================
if UserInputService.TouchEnabled and not GuiService:IsTenFootInterface() then
    local mobileButton = Instance.new("TextButton")
    mobileButton.Size = UDim2.new(0, 50, 0, 50)
    mobileButton.Position = UDim2.new(0, 15, 0, 120) 
    mobileButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    mobileButton.Text = "L" 
    mobileButton.TextColor3 = Color3.fromRGB(20, 20, 20)
    mobileButton.Font = Enum.Font.SourceSansBold
    mobileButton.TextSize = 24 
    mobileButton.Parent = screenGui
    
    local mc = Instance.new("UICorner") 
    mc.CornerRadius = UDim.new(1, 0) 
    mc.Parent = mobileButton
    
    mobileButton.Active = true 
    mobileButton.Draggable = true
    mobileButton.MouseButton1Click:Connect(function() 
        mainFrame.Visible = not mainFrame.Visible 
    end)
end
