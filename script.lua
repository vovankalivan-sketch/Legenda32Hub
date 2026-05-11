-- ====================================================================
-- ФИНАЛЬНЫЙ СЕТЕВОЙ КОД LEGENDA32HUB (ЗАГРУЖАТЬ В SCRIPT.LUA НА GITHUB)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Принудительное удаление старых GUI при перезапуске
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubUniversal") then 
    LocalPlayer.PlayerGui.LegendaHubUniversal:Destroy() 
end

-- Настройки функций
getgenv().AutoFarmTeleport = false
getgenv().AutoRNGEvent = false
getgenv().RGB_Enabled = false
getgenv().SelectedZoneID = "38" -- По умолчанию выставляем вашу 38 зону

-- ОФИЦИАЛЬНЫЙ СПИСОК ИДЕНТИФИКАТОРОВ ЗОН (ДЛЯ СЕТЕВЫХ КОМАНД СЕРВЕРУ)
local GameZones = {
    {"1", "Area 1 (Spawn)"},
    {"2", "Area 2 (Colorful Forest)"},
    {"3", "Area 3 (Castle)"},
    {"5", "Area 5 (Autumn)"},
    {"10", "Area 10 (Mine)"},
    {"15", "Area 15 (Enchanted Forest)"},
    {"20", "Area 20 (Beach)"},
    {"25", "Area 25 (Tiki)"},
    {"30", "Area 30 (Fossil Digsite)"},
    {"34", "Area 34 (Grand Canyons)"},
    {"38", "Area 38 (Icy Peaks)"},
    {"43", "Area 43 (Volcano)"},
    {"50", "Area 50 (Fire Dojo)"},
    {"75", "Area 75 (Haunted Forest)"},
    {"99", "Area 99 (Rainbow Road)"}
}

-- Функция отправки официального сетевого пакета телепортации на сервер
local function TeleportToServerZone(zoneID)
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            -- Используем официальный удаленный вызов игры для перемещения между зонами
            local teleportRemote = network:FindFirstChild("Teleports_Teleport") or network:FindFirstChild("Teleport") or network:FindFirstChild("Zoning_Teleport")
            if teleportRemote and teleportRemote:IsA("RemoteFunction") then
                teleportRemote:InvokeServer("Area " .. tostring(zoneID))
            else
                -- Резервный метод: перехват через систему карт, если ремот скрыт
                local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if map and root then
                    for _, zone in ipairs(map:GetChildren()) do
                        if zone.Name:match("^" .. tostring(zoneID) .. "%s") or zone.Name == tostring(zoneID) then
                            root.CFrame = zone:GetPivot() + Vector3.new(0, 5, 0)
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubUniversal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Квадратная кнопка "L"
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Мобильный скрипт перетаскивания кнопки пальцем
local dragging, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = ToggleButton.Position
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Главная панель меню
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

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Вкладки
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

BtnFarm.BackgroundColor3 = Color3.fromRGB(40, 40, 55); BtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)

local function createContainer()
    local f = Instance.new("Frame")
    f.Position = UDim2.new(0, 10, 0, 75)
    f.Size = UDim2.new(1, -20, 1, -85)
    f.BackgroundTransparency = 1; f.Visible = false; f.Parent = MainFrame
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
-- ОФИЦИАЛЬНЫЙ АВТОФАРМ С СЕТЕВОЙ СИНХРОНИЗАЦИЕЙ
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 40)
FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
FarmToggle.Text = "Официальный Авто-Фарм: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold; FarmToggle.TextSize = 11; FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 45); StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "Статус: Фарм не активен."
StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 170); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = FarmContent

FarmToggle.MouseButton1Click:Connect(function()
    getgenv().AutoFarmTeleport = not getgenv().AutoFarmTeleport
    if getgenv().AutoFarmTeleport then
        FarmToggle.Text = "Официальный Авто-Фарм: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75); FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            while getgenv().AutoFarmTeleport do
                pcall(function()
                    StatusLabel.Text = "Статус: Удерживаем Зону " .. tostring(getgenv().SelectedZoneID)
                    
                    -- Постоянно вызываем официальный серверный телепорт в выбранную локацию
                    TeleportToServerZone(getgenv().SelectedZoneID)
                    
                    -- Сбор выпадающих предметов вокруг персонажа
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                                obj.CFrame = root.CFrame
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    else
        FarmToggle.Text = "Официальный Авто-Фарм: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75); FarmToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "Статус: Фарм не активен."
    end
end)

-- ==========================================
-- ПРОДВИНУТАЯ СЕТКА СЕРВЕРНЫХ ТЕЛЕПОРТОВ
-- ==========================================
local ScrollTeleport = Instance.new("ScrollingFrame")
ScrollTeleport.Size = UDim2.new(1, 0, 1, 0); ScrollTeleport.BackgroundTransparency = 1
ScrollTeleport.CanvasSize = UDim2.new(0, 0, 2.5, 0); ScrollTeleport.ScrollBarThickness = 2; ScrollTeleport.Parent = TeleportContent

for i, zoneData in ipairs(GameZones) do
    local zoneID = zoneData[1]
    local zoneName = zoneData[2]
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "Выбрать: " .. zoneName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = ScrollTeleport
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().SelectedZoneID = zoneID -- Запоминаем ID зоны для автофарма
        TeleportToServerZone(zoneID)     -- Мгновенно отправляем пакет телепортации на сервер
    end)
end

-- ==========================================
-- ВКЛАДКА: ЭВЕНТЫ
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 40); RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
RngToggle.Text = "Авто RNG Крутилка: ВЫКЛ"; RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold; RngToggle.TextSize = 11; RngToggle.Parent = EventContent
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

RngToggle.MouseButton1Click:Connect(function()
    getgenv().AutoRNGEvent = not getgenv().AutoRNGEvent
    if getgenv().AutoRNGEvent then
        RngToggle.Text = "Авто RNG Крутилка: ВКЛ"; RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75); RngToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        task.spawn(function()
            while getgenv().AutoRNGEvent do
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    if net then
                        local remote = net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll")
                        if remote then remote:InvokeServer() end
                    end
                end)
                task.wait(0.1)
            end
        end)
    else
        RngToggle.Text = "Авто RNG Крутилка: ВЫКЛ"; RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75); RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ВКЛАДКА: ОПЦИИ И ЗАКРЫТИЕ
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 35); RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Переливающийся RGB режим: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold; RgbToggle.TextSize = 11; RgbToggle.Parent = SettingsContent
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 35); ShutdownButton.Position = UDim2.new(0, 0, 0, 45)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25); ShutdownButton.Text = "ПОЛНОСТЬЮ УДАЛИТЬ СКРИПТ"
ShutdownButton.TextColor3 = Color3.fromRGB(255, 100, 100); ShutdownButton.Font = Enum.Font.GothamBold; ShutdownButton.TextSize = 11; ShutdownButton.Parent = SettingsContent
Instance.new("UICorner", ShutdownButton).CornerRadius = UDim.new(0, 6)

RunService.RenderStepped:Connect(function()
    if getgenv().RGB_Enabled then
        local hue = (tick() % 4) / 4; local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color; ToggleButton.TextColor3 = color
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

ShutdownButton.MouseButton1Click:Connect(function()
    getgenv().AutoFarmTeleport = false; getgenv().AutoRNGEvent = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Код успешно обновлен на основе официальных ID зон!",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
