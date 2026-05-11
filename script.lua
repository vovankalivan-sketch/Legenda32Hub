-- =======================================================
-- ★ Legenda32Hub — Полная и Окончательная Версия ★
-- =======================================================

-- Сервисы игры
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("Network", 5)

-- Настройки безопасности баланса и крафта (Лимиты)
local CRAFT_RESERVE_LIMIT = 1000000 

-- Имя файла для сохранения настроек
local CONFIG_FILE_NAME = "Legenda32Hub_Config.json"

-- Глобальная таблица состояний для сохранения
_G.Legenda32Settings = {
    CraftReserve = 1000000,
    WalkSpeedBoost = 0,
    AutoLastZone = false,
    AutoRankQuests = false,
    AutoCollectRewards = false,
    AutoUpgradeDice = false,
    SmartRNGUpgrades = false,
    LuckStormBooster = false,
    AutoEventChest = false,
    AutoBeggingBot = false,
    AutoServerHop = false,
    CpuOptimizer = false,
    AntiAfk = false
}

-- База фраз для трейд-бота (без упоминания кубиков)
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

-- Очистка черного списка при выходе игроков
Players.PlayerRemoving:Connect(function(leftPlayer)
    processedPlayers[leftPlayer.UserId] = nil
end)

-- Защита от дублирования интерфейса
if game:GetService("CoreGui"):FindFirstChild("Legenda32Hub_Gui") then
    game:GetService("CoreGui"):FindFirstChild("Legenda32Hub_Gui"):Destroy()
end

-- 1. Создание основы интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Legenda32Hub_Gui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- 2. Главное окно меню
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

-- Заголовок меню
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

-- Кнопка закрытия (X)
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

-- Боковая панель для 7 вкладок
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

-- Контейнер страниц
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

-- Создание структуры вкладок
createTab("Farm", "🌾", 1)
createTab("Items", "🎒", 2)
createTab("Visuals", "👁️", 3)
createTab("Player", "⚡", 4)
createTab("Events", "🎉", 5) 
createTab("Trading", "🏪", 6) 
createTab("Misc", "⚙️", 7)

pages["Events"].Visible = true
tabButtons["Events"].TextColor3 = Color3.fromRGB(0, 255, 150)
tabButtons["Events"].BackgroundTransparency = 0
tabButtons["Events"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Конструктор переключателей Toggle
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

-- Пустышки под будущие системы
createToggle(pages["Items"], "Auto Use Potions", "Dummy1", function() end)
createToggle(pages["Items"], "Auto Vending Machines", "Dummy2", function() end)
createToggle(pages["Visuals"], "Shiny Relic ESP", "Dummy3", function() end)

-- =======================================================
-- 📍 ВКЛАДКА [ FARM ] (Автофарм ресурсов)
-- =======================================================
local function table_getLastUnlockedZone()
    local mapFolder = workspace:FindFirstChild("Map")
    local lastZone = nil
    local maxNum = -1
    if mapFolder then
        for _, zone in ipairs(mapFolder:GetChildren()) do
            local num = tonumber(string.match(zone.Name, "^(%d+)"))
            if num and num > maxNum then maxNum = num lastZone = zone end
        end
    end
    return lastZone
end

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, -5, 0, 35)
zoneLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
zoneLabel.Text = "Detecting Zone..."
zoneLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneLabel.Font = Enum.Font.SourceSansItalic
zoneLabel.TextSize = 14
zoneLabel.Parent = pages["Farm"]
local zc = Instance.new("UICorner") zc.CornerRadius = UDim.new(0, 6) zc.Parent = zoneLabel

task.spawn(function()
    while true do
        if mainFrame.Visible and pages["Farm"].Visible then
            local currentZone = table_getLastUnlockedZone()
            if currentZone then
                zoneLabel.Text = "📍 Current Zone: " .. string.gsub(currentZone.Name, "^%d+%.%s*", "")
            else zoneLabel.Text = "📍 Zone: Unknown" end
        end
        task.wait(2)
    end
end)

