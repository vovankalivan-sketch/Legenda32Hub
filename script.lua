-- Авто-удаление старых версий при перезапуске
if game:GetService("CoreGui"):FindFirstChild("LegendaHubGodMode") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubGodMode"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Настройки функций
local _G = getgenv and getgenv() or _G
_G.AutoFarmAdvanced = false
_G.AutoRNGEvent = false
_G.RGB_Enabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubGodMode"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- КВАДРАТНАЯ КНОПКА С КРУГЛЫМИ УГЛАМИ (СПАВН ВЫШЕ И ПРАВЕЕ)
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.15, 0) -- Спавн вверху справа
ToggleButton.Size = UDim2.new(0, 45, 0, 45) -- Квадратная форма
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(0, 10) -- Скругление углов (не круг)
ButtonCorner.Parent = ToggleButton

-- Ультимативный кроссплатформенный скрипт перетаскивания (Телефоны/ПК)
local dragToggle = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    game:GetService("TweenService"):Create(ToggleButton, TweenInfo.new(0.10), {Position = position}):Play()
end

ToggleButton.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        if dragToggle then
            updateInput(input)
        end
    end
end)

-- ==========================================
-- ГЛАВНОЕ ОКНО
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Для анимации
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  LegendaHub | PS99"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Плавная анимация окон
local isMenuOpen = false
local function toggleMenuAnimation()
    if not isMenuOpen then
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 270), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.4, true)
        isMenuOpen = true
    else
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function() MainFrame.Visible = false end)
        isMenuOpen = false
    end
end
ToggleButton.MouseButton1Click:Connect(toggleMenuAnimation)

-- ==========================================
-- НАВИГАЦИЯ ВКЛАДОК (4 ВКЛАДКИ)
-- ==========================================
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 40)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local function createTabBtn(text, posMultiplier)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.24, 0, 1, 0)
    btn.Position = UDim2.new(posMultiplier * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
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

BtnFarm.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
BtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Контейнеры
local function createContainer()
    local f = Instance.new("Frame")
    f.Position = UDim2.new(0, 10, 0, 80)
    f.Size = UDim2.new(1, -20, 1, -95)
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
    for _, b do
        if b == activeBtn then
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 55); b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

BtnFarm.MouseButton1Click:Connect(function() switchTab(FarmContent, BtnFarm) end)
BtnEvent.MouseButton1Click:Connect(function() switchTab(EventContent, BtnEvent) end)
BtnTeleport.MouseButton1Click:Connect(function() switchTab(TeleportContent, BtnTeleport) end)
BtnSettings.MouseButton1Click:Connect(function() switchTab(SettingsContent, BtnSettingsTab) end)

-- ==========================================
-- СЛОЖНЫЙ ИСПРАВЛЕННЫЙ АВТОФАРМ (СЕТЕВЫЕ ПАКЕТЫ)
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 45)
FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
FarmToggle.Text = "Продвинутый Бог-Фарм: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 12
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Потоки сбора отключены."
StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmContent

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmAdvanced = not _G.AutoFarmAdvanced
    if _G.AutoFarmAdvanced then
        FarmToggle.Text = "Продвинутый Бог-Фарм: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            while _G.AutoFarmAdvanced do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    StatusLabel.Text = "Статус: Перехват и сбор сфер через Сервер..."
                    
                    -- Поиск скрытой папки сфер
                    local orbs = Workspace:FindFirstChild("Network") and Workspace.Network:FindFirstChild("Orbs")
                    local networkStorage = ReplicatedStorage:FindFirstChild("Network")
                    
                    if orbs and networkStorage then
                        for _, orb in ipairs(orbs:GetChildren()) do
                            if orb:IsA("BasePart") then
                                -- Способ 1: Прямая отправка запроса серверу о взятии сферы (Обход радиуса)
                                local claimEvent = networkStorage:FindFirstChild("Orbs_Claim") or networkStorage:FindFirstChild("Orbs:Claim")
                                if claimEvent then
                                    claimEvent:FireServer({orb.Name})
                                end
                                -- Способ 2: Мгновенное стягивание физического парта
                                orb.CFrame = root.CFrame
                            end
                        end
                    end
                end
                task.wait(0.05) -- Ультра-быстрый цикл
            end
        end)
    else
        FarmToggle.Text = "Продвинутый Бог-Фарм: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "Статус: Потоки сбора отключены."
    end
end)

-- ==========================================
-- ВКЛАДКА ТЕЛЕПОРТЫ (ПО ЛОКАЦИЯМ)
-- ==========================================
local ScrollTeleport = Instance.new("ScrollingFrame")
ScrollTeleport.Size = UDim2.new(1, 0, 1, 0)
ScrollTeleport.BackgroundTransparency = 1
ScrollTeleport.CanvasSize = UDim2.new(0, 0, 1.5, 0)
ScrollTeleport.ScrollBarThickness = 4
ScrollTeleport.Parent = TeleportContent

local function createTpBtn(zoneName, displayName, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (index - 1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "Телепорт в " .. displayName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = ScrollTeleport
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if map and root then
            for _, zone in ipairs(map:GetChildren()) do
                if zone.Name:lower():find(zoneName:lower()) or zone.Name:match("^" .. zoneName .. "%s") then
                    root.CFrame = zone:GetPivot() + Vector3.new(0, 5, 0)
                    break
                end
            end
        end
    end)
end

-- Сетка популярных телепортов по зонам
createTpBtn("1", "Зона 1 (Спавн)", 1)
createTpBtn("15", "Зона 15 (Пляж)", 2)
createTpBtn("25", "Зона 25 (Шахта)", 3)
createTpBtn("38", "Зона 38 (Сад / Каньон)", 4)
createTpBtn("50", "Зона 50 (Лава)", 5)

-- ==========================================
-- ВКЛАДКА ЭВЕНТЫ
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 45)
RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold
RngToggle.TextSize = 12
RngToggle.Parent = EventContent
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

RngToggle.MouseButton1Click:Connect(function()
    _G.AutoRNGEvent = not _G.AutoRNGEvent
    if _G.AutoRNGEvent then
        RngToggle.Text = "Авто RNG Ролл событие: ВКЛ"
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
        RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ВКЛАДКА ОПЦИИ (RGB И ЗАКРЫТИЕ)
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 40)
RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Включить Переливающийся RGB: ВЫКЛ"
RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold
RgbToggle.TextSize = 11
RgbToggle.Parent = SettingsContent
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 40)
ShutdownButton.Position = UDim2.new(0, 0, 0, 50)
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
        RgbToggle.Text = "Включить Переливающийся RGB: ВКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Включить Переливающийся RGB: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

ShutdownButton.MouseButton1Click:Connect(function()
    _G.AutoFarmAdvanced = false
    _G.AutoRNGEvent = false
    _G.RGB_Enabled = false
    ScreenGui:Destroy()
end)
