-- ============================================================
--  PS99 ULTIMATE HUB v5.1 | PET SIMULATOR 99
--  World Cup Event: авто-сбор орбов, пинок мяча, прокачка, яйцо
--  Автор: Колин (на основе всей предоставленной информации)
--  Совместим: Synapse X, Fluxus, Delta, Arceus X
-- ============================================================

--!strict
--!nolint LocalUnused

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- ===== КОНФИГУРАЦИЯ API =====
local API_BASE = "https://ps99.biggamesapi.io"
local AUTH_TOKEN = nil  -- Вставьте Bearer-токен для авторизованных запросов

-- ===== КЭШ ДЛЯ API =====
local cache = {}
local CACHE_TTL = {
    collections = 60, items = 60, rap = 14400, exists = 60,
    clansList = 60, clansTotal = 60, clans = 60, clan = 60,
    activeBattle = 60, playersFeatured = 60, playersSearch = 30,
    playersList = 60, playersTotal = 60, playerProfile = 300,
    account = 60, leagues = 60, leagueDetail = 60, leaguePlayers = 60,
}

local function isCacheValid(key)
    local entry = cache[key]
    return entry and entry.data and (os.time() - entry.timestamp) < CACHE_TTL[key]
end

local function getCached(key)
    if isCacheValid(key) then return cache[key].data end
    return nil
end

local function setCache(key, data)
    cache[key] = { data = data, timestamp = os.time() }
end