createToggle(pages["Farm"], "Auto Last Zone", "AutoLastZone", function(toggled)
    while toggled and _G.Legenda32Settings.AutoLastZone do
        local lastZone = table_getLastUnlockedZone()
        if lastZone and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = lastZone:FindFirstChild("PERSISTENT") or lastZone:FindFirstChild("Collider") or lastZone:FindFirstChildOfClass("Part")
            if targetPart then
                if network and network:FindFirstChild("Hoverboard_SetState") then network.Hoverboard_SetState:InvokeServer(true) end
                player.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
        task.wait(4)
    end
end)

createToggle(pages["Farm"], "Auto Rank Quests", "AutoRankQuests", function(toggled)
    while toggled and _G.Legenda32Settings.AutoRankQuests do
        local breakables = workspace:FindFirstChild("Breakables")
        if breakables and network and network:FindFirstChild("Breakables_PlayerClick") then
            for _, obj in ipairs(breakables:GetChildren()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - obj:GetModelCFrame().Position).Magnitude
                    if dist < 150 then network.Breakables_PlayerClick:FireServer(obj.Name) end
                end
            end
        end
        task.wait(0.5)
    end
end)

createToggle(pages["Farm"], "Auto Collect Rewards", "AutoCollectRewards", function(toggled)
    while toggled and _G.Legenda32Settings.AutoCollectRewards do
        if network then
            local playtimeEvent = network:FindFirstChild("PlaytimeRewards_Claim") or network:FindFirstChild("Playtime_Claim")
            if playtimeEvent then for i = 1, 12 do playtimeEvent:FireServer(i) end end
        end
        task.wait(45)
    end
end)

-- =======================================================
-- 📍 ВКЛАДКА [ PLAYER ] (Характеристики и обход AFK)
-- =======================================================
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

local antiAfkConnection
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
-- 📍 ВКЛАДКА [ EVENTS ] (Автоматизация Бездны и сундука)
-- =======================================================
local eventHeader = Instance.new("TextLabel")
eventHeader.Size = UDim2.new(1, -5, 0, 25)
eventHeader.BackgroundTransparency = 1
eventHeader.Text = "🌌 Void RNG Event Advanced"
eventHeader.TextColor3 = Color3.fromRGB(140, 60, 255)
eventHeader.Font = Enum.Font.SourceSansBold
eventHeader.TextSize = 14
eventHeader.TextXAlignment = Enum.TextXAlignment.Left
eventHeader.Parent = pages["Events"]

createToggle(pages["Events"], "Auto Upgrade Dice", "AutoUpgradeDice", function(toggled)
    while toggled and _G.Legenda32Settings.AutoUpgradeDice do
        if network then
            local upgradeDiceRemote = network:FindFirstChild("VoidRNG_CraftDice") or network:FindFirstChild("RNG_UpgradeDice") or network:FindFirstChild("Dice_Craft")
            if upgradeDiceRemote then
                upgradeDiceRemote:FireServer("Lucky Dice II", "All")
                task.wait(0.5)
                upgradeDiceRemote:FireServer("Mega Lucky Dice", "All")
                task.wait(0.5)
                upgradeDiceRemote:FireServer("Mega Lucky Dice II", "All")
            end
        end
        task.wait(5)
    end
end)

createToggle(pages["Events"], "Smart RNG Upgrades", "SmartRNGUpgrades", function(toggled)
    while toggled and _G.Legenda32Settings.SmartRNGUpgrades do
        if network then
            local currentCoins = 0
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats and leaderstats:FindFirstChild("RNG Coins") then currentCoins = leaderstats["RNG Coins"].Value end
            if currentCoins > _G.Legenda32Settings.CraftReserve then
                local upgradeRemote = network:FindFirstChild("VoidRNG_BuyUpgrade") or network:FindFirstChild("RNG_PurchaseUpgrade")
                if upgradeRemote then for upgradeID = 1, 4 do upgradeRemote:FireServer(upgradeID) end end
            end
        end
        task.wait(10)
    end
end)

