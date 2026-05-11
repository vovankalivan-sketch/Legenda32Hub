-- ====================================================================
-- ПОЛНЫЙ КОД LEGENDA32HUB (ЗАГРУЖАТЬ В SCRIPT.LUA НА GITHUB)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Принудительное удаление старых копий GUI, чтобы меню не двоилось
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubUniversal") then 
    LocalPlayer.PlayerGui.LegendaHubUniversal:Destroy() 
end

-- Глобальные флаги для циклов (getgenv() для стабильности)
getgenv().AutoFarmAdvanced = false
getgenv().AutoRNGEvent = false
getgenv().RGB_Enabled = false

-- Создание интерфейса в надежной папке PlayerGui (100% обход защиты CoreGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubUniversal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- КВАДРАТНАЯ КНОПКА С КРУГЛЫМИ УГЛАМИ
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0) -- Спавн вверху справа (выше кнопок игры)
ToggleButton.Size = UDim2.new(0, 45, 0, 45) -- Квадратная форма
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(0, 10) -- Скругление углов парта (не круг)
ButtonCorner.Parent = ToggleButton

-- Стабильный мобильный скрипт перетаскивания кнопки пальцем
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
        if input.Position then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==========================================
-- ГЛАВНАЯ ПАНЕЛЬ МЕНЮ (СТАБИЛЬНЫЙ ОПТИМИЗИРОВАННЫЙ РАЗМЕР)
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Visible = true

MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Legenda32Hub | PS99"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Моментальный показ/скрытие без ломающих анимаций
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

-- Активная вкладка при старте
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
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 55); b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
end

BtnFarm.MouseButton1Click:Connect(function() switchTab(FarmContent, BtnFarm) end)
BtnEvent.MouseButton1Click:Connect(function() switchTab(EventContent, BtnEvent) end)
BtnTeleport.MouseButton1Click:Connect(function() switchTab(TeleportContent, BtnTeleport) end)
BtnSettings.MouseButton1Click:Connect(function() switchTab(SettingsContent, BtnSettings) end)

-- ==========================================
-- СЛОЖНЫЙ УДАРНЫЙ АВТОФАРМ СФЕР И МЕШКОВ
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 40)
FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
FarmToggle.Text = "Сбор сфер (Вся карта): ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 11
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

FarmToggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarmAdvanced = not getgenv().AutoFarmAdvanced
    if getgenv().AutoFarmAdvanced then
        FarmToggle.Text = "Сбор сфер (Вся карта): ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            while getgenv().AutoFarmAdvanced do
                pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Глубокое сканирование Workspace на случай динамического создания сфер игрой
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if (obj.Name == "Orb" or obj.Name == "Lootbag" or obj:GetAttribute("OrbType")) and obj:IsA("BasePart") then
                                -- Стягиваем позицию физического объекта прямо в персонажа
                                obj.CFrame = root.CFrame
                            end
                        end
                    end
                end)
                task.wait(0.15) -- Оптимальная скорость для обхода лимитов сервера
            end
        end)
    else
        FarmToggle.Text = "Сбор сфер (Вся карта): ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ВКЛАДКА: СЕТКА ТЕЛЕПОРТОВ ПО ЗОНАМ
-- ==========================================
local ScrollTeleport = Instance.new("ScrollingFrame")
ScrollTeleport.Size = UDim2.new(1, 0, 1, 0)
ScrollTeleport.BackgroundTransparency = 1
ScrollTeleport.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollTeleport.ScrollBarThickness = 2
ScrollTeleport.Parent = TeleportContent

local function createTpBtn(zoneName, displayName, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (index - 1) * 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "ТП в " .. displayName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = ScrollTeleport
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if map and root then
                for _, zone in ipairs(map:GetChildren()) do
                    -- Ищет зону по маске регулярного выражения (например, "38 | ...")
                    if zone.Name:match("^" .. zoneName .. "%s") or zone.Name == zoneName then
                        root.CFrame = zone:GetPivot() + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end)
    end)
end

createTpBtn("1", "Зону 1 (Спавн)", 1)
createTpBtn("10", "Зону 10 (Шахта)", 2)
createTpBtn("20", "Зону 20 (Пустыня)", 3)
createTpBtn("30", "Зону 30 (Пираты)", 4)
createTpBtn("38", "Зону 38 (Ваш Каньон)", 5)
createTpBtn("50", "Зону 50 (Самураи)", 6)

-- ==========================================
-- ВКЛАДКА: ЭВЕНТЫ (АВТО-RNG)
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 40)
RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
RngToggle.Text = "Авто RNG Крутилка: ВЫКЛ"
RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold
RngToggle.TextSize = 11
RngToggle.Parent = EventContent
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

RngToggle.MouseButton1Click:Connect(function()
    getgenv().AutoRNGEvent = not getgenv().AutoRNGEvent
    if getgenv().AutoRNGEvent then
        RngToggle.Text = "Авто RNG Крутилка: ВКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        task.spawn(function()
            while getgenv().AutoRNGEvent do
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    if net then
                        -- Простукивание всех возможных сетевых ивентов ролла игры
                        local remote = net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll")
                        if remote then remote:InvokeServer() end
                    end
                end)
                task.wait(0.1)
            end
        end)
    else
        RngToggle.Text = "Авто RNG Крутилка: ВЫКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ВКЛАДКА: ОПЦИИ (RGB И КНОПКА ПОЛНОГО УДАЛЕНИЯ С ТЕЛЕФОНА)
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 35)
RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Переливающийся RGB режим: ВЫКЛ"
RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold
RgbToggle.TextSize = 11
RgbToggle.Parent = SettingsContent
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 35)
ShutdownButton.Position = UDim2.new(0, 0, 0, 45)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25)
ShutdownButton.Text = "ПОЛНОСТЬЮ УДАЛИТЬ СКРИПТ"
ShutdownButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ShutdownButton.Font = Enum.Font.GothamBold
ShutdownButton.TextSize = 11
ShutdownButton.Parent = SettingsContent
Instance.new("UICorner", ShutdownButton).CornerRadius = UDim.new(0, 6)

-- Быстрый рендер-цикл для плавной смены оттенков
RunService.RenderStepped:Connect(function()
    if getgenv().RGB_Enabled then
        local hue = (tick() % 4) / 4
        local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color
        ToggleButton.TextColor3 = color
    end
end)

RgbToggle.MouseButton1Click:Connect(function()
    getgenv().RGB_Enabled = not getgenv().RGB_Enabled
    if getgenv().RGB_Enabled then
        RgbToggle.Text = "Переливающийся RGB режим: ВКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Переливающийся RGB режим: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

-- Полное уничтожение всех запущенных процессов и очистка GUI
ShutdownButton.MouseButton1Click:Connect(function()
    getgenv().AutoFarmAdvanced = false
    getgenv().AutoRNGEvent = false
    getgenv().RGB_Enabled = false
    ScreenGui:Destroy()
end)

-- Лог успешного старта в игровой чат
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Успешно скачан с репозитория vovankalivan-sketch!",
    Color = Color3.fromRGB(75, 255, 75),
    Font = Enum.Font.GothamBold,
    TextSize = 14
})
