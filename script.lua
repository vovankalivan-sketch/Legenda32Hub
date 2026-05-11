-- Принудительное удаление зависших старых копий
if game:GetService("CoreGui"):FindFirstChild("LegendaHubGodMode") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubGodMode"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Флаги функций
local _G = getgenv and getgenv() or _G
_G.AutoFarmAdvanced = false
_G.AutoRNGEvent = false
_G.RGB_Enabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubGodMode"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- КВАДРАТНАЯ КНОПКА С КРУГЛЫМИ УГЛАМИ (СТАБИЛЬНЫЙ ПЕРЕНЕСЕННЫЙ СПАВН)
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.80, 0, 0.10, 0) -- Спавн вверху справа, не мешает игре
ToggleButton.Size = UDim2.new(0, 45, 0, 45) -- Четкий квадрат
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(0, 10) -- Скругленные края (не круг)
ButtonCorner.Parent = ToggleButton

-- Облегченный мобильный скрипт перетаскивания без тяжелых Tween-задержек
local dragging, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==========================================
-- ОСНОВНОЕ ОКНО (БЕЗ ОШИБОК АНИМАЦИИ)
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.Size = UDim2.new(0, 300, 0, 220) -- Сразу фиксированный размер для Delta
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Visible = true

MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  LegendaHub | PS99"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Моментальное переключение видимости (0% лагов)
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==========================================
-- НАВИГАЦИЯ ВКЛАДОК (4 ШТУКИ)
-- ==========================================
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 35)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local function createTabBtn(text, posMultiplier)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, 0, 1, 0)
    btn.Position = UDim2.new(posMultiplier * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = TabNavFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local BtnFarm = createTabBtn("Фарм", 0)
local BtnEvent = createTabBtn("Эвенты", 1)
local BtnTeleport = createTabBtn("Телепорт", 2)
local BtnSettings = createTabBtn("Опции", 3)

-- Подсветка первой вкладки
BtnFarm.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
BtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)

local function createContainer()
    local f = Instance.new("Frame")
    f.Position = UDim2.new(0, 10, 0, 75)
    f.Size = UDim2.new(1, -20, 1, -85)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.Parent = MainFrame
    return f
end

local FarmContent = createContainer(); FarmContent.Visible = true
local EventContent = createContainer()
local TeleportContent = createContainer()
local SettingsContent = createContainer()

local function switchTab(activeContent, activeBtn)
    FarmContent.Visible = (FarmContent == activeContent)
    EventContent.Visible = (EventContent == activeContent)
    TeleportContent.Visible = (TeleportContent == activeContent)
    SettingsContent.Visible = (SettingsContent == activeContent)
    
    local btns = {BtnFarm, BtnEvent, BtnTeleport, BtnSettings}
    for _, b in ipairs(btns) do
        if b == activeBtn then
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            b.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
end

BtnFarm.MouseButton1Click:Connect(function() switchTab(FarmContent, BtnFarm) end)
BtnEvent.MouseButton1Click:Connect(function() switchTab(EventContent, BtnEvent) end)
BtnTeleport.MouseButton1Click:Connect(function() switchTab(TeleportContent, BtnTeleport) end)
BtnSettings.MouseButton1Click:Connect(function() switchTab(SettingsContent, BtnSettings) end)

-- ==========================================
-- УЛЬТИМАТИВНЫЙ ФАРМ (БЕЗМАГНИТНЫЙ СЕТЕВОЙ СБОР)
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 40)
FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
FarmToggle.Text = "Бог-Фарм Сфер (Пакетный): ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 11
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 45)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Фарм не активен."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmContent

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmAdvanced = not _G.AutoFarmAdvanced
    if _G.AutoFarmAdvanced then
        FarmToggle.Text = "Бог-Фарм Сфер (Пакетный): ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            while _G.AutoFarmAdvanced do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    StatusLabel.Text = "Статус: Симуляция захвата пакетов..."
                    
                    -- Запрос к ядру игры PS99 для моментального зачисления всех Orbs
                    local networkFolder = ReplicatedStorage:FindFirstChild("Network")
                    local orbsFolder = Workspace:FindFirstChild("Network") and Workspace.Network:FindFirstChild("Orbs")
                    
                    if orbsFolder and networkFolder then
                        local claimRemote = networkFolder:FindFirstChild("Orbs_Claim") or networkFolder:FindFirstChild("Orbs:Claim")
                        
                        -- Собираем ID всех сфер на карте
                        local orbIds = {}
                        for _, orb in ipairs(orbsFolder:GetChildren()) do
                            if orb:IsA("BasePart") then
                                table.insert(orbIds, orb.Name)
                                -- Дополнительно притягиваем физически к игроку на случай лага сети
                                orb.CFrame = root.CFrame
                            end
                        end
                        
                        -- Отправляем серверу команду "я поднял эти сферы" (работает на любом расстоянии)
                        if #orbIds > 0 and claimRemote then
                            claimRemote:FireServer(orbIds)
                        end
                    end
                end
                task.wait(0.2) -- Безопасный интервал для защиты от кика
            end
        end)
    else
        FarmToggle.Text = "Бог-Фарм Сфер (Пакетный): ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "Статус: Фарм не активен."
    end