createToggle(pages["Events"], "3x Luck Storm Booster", "LuckStormBooster", function(toggled)
    while toggled and _G.Legenda32Settings.LuckStormBooster do
        if network then
            local megaDiceCount = 0
            local inventoryFolder = player:FindFirstChild("VoidRNG_Inventory") or player:FindFirstChild("Inventory")
            if inventoryFolder and inventoryFolder:FindFirstChild("Mega Lucky Dice II") then megaDiceCount = inventoryFolder["Mega Lucky Dice II"].Value end

            local isLightningStorm = false
            local environment = workspace:FindFirstChild("Environment") or workspace:FindFirstChild("Map")
            if environment and (environment:FindFirstChild("LightningStorm") or environment:FindFirstChild("VoidStorm") or workspace:FindFirstChild("Weather_Lightning")) then isLightningStorm = true end

            local isBonusRoll = false
            local rstats = player:FindFirstChild("RNG_Stats") or player:FindFirstChild("leaderstats")
            if rstats and rstats:FindFirstChild("RollsUntilBonus") and rstats["RollsUntilBonus"].Value == 0 then isBonusRoll = true end

            if isLightningStorm and megaDiceCount > 0 then
                local useDiceRemote = network:FindFirstChild("VoidRNG_UseDice") or network:FindFirstChild("RNG_ConsumeItem") or network:FindFirstChild("Dice_Use")
                if useDiceRemote then
                    if megaDiceCount < 5 then
                        if isBonusRoll then useDiceRemote:FireServer("Mega Lucky Dice II", 1) task.wait(5) end
                    else useDiceRemote:FireServer("Mega Lucky Dice II", megaDiceCount) task.wait(115) end
                end
            end
        end
        task.wait(1)
    end
end)

local chestBtnEnabled = false
local chestBtn = Instance.new("TextButton")
chestBtn.Size = UDim2.new(1, -5, 0, 38)
chestBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
chestBtn.Text = "Auto Event Chest: OFF"
chestBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
chestBtn.Font = Enum.Font.SourceSansBold
chestBtn.TextSize = 14
chestBtn.Parent = pages["Events"]
local cbt = Instance.new("UICorner") cbt.CornerRadius = UDim.new(0, 6) cbt.Parent = chestBtn

chestBtn.MouseButton1Click:Connect(function()
    chestBtnEnabled = not chestBtnEnabled
    _G.Legenda32Settings.AutoEventChest = chestBtnEnabled
    if chestBtnEnabled then
        chestBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
        chestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        task.spawn(function()
            local chestCooldown = 0
            while chestBtnEnabled and _G.Legenda32Settings.AutoEventChest do
                local breakables = workspace:FindFirstChild("Breakables")
                local targetChest = nil
                if breakables then
                    for _, obj in ipairs(breakables:GetChildren()) do
                        if string.find(obj.Name, "Void") and string.find(obj.Name, "Chest") then targetChest = obj break end
                    end
                end
                if targetChest then
                    chestBtn.Text = "⚔️ Destroying Chest..."
                    if network and network:FindFirstChild("Breakables_PlayerClick") then network.Breakables_PlayerClick:FireServer(targetChest.Name) end
                    task.wait(0.2)
                    chestCooldown = 300 
                else
                    if chestCooldown > 0 then chestBtn.Text = "⏱️ Next Chest: " .. tostring(chestCooldown) .. "s" chestCooldown = chestCooldown - 1 task.wait(1)
                    else chestBtn.Text = "🔍 Searching Chest..." task.wait(2) end
                end
            end
        end)
    else chestBtn.Text = "Auto Event Chest: OFF" chestBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) chestBtn.TextColor3 = Color3.fromRGB(200, 200, 200) end
end)

-- =======================================================
-- 📍 ВКЛАДКА [ TRADING ] (Мультиязычный Трейд-бот)
-- =======================================================
local tradeHeader = Instance.new("TextLabel")
tradeHeader.Size = UDim2.new(1, -5, 0, 25)
tradeHeader.BackgroundTransparency = 1
tradeHeader.Text = "🏪 Trading Plaza Systems"
tradeHeader.TextColor3 = Color3.fromRGB(255, 180, 0)
tradeHeader.Font = Enum.Font.SourceSansBold
tradeHeader.TextSize = 14
tradeHeader.TextXAlignment = Enum.TextXAlignment.Left
tradeHeader.Parent = pages["Trading"]