local function fetchData(endpoint, params, cacheKey, token)
    if cacheKey and isCacheValid(cacheKey) then
        return getCached(cacheKey)
    end
    local url = API_BASE .. endpoint
    if params then
        local query = {}
        for k, v in pairs(params) do
            table.insert(query, k .. "=" .. tostring(v))
        end
        if #query > 0 then
            url = url .. "?" .. table.concat(query, "&")
        end
    end
    local headers = {}
    if token then
        headers["Authorization"] = "Bearer " .. token
    end
    local success, response = pcall(function()
        if token then
            return game:HttpGet(url, true, headers)
        else
            return game:HttpGet(url)
        end
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data.status == "ok" then
            if cacheKey then setCache(cacheKey, data.data) end
            return data.data
        else
            warn("API error: " .. (data.error and data.error.message or "unknown"))
            return nil
        end
    else
        warn("HTTP error: " .. tostring(response))
        return nil
    end
end

-- ===== ПЕРЕМЕННЫЕ СОСТОЯНИЙ =====
local state = {
    AutoFarm = false,
    AutoQuest = false,
    AutoTap = false,
    AutoUseUltimate = false,
    InfiniteEnergy = false,
    AntiAFK = false,
    SafeMode = true,
    AutoKickBall = false,
    AutoCollectSoccerItems = false,
    AutoCollectOrbs = false,        -- Новая функция: сбор орбов
    AutoHatchEventEgg = false,
    FarmEventChests = false,
    StadiumHopper = false,
    EventMode = false,              -- Супер-режим ивента
    WhiteScreen = false,
    RemoveTextures = false,
    HideAllPets = false,
    ClearMapVFX = false,
    BackgroundFPS = false,
    FastOpenEggs = false,
    AutoUsePotions = false,
    AutoVending = false,
    AutoFishing = false,
    AntiLeave = false,
    -- API
    ShowRAP = false,
    ShowExists = false,
    ShowPlayerProfile = false,
}

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====

-- Безопасный телепорт (плавный)
local function safeTeleport(targetCFrame, duration)
    duration = duration or 2
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state.SafeMode then
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
    else
        hrp.CFrame = targetCFrame
    end
end

-- Отправка сетевых событий (с pcall)
local function fireServer(eventName, ...)
    local net = ReplicatedStorage:FindFirstChild("Network") or ReplicatedStorage:FindFirstChild("Remotes")
    if not net then return end
    local event = net:FindFirstChild(eventName)
    if event then
        pcall(function()
            event:FireServer(...)
        end)
    end
end

-- Имитация клика
local function safeClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05 + math.random()*0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- ===== ОСНОВНЫЕ ФУНКЦИИ =====

-- ВКЛАДКА 1: Main & Anti-Cheat Bypass
local function autoFarmLoop()
    while state.AutoFarm do
        task.wait(0.1)
        local char = LocalPlayer.Character
        if not char then break end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not hrp or not humanoid then break end
        humanoid.WalkSpeed = state.SafeMode and 38 or 50
        humanoid.JumpPower = state.SafeMode and 65 or 80
        
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
            safeTeleport(closest.HumanoidRootPart.CFrame * CFrame.new(0, 2, 5), 0.5)
            task.wait(0.2)
            safeClick()
            fireServer("BreakableClick")
        end
        task.wait(0.5 + math.random())
    end
end

local function autoTapLoop()
    while state.AutoTap do
        task.wait(0.01)
        fireServer("Tap")
        safeClick()
    end
end

local function autoUseUltimateLoop()
    while state.AutoUseUltimate do
        task.wait(5)
        fireServer("ActivateUltimate")
    end
end

local function infiniteEnergyLoop()
    while state.InfiniteEnergy do
        local energy = LocalPlayer:FindFirstChild("Energy") or LocalPlayer:FindFirstChild("Stamina")
        if energy then
            local max = energy:GetAttribute("Max") or energy.MaxValue or 100
            energy.Value = max
        end
        task.wait(0.1)
    end
end

local function antiAFKLoop()
    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
    while state.AntiAFK do
        task.wait(30 + math.random()*30)
        local key = keys[math.random(#keys)]
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1+math.random()*0.2)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
end

-- ===== ВКЛАДКА 2: World Cup Event =====

-- Пинок мяча
local function autoKickBallLoop()
    while state.AutoKickBall or state.EventMode do
        task.wait(0.5)
        fireServer("KickBall")
    end
end

-- Сбор бутс и подарков
local function autoCollectSoccerItemsLoop()
    while state.AutoCollectSoccerItems or state.EventMode do
        task.wait(0.3)
        fireServer("CollectSoccerItem")
    end
end

-- Сбор орбов (новое!)
local function autoCollectOrbsLoop()
    while state.AutoCollectOrbs or state.EventMode do
        task.wait(0.2)
        -- Ищем орбы в workspace (часто это Part с именем "Orb" или "SoccerOrb")
        local found = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Orb") or obj.Name:find("Soccer")) then
                if obj:FindFirstChild("ClickDetector") then
                    pcall(function()
                        obj.ClickDetector:Click()
                    end)
                    found = true
                    break
                end
            end
        end
        -- Если не нашли через ClickDetector, пробуем через FireServer
        if not found then
            fireServer("ClaimOrb")
        end
    end
end

-- Открытие ивентового яйца
local function autoHatchEventEggLoop()
    while state.AutoHatchEventEgg or state.EventMode do
        task.wait(1)
        fireServer("HatchEventEgg")
    end
end

-- Фарм ивентовых сундуков
local function farmEventChestsLoop()
    while state.FarmEventChests do
        task.wait(0.5)
        fireServer("AttackEventChest")
    end
end

-- Перемещение между стадионами
local function stadiumHopperLoop()
    local stadiums = {
        CFrame.new(100, 10, 200),
        CFrame.new(150, 10, 250),
        CFrame.new(200, 10, 300),
        CFrame.new(250, 10, 350),
        CFrame.new(300, 10, 400),
    }
    while state.StadiumHopper do
        for _, cf in ipairs(stadiums) do
            safeTeleport(cf, 4)
            task.wait(5)
        end
    end
end

-- СУПЕР-РЕЖИМ ИВЕНТА (включает всё одновременно)
local function eventModeLoop()
    -- Запускаем все нужные функции в отдельных потоках
    task.spawn(autoKickBallLoop)
    task.spawn(autoCollectSoccerItemsLoop)
    task.spawn(autoCollectOrbsLoop)
    task.spawn(autoHatchEventEggLoop)
    task.spawn(farmEventChestsLoop) -- если нужно
    -- Также можно включить автофарм для прокачки
    if not state.AutoFarm then
        state.AutoFarm = true
        task.spawn(autoFarmLoop)
    end
    while state.EventMode do
        -- Основной цикл супер-режима (можно добавить дополнительные действия)
        task.wait(1)
    end
end

-- ===== ВКЛАДКА 3: FPS Boost & Optimization =====
local function whiteScreenLoop()
    while state.WhiteScreen do
        RunService:Set3dRenderEnabled(false)
        task.wait()
    end
    RunService:Set3dRenderEnabled(true)
end

local function removeTexturesLoop()
    while state.RemoveTextures do
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.Material = Enum.Material.SmoothPlastic
                end)
            end
        end
        task.wait(5)
    end
end

local function hideAllPetsLoop()
    while state.HideAllPets do
        for _, pet in ipairs(workspace:GetDescendants()) do
            if pet:IsA("Model") and pet.Name:find("Pet") then
                pet.Transparency = 1
                pet.CanCollide = false
            end
        end
        task.wait(1)
    end
end

local function clearMapVFXLoop()
    while state.ClearMapVFX do
        for _, effect in ipairs(workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
                effect.Enabled = false
            end
        end
        task.wait(5)
    end
end

local function backgroundFPSCapLoop()
    while state.BackgroundFPS do
        setfpscap(10)
        task.wait(60)
        setfpscap(60)
    end
end

-- ===== ВКЛАДКА 4: Автоматизация и Прогресс =====
local function fastOpenEggsLoop()
    while state.FastOpenEggs do
        task.wait(0.1)
        fireServer("OpenEgg")
    end
end

local function autoUsePotionsLoop()
    while state.AutoUsePotions do
        task.wait(30)
        fireServer("UsePotion")
    end
end

local function autoVendingLoop()
    while state.AutoVending do
        task.wait(1)
        fireServer("VendingPurchase")
    end
end

local function autoFishingLoop()
    while state.AutoFishing do
        task.wait(2)
        fireServer("Fish")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.5)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

-- ===== ВКЛАДКА 5: Security =====
local function antiLeaveLoop()
    while state.AntiLeave do
        task.wait(5)
        if not LocalPlayer then
            TeleportService:Teleport(game.PlaceId)
        end
    end
end

-- ===== GUI (Fluent) =====
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PS99 ULTIMATE HUB v5.1",
    SubTitle = "by КОЛИН",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- Вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    WorldCup = Window:AddTab({ Title = "World Cup", Icon = "soccer" }),
    FPSBoost = Window:AddTab({ Title = "FPS Boost", Icon = "speed" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "clock" }),
    Security = Window:AddTab({ Title = "Security", Icon = "shield" }),
    API = Window:AddTab({ Title = "API Data", Icon = "database" }),
}