end)

-- ==========================================
-- ВКЛАДКА: ТЕЛЕПОРТЫ ПО ЗОНАМ
-- ==========================================
local ScrollTeleport = Instance.new("ScrollingFrame")
ScrollTeleport.Size = UDim2.new(1, 0, 1, 0)
ScrollTeleport.BackgroundTransparency = 1
ScrollTeleport.CanvasSize = UDim2.new(0, 0, 1.8, 0)
ScrollTeleport.ScrollBarThickness = 3
ScrollTeleport.Parent = TeleportContent

local function createTpBtn(zoneName, displayName, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (index - 1) * 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "Телепорт: " .. displayName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = ScrollTeleport
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if map and root then
            for _, zone in ipairs(map:GetChildren()) do
                -- Сверяем имена зон по номерам
                if zone.Name:match("^" .. zoneName .. "%s") or zone.Name == zoneName then
                    root.CFrame = zone:GetPivot() + Vector3.new(0, 5, 0)
                    break
                end
            end
        end
    end)
end

createTpBtn("1", "Зона 1 (Спавн)", 1)
createTpBtn("10", "Зона 10 (Шахта)", 2)
createTpBtn("20", "Зона 20 (Пустыня)", 3)
createTpBtn("30", "Зона 30 (Пираты)", 4)
createTpBtn("38", "Зона 38 (Ваша локация)", 5)
createTpBtn("50", "Зона 50 (Самураи)", 6)

-- ==========================================
-- ВКЛАДКА: ЭВЕНТЫ
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 40)
RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
RngToggle.Text = "Авто RNG Ролл события: ВЫКЛ"
RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold
RngToggle.TextSize = 11
RngToggle.Parent = EventContent
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

RngToggle.MouseButton1Click:Connect(function()
    _G.AutoRNGEvent = not _G.AutoRNGEvent
    if _G.AutoRNGEvent then
        RngToggle.Text = "Авто RNG Ролл события: ВКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        task.spawn(function()
            while _G.AutoRNGEvent do
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network then
                    local roll = network:FindFirstChild("RNG_Roll") or network:FindFirstChild("RNG_Event_Roll") or network:FindFirstChild("VoidRNG_Roll")
                    if roll then roll:InvokeServer() end
                end
                task.wait(0.1)
            end
        end)
    else
        RngToggle.Text = "Авто RNG Ролл события: ВЫКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ВКЛАДКА: ОПЦИИ (RGB И КНОПКА ПОЛНОГО ЗАКРЫТИЯ)
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 35)
RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Переливающийся RGB: ВЫКЛ"
RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold
RgbToggle.TextSize = 11
RgbToggle.Parent = SettingsContent
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 35)
ShutdownButton.Position = UDim2.new(0, 0, 0, 45)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25)
ShutdownButton.Text = "ПОЛНОСТЬЮ ЗАКРЫТЬ СКРИПТ"
ShutdownButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ShutdownButton.Font = Enum.Font.GothamBold
ShutdownButton.TextSize = 11
ShutdownButton.Parent = SettingsContent
Instance.new("UICorner", ShutdownButton).CornerRadius = UDim.new(0, 6)

RunService.RenderStepped:Connect(function()
    if _G.RGB_Enabled then
        local hue = (tick() % 4) / 4
        local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color
        ToggleButton.TextColor3 = color
    end
end)

RgbToggle.MouseButton1Click:Connect(function()
    _G.RGB_Enabled = not _G.RGB_Enabled
    if _G.RGB_Enabled then
        RgbToggle.Text = "Переливающийся RGB: ВКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Переливающийся RGB: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

ShutdownButton.MouseButton1Click:Connect(function()
    _G.AutoFarmAdvanced = false
    _G.AutoRNGEvent = false
    _G.RGB_Enabled = false
    ScreenGui:Destroy()
end)