local function getPlayerLanguage(targetPlayer)
    local locale = targetPlayer.LocaleId or "en-us"
    locale = string.lower(locale)
    if string.find(locale, "ru") or string.find(locale, "uk") or string.find(locale, "be") or string.find(locale, "kk") then return "RU" else return "EN" end
end

createToggle(pages["Trading"], "Auto Begging Bot", "AutoBeggingBot", function(toggled)
    task.spawn(function()
        while toggled and _G.Legenda32Settings.AutoBeggingBot do
            if network then
                local incomingRequest = player:FindFirstChild("IncomingTradeRequest") or player:FindFirstChild("TradeRequest")
                if incomingRequest and incomingRequest.Value then
                    local sender = incomingRequest.Value
                    local acceptRequestRemote = network:FindFirstChild("Trade_AcceptRequest") or network:FindFirstChild("Trading_RespondRequest")
                    if acceptRequestRemote then acceptRequestRemote:FireServer(sender, true) task.wait(1) end
                end
            end
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while toggled and _G.Legenda32Settings.AutoBeggingBot do
            if network then
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and toggled and not processedPlayers[otherPlayer.UserId] then
                        local inTrade = player:FindFirstChild("InTrade") or player:FindFirstChild("TradingState")
                        if not inTrade then
                            local requestRemote = network:FindFirstChild("Trade_Request") or network:FindFirstChild("Trading_SendRequest")
                            if requestRemote then requestRemote:FireServer(otherPlayer) processedPlayers[otherPlayer.UserId] = true end
                        end
                        task.wait(3)
                    end
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
                    local playerLang = getPlayerLanguage(currentPartner)
                    local selectedPhrase = playerLang == "RU" and russianPhrases[math.random(1, #russianPhrases)] or englishPhrases[math.random(1, #englishPhrases)]
                    local msgRemote = network:FindFirstChild("Trade_SendMessage") or network:FindFirstChild("Trading_Chat")
                    if msgRemote then msgRemote:FireServer(selectedPhrase) end
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
                    local acceptRemote = network:FindFirstChild("Trade_Accept") or network:FindFirstChild("Trading_Accept")
                    if acceptRemote then acceptRemote:FireServer() end
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
-- 📍 ВКЛАДКА [ MISC ] (Менеджер сохранений и Локальный ИИ)
-- =======================================================
local miscHeader = Instance.new("TextLabel")
miscHeader.Size = UDim2.new(1, -5, 0, 20)
miscHeader.BackgroundTransparency = 1
miscHeader.Text = "⚙️ Config File Manager"
miscHeader.TextColor3 = Color3.fromRGB(0, 255, 150)
miscHeader.Font = Enum.Font.SourceSansBold
miscHeader.TextSize = 14
miscHeader.Parent = pages["Misc"]

local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(1, -5, 0, 35)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 150)
saveConfigBtn.Text = "💾 Save Current Config"
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.Font = Enum.Font.SourceSansBold
saveConfigBtn.TextSize = 13
saveConfigBtn.Parent = pages["Misc"]
local scbc = Instance.new("UICorner") scbc.CornerRadius = UDim.new(0, 6) scbc.Parent = saveConfigBtn

saveConfigBtn.MouseButton1Click:Connect(function()
    local json = HttpService:JSONEncode(_G.Legenda32Settings)
    writefile(CONFIG_FILE_NAME, json)
    saveConfigBtn.Text = "✅ Config Saved!"
    task.wait(1.5)
    saveConfigBtn.Text = "💾 Save Current Config"
end)

local loadConfigBtn = Instance.new("TextButton")
loadConfigBtn.Size = UDim2.new(1, -5, 0, 35)
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 80)
loadConfigBtn.Text = "📂 Load Saved Config"
loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadConfigBtn.Font = Enum.Font.SourceSansBold
loadConfigBtn.TextSize = 13
loadConfigBtn.Parent = pages["Misc"]
local lcbc = Instance.new("UICorner") lcbc.CornerRadius = UDim.new(0, 6) lcbc.Parent = loadConfigBtn

loadConfigBtn.MouseButton1Click:Connect(function()
    if isfile(CONFIG_FILE_NAME) then
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE_NAME))
        for key, val in pairs(data) do
            _G.Legenda32Settings[key] = val
            if activeToggles[key] then activeToggles[key].Update(val) task.spawn(activeToggles[key].Callback, val) end
        end
        loadConfigBtn.Text = "✅ Config Loaded!"
    else loadConfigBtn.Text = "❌ No Saved Config Found" end
    task.wait(1.5) loadConfigBtn.Text = "📂 Load Saved Config"
end)