-- Заполнение вкладок
-- Main
Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Автофарм мобов / breakables",
    Default = false,
    Callback = function(v)
        state.AutoFarm = v
        if v then task.spawn(autoFarmLoop) end
    end
})
Tabs.Main:AddToggle("AutoTap", {
    Title = "Auto Tap",
    Description = "Сверхбыстрый клик для ультимейта",
    Default = false,
    Callback = function(v)
        state.AutoTap = v
        if v then task.spawn(autoTapLoop) end
    end
})
Tabs.Main:AddToggle("AutoUseUltimate", {
    Title = "Auto Ultimate",
    Description = "Авто-прожатие ультимейта по КД",
    Default = false,
    Callback = function(v)
        state.AutoUseUltimate = v
        if v then task.spawn(autoUseUltimateLoop) end
    end
})
Tabs.Main:AddToggle("InfiniteEnergy", {
    Title = "Infinite Energy",
    Description = "Бесконечная выносливость",
    Default = false,
    Callback = function(v)
        state.InfiniteEnergy = v
        if v then task.spawn(infiniteEnergyLoop) end
    end
})
Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Description = "Защита от выкидывания",
    Default = false,
    Callback = function(v)
        state.AntiAFK = v
        if v then task.spawn(antiAFKLoop) end
    end
})
Tabs.Main:AddToggle("SafeMode", {
    Title = "Safe Mode",
    Description = "Задержки и плавные движения для обхода античита",
    Default = true,
    Callback = function(v) state.SafeMode = v end
})
Tabs.Main:AddButton({
    Title = "Teleport to Zone",
    Description = "Плавный телепорт к зоне (введите координаты)",
    Callback = function()
        local input = Fluent:CreateInput({
            Title = "Введите CFrame координаты",
            Description = "Например: 100, 10, 500",
            Placeholder = "x, y, z",
        })
        input:OnInput(function(val)
            local parts = {string.match(val, "([^,]+)")}
            if #parts == 3 then
                local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
                if x and y and z then
                    safeTeleport(CFrame.new(x, y, z), 2)
                end
            end
        end)
    end
})