local deleteConfigBtn = Instance.new("TextButton")
deleteConfigBtn.Size
deleteConfigBtn.Size = UDim2.new(1, -5, 0, 35)
deleteConfigBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
deleteConfigBtn.Text = "🗑️ Delete Config"
deleteConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteConfigBtn.Font = Enum.Font.SourceSansBold
deleteConfigBtn.TextSize = 13
deleteConfigBtn.Parent = pages["Misc"]
local dcbc = Instance.new("UICorner") dcbc.CornerRadius = UDim.new(0, 6) dcbc.Parent = deleteConfigBtn

deleteConfigBtn.MouseButton1Click:Connect(function()
    if isfile(CONFIG_FILE_NAME) then 
        delfile(CONFIG_FILE_NAME) 
        deleteConfigBtn.Text = "🗑️ Config Deleted"
    else 
        deleteConfigBtn.Text = "❌ No file found" 
    end
    task.wait(1.5) 
    deleteConfigBtn.Text = "🗑️ Delete Config"
end)

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
aiGenerateBtn.Text = "⚡ Run AI Resource Analysis"
aiGenerateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aiGenerateBtn.Font = Enum.Font.SourceSansBold
aiGenerateBtn.TextSize = 13
aiGenerateBtn.Parent = pages["Misc"]
local aicb = Instance.new("UICorner") aicb.CornerRadius = UDim.new(0, 6) aicb.Parent = aiGenerateBtn

aiGenerateBtn.MouseButton1Click:Connect(function()
    aiGenerateBtn.Text = "🧠 AI analyzing resources..."
    task.wait(1.5)
    local coins = 0
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("RNG Coins") then coins = leaderstats["RNG Coins"].Value end
    
    if coins < 50000 then
        _G.Legenda32Settings.CraftReserve = 1000
        _G.Legenda32Settings.SmartRNGUpgrades = false
        _G.Legenda32Settings.AutoUpgradeDice = true
        _G.Legenda32Settings.LuckStormBooster = true
    elseif coins >= 50000 and coins < 2000000 then
        _G.Legenda32Settings.CraftReserve = 300000
        _G.Legenda32Settings.SmartRNGUpgrades = true
        _G.Legenda32Settings.AutoUpgradeDice = true
        _G.Legenda32Settings.LuckStormBooster = true
    else
        _G.Legenda32Settings.CraftReserve = 1500000
        _G.Legenda32Settings.SmartRNGUpgrades = true
        _G.Legenda32Settings.AutoUpgradeDice = true
        _G.Legenda32Settings.LuckStormBooster = true
    end
    
    for key, val in pairs(_G.Legenda32Settings) do
        if activeToggles[key] then activeToggles[key].Update(val) task.spawn(activeToggles[key].Callback, val) end
    end
    aiGenerateBtn.Text = "✅ AI Configuration Applied!"
    task.wait(1.5) 
    aiGenerateBtn.Text = "⚡ Run AI Resource Analysis"
end)

-- =======================================================
-- ⚙️ СИСТЕМНОЕ УПРАВЛЕНИЕ ХАБОМ (Клавиатура и Кнопка L)
-- =======================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    if input.KeyCode == Enum.KeyCode.Delete then mainFrame.Visible = not mainFrame.Visible end
end)

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
    local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(1, 0) mc.Parent = mobileButton
    mobileButton.Active = true 
    mobileButton.Draggable = true
    mobileButton.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
end