-- World Cup
Tabs.WorldCup:AddToggle("AutoKickBall", {
    Title = "Auto Kick Ball",
    Description = "Автоматический пинок мяча",
    Default = false,
    Callback = function(v)
        state.AutoKickBall = v
        if v then task.spawn(autoKickBallLoop) end
    end
})
Tabs.WorldCup:AddToggle("AutoCollectSoccerItems", {
    Title = "Auto Collect Soccer Items",
    Description = "Сбор бутс и подарков",
    Default = false,
    Callback = function(v)
        state.AutoCollectSoccerItems = v
        if v then task.spawn(autoCollectSoccerItemsLoop) end
    end
})
Tabs.WorldCup:AddToggle("AutoCollectOrbs", {
    Title = "Auto Collect Orbs",
    Description = "Сбор орбов (сфер) на поле",
    Default = false,
    Callback = function(v)
        state.AutoCollectOrbs = v
        if v then task.spawn(autoCollectOrbsLoop) end
    end
})
Tabs.WorldCup:AddToggle("AutoHatchEventEgg", {
    Title = "Auto Hatch Event Egg",
    Description = "Открытие Trophy Soccer Egg",
    Default = false,
    Callback = function(v)
        state.AutoHatchEventEgg = v
        if v then task.spawn(autoHatchEventEggLoop) end
    end
})
Tabs.WorldCup:AddToggle("FarmEventChests", {
    Title = "Farm Event Chests",
    Description = "Фокус на ивентовых сундуках",
    Default = false,
    Callback = function(v)
        state.FarmEventChests = v
        if v then task.spawn(farmEventChestsLoop) end
    end
})
Tabs.WorldCup:AddToggle("StadiumHopper", {
    Title = "Stadium Hopper",
    Description = "Авто-перемещение между 5 стадионами",
    Default = false,
    Callback = function(v)
        state.StadiumHopper = v
        if v then task.spawn(stadiumHopperLoop) end
    end
})

-- НОВЫЙ СУПЕР-РЕЖИМ ИВЕНТА
Tabs.WorldCup:AddToggle("EventMode", {
    Title = "🔥 EVENT MODE (ALL IN ONE)",
    Description = "Включает: пинок мяча, сбор орбов, сбор предметов, открытие яйца и автофарм",
    Default = false,
    Callback = function(v)
        state.EventMode = v
        if v then
            task.spawn(eventModeLoop)
        else
            -- Выключаем отдельные функции, если они не были включены вручную
            if not state.AutoKickBall then state.AutoKickBall = false end
            if not state.AutoCollectSoccerItems then state.AutoCollectSoccerItems = false end
            if not state.AutoCollectOrbs then state.AutoCollectOrbs = false end
            if not state.AutoHatchEventEgg then state.AutoHatchEventEgg = false end
            if not state.FarmEventChests then state.FarmEventChests = false end
            if not state.AutoFarm then state.AutoFarm = false end
        end
    end
})

-- FPS Boost
Tabs.FPSBoost:AddToggle("WhiteScreen", {
    Title = "White Screen Mode",
    Description = "Отключение 3D-рендеринга",
    Default = false,
    Callback = function(v)
        state.WhiteScreen = v
        if v then task.spawn(whiteScreenLoop) else RunService:Set3dRenderEnabled(true) end
    end
})
Tabs.FPSBoost:AddToggle("RemoveTextures", {
    Title = "Remove Textures",
    Description = "Замена текстур на SmoothPlastic",
    Default = false,
    Callback = function(v)
        state.RemoveTextures = v
        if v then task.spawn(removeTexturesLoop) end
    end
})
Tabs.FPSBoost:AddToggle("HideAllPets", {
    Title = "Hide All Pets",
    Description = "Скрытие моделей петов",
    Default = false,
    Callback = function(v)
        state.HideAllPets = v
        if v then task.spawn(hideAllPetsLoop) end
    end
})
Tabs.FPSBoost:AddToggle("ClearMapVFX", {
    Title = "Clear Map VFX",
    Description = "Удаление эффектов (частиц и т.д.)",
    Default = false,
    Callback = function(v)
        state.ClearMapVFX = v
        if v then task.spawn(clearMapVFXLoop) end
    end
})
Tabs.FPSBoost:AddToggle("BackgroundFPS", {
    Title = "Background FPS Cap",
    Description = "Снижение FPS до 10 при простое",
    Default = false,
    Callback = function(v)
        state.BackgroundFPS = v
        if v then task.spawn(backgroundFPSCapLoop) end
    end
})

-- Auto
Tabs.Auto:AddToggle("FastOpenEggs", {
    Title = "Fast Open Eggs",
    Description = "Пропуск анимации вылупления",
    Default = false,
    Callback = function(v)
        state.FastOpenEggs = v
        if v then task.spawn(fastOpenEggsLoop) end
    end
})
Tabs.Auto:AddToggle("AutoUsePotions", {
    Title = "Auto Use Potions & Enchants",
    Description = "Автоматическое использование зелий",
    Default = false,
    Callback = function(v)
        state.AutoUsePotions = v
        if v then task.spawn(autoUsePotionsLoop) end
    end
})
Tabs.Auto:AddToggle("AutoVending", {
    Title = "Auto Vending Machines",
    Description = "Скупка из автоматов",
    Default = false,
    Callback = function(v)
        state.AutoVending = v
        if v then task.spawn(autoVendingLoop) end
    end
})
Tabs.Auto:AddToggle("AutoFishing", {
    Title = "Auto Fishing",
    Description = "Идеальная авто-рыбалка",
    Default = false,
    Callback = function(v)
        state.AutoFishing = v
        if v then task.spawn(autoFishingLoop) end
    end
})

-- Security
Tabs.Security:AddToggle("AntiLeave", {
    Title = "Anti-Leave & Auto Reconnect",
    Description = "Защита от вылетов",
    Default = false,
    Callback = function(v)
        state.AntiLeave = v
        if v then task.spawn(antiLeaveLoop) end
    end
})

-- API вкладка (краткая)
local apiPanel = Tabs.API
apiPanel:AddButton({
    Title = "Загрузить RAP",
    Description = "Показать Recent Average Price",
    Callback = function()
        local data = fetchData("/api/rap", nil, "rap")
        if data then
            Fluent:Notify({
                Title = "RAP Data",
                Content = "Загружено " .. #data .. " записей",
                Duration = 5,
            })
            local items = {}
            for i=1, math.min(10, #data) do
                local entry = data[i]
                local name = entry.configData and entry.configData.id or "?"
                local val = entry.value or 0
                table.insert(items, name .. ": " .. val)
            end
            Fluent:CreateInput({
                Title = "Топ-10 RAP",
                Description = table.concat(items, "\n"),
                ReadOnly = true,
            })
        end
    end
})
apiPanel:AddButton({
    Title = "Загрузить Exists",
    Description = "Показать количество предметов в игре",
    Callback = function()
        local data = fetchData("/api/exists", nil, "exists")
        if data then
            Fluent:Notify({
                Title = "Exists Data",
                Content = "Загружено " .. #data .. " записей",
                Duration = 5,
            })
            local items = {}
            for i=1, math.min(10, #data) do
                local entry = data[i]
                local id = entry.configData and entry.configData.id or "?"
                local val = entry.value or 0
                table.insert(items, id .. ": " .. val)
            end
            Fluent:CreateInput({
                Title = "Топ-10 Exists",
                Description = table.concat(items, "\n"),
                ReadOnly = true,
            })
        end
    end
})
apiPanel:AddButton({
    Title = "Поиск игрока",
    Description = "Введите имя или ID",
    Callback = function()
        local input = Fluent:CreateInput({
            Title = "Поиск игрока",
            Description = "Введите имя или Roblox ID",
            Placeholder = "chickenputty или 123456789",
        })
        input:OnInput(function(val)
            local data = fetchData("/v1/players/" .. val, nil, "playerProfile")
            if data and data.account then
                local acc = data.account
                local msg = "Игрок: " .. (acc.displayName or acc.username or val) .. "\n"
                msg = msg .. "ID: " .. acc.robloxUserId .. "\n"
                if acc.publicViews then
                    local views = {}
                    for k, v in pairs(acc.publicViews) do
                        if v then table.insert(views, k) end
                    end
                    msg = msg .. "Публичные вкладки: " .. table.concat(views, ", ")
                end
                Fluent:Notify({
                    Title = "Профиль игрока",
                    Content = msg,
                    Duration = 10,
                })
            else
                Fluent:Notify({
                    Title = "Ошибка",
                    Content = "Игрок не найден или профиль закрыт",
                    Duration = 5,
                })
            end
        end)
    end
})

-- ===== СОХРАНЕНИЕ НАСТРОЕК =====
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("PS99Hub_v5")

SaveManager:BuildConfigSection(Window)
InterfaceManager:BuildConfigSection(Window)

Window:SelectTab(1)

Fluent:Notify({
    Title = "PS99 ULTIMATE HUB v5.1",
    Content = "Загружен успешно! Включите EVENT MODE для ивента.",
    Duration = 8,
})

print("✅ PS99 Ultimate Hub v5.1 загружен. World Cup Event Mode готов!")
print("⚠️ Включите 'Event Mode' для одновременного сбора орбов, пинания мяча, открытия яйца и прокачки.")
