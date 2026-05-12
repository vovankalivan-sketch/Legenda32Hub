local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Гарантированное удаление старых зависших копий UI из памяти
local OldGui = game:GetService("CoreGui"):FindFirstChild("SkeetMenu_BS") or LocalPlayer.PlayerGui:FindFirstChild("SkeetMenu_BS")
if OldGui then OldGui:Destroy() end

-- Инициализация корневого контейнера
local SkeetMenu = Instance.new("ScreenGui")
SkeetMenu.Name = "SkeetMenu_BS"
SkeetMenu.DisplayOrder = 9999
SkeetMenu.ResetOnSpawn = false
SkeetMenu.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия/закрытия меню в левом верхнем углу
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "ToggleButton"
MenuButton.Parent = SkeetMenu
MenuButton.Position = UDim2.new(0, 10, 0, 10)
MenuButton.Size = UDim2.new(0, 100, 0, 25)
MenuButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MenuButton.BorderColor3 = Color3.fromRGB(163, 212, 47)
MenuButton.BorderSizePixel = 1
MenuButton.Font = Enum.Font.Code
MenuButton.Text = " GAMESENSE "
MenuButton.TextColor3 = Color3.fromRGB(163, 212, 47)
MenuButton.TextSize = 11
MenuButton.ZIndex = 100

-- Главное окно Skeet.cc
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.ZIndex = 10

MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Оригинальная неоновая полоса Skeet сверху
local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)
Line.ZIndex = 11

-- Левая панель для вкладок
local LeftTabs = Instance.new("Frame")
LeftTabs.Parent = MainFrame
LeftTabs.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LeftTabs.BorderColor3 = Color3.fromRGB(25, 25, 25)
LeftTabs.Position = UDim2.new(0, 10, 0, 15)
LeftTabs.Size = UDim2.new(0, 100, 1, -55)
LeftTabs.ZIndex = 11

-- Кнопка полной выгрузки (UNLOAD)
local UnloadButton = Instance.new("TextButton")
UnloadButton.Parent = MainFrame
UnloadButton.Position = UDim2.new(0, 10, 1, -32)
UnloadButton.Size = UDim2.new(0, 100, 0, 22)
UnloadButton.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
UnloadButton.BorderColor3 = Color3.fromRGB(50, 20, 20)
UnloadButton.Font = Enum.Font.Code
UnloadButton.Text = "UNLOAD"
UnloadButton.TextColor3 = Color3.fromRGB(240, 70, 70)
UnloadButton.TextSize = 11
UnloadButton.ZIndex = 99

-- Контейнер для страниц
local PageContainer = Instance.new("Frame")
PageContainer.Parent = MainFrame
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 120, 0, 15)
PageContainer.Size = UDim2.new(1, -130, 1, -25)
PageContainer.ZIndex = 11

-- Таблица состояний
local Config = {
    Aimbot = false, SilentAim = false, NoRecoil = false, Triggerbot = false,
    EspBoxes = false, EspChams = false, BunnyHop = false
}

local Connections = {}
local Pages = {}
local TabButtons = {}

-- БЕЗОПАСНЫЙ КОНСТРУКТОР СТРАНИЦ НА ЧИСТЫХ КООРДИНАТАХ (БЕЗ UIListLayout)
local function CreatePage(name, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = LeftTabs
    -- Расчет позиции кнопок вручную по индексу order (Шаг 30 пикселей)
    TabButton.Position = UDim2.new(0, 0, 0, (order - 1) * 32)
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundTransparency = 1
    TabButton.Font = Enum.Font.Code
    TabButton.Text = name:upper()
    TabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabButton.TextSize = 11
    TabButton.ZIndex = 15

    local Page = Instance.new("Frame")
    Page.Name = name .. "Page"
    Page.Parent = PageContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ZIndex = 12

    local Groupbox = Instance.new("Frame")
    Groupbox.Parent = Page
    Groupbox.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    Groupbox.BorderColor3 = Color3.fromRGB(30, 30, 30)
    Groupbox.Size = UDim2.new(1, 0, 1, 0)
    Groupbox.ZIndex = 13

    local GroupboxLabel = Instance.new("TextLabel")
    GroupboxLabel.Parent = Groupbox
    GroupboxLabel.Position = UDim2.new(0, 12, 0, -6)
    GroupboxLabel.Size = UDim2.new(0, 65, 0, 12)
    GroupboxLabel.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    GroupboxLabel.Font = Enum.Font.Code
    GroupboxLabel.Text = " " .. name .. " "
    GroupboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GroupboxLabel.TextSize = 10
    GroupboxLabel.ZIndex = 14

    -- Контейнер для тумблеров внутри страницы
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Parent = Groupbox
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Position = UDim2.new(0, 0, 0, 12)
    ContentHolder.Size = UDim2.new(1, 0, 1, -12)
    ContentHolder.ZIndex = 14

    -- Переключение страниц кликом
    TabButton.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(TabButtons) do btn.TextColor3 = Color3.fromRGB(140, 140, 140) end
        Page.Visible = true
        TabButton.TextColor3 = Color3.fromRGB(163, 212, 47)
    end)

    Pages[name] = Page
    table.insert(TabButtons, TabButton)
    return ContentHolder
end

-- БЕЗОПАСНЫЙ КОНСТРУКТОР ТУМБЛЕРОВ С КОРРЕКТНЫМ СДВИГОМ (БЕЗ UIListLayout)
local toggleCounts = {}
local function AddToggle(name, parent, config_key)
    if not toggleCounts[parent] then toggleCounts[parent] = 0 end
    local index = toggleCounts[parent]
    toggleCounts[parent] = toggleCounts[parent] + 1

    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundTransparency = 1
    -- Позиционирование каждого тумблера со сдвигом на 22 пикселя по вертикали
    Frame.Position = UDim2.new(0, 0, 0, index * 22)
    Frame.Size = UDim2.new(1, 0, 0, 20)
    Frame.ZIndex = 15

    local Box = Instance.new("TextButton")
    Box.Parent = Frame
    Box.Position = UDim2.new(0, 12, 0, 4)
    Box.Size = UDim2.new(0, 9, 0, 9)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Box.ZIndex = 17

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 16

    Box.MouseButton1Click:Connect(function()
        Config[config_key] = not Config[config_key]
        Box.BackgroundColor3 = Config[config_key] and Color3.fromRGB(163, 212, 47) or Color3.fromRGB(30, 30, 30)
        Label.TextColor3 = Config[config_key] and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(150, 150, 150)
    end)
end

-- Генерация вкладок по фиксированному порядку (1, 2, 3, 4)
local RageSection = CreatePage("Rage", 1)
local LegitSection = CreatePage("Legit", 2)
local VisualsSection = CreatePage("Visuals", 3)
local MiscSection = CreatePage("Misc", 4)

-- Добавление функций
AddToggle("Enabled Aimbot", RageSection, "Aimbot")
AddToggle("Silent Aim", RageSection, "SilentAim")
AddToggle("Remove Recoil", RageSection, "NoRecoil")

AddToggle("Triggerbot", LegitSection, "Triggerbot")

AddToggle("Player Boxes (Enemy)", VisualsSection, "EspBoxes")
AddToggle("Chams Wallhack (Enemy)", VisualsSection, "EspChams")

AddToggle("BunnyHop (Space)", MiscSection, "BunnyHop")

-- Активация первой вкладки по умолчанию
Pages["Rage"].Visible = true
TabButtons[1].TextColor3 = Color3.fromRGB(163, 212, 47)

-- =================================================================
-- ФУНКЦИОНАЛЬНАЯ ИГРОВАЯ ЛОГИКА
-- =================================================================

local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team or player.TeamColor ~= LocalPlayer.TeamColor
end

local function GetClosestPlayer()
    local closest = nil
    local maxDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UIS:GetMouseLocation()
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < maxDist then closest = p.Character; maxDist = dist end
            end
        end
    end
    return closest
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayer()
    if target and target:FindFirstChild("Head") and Config.Aimbot then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
    end
    
    if Config.NoRecoil then
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name == "Recoil" or v.Name == "Spread") then v.Value = 0 end
            end
        end)
    end
end))

table.insert(Connections, RunService.PreRender:Connect(function()
    if Config.BunnyHop and UIS:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.FloorMaterial ~= Enum.Material.Air then
            char.Humanoid.Jump = true
        end
    end
end))

-- Метатабличный хук на Silent Aim
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcstackclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Config.SilentAim and (method == "FireServer" or method == "InvokeServer") and self.Name == "Shoot" then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild("Head") then
            args = target.Head.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Отрисовка Wallhack (Только враги)
local function ApplyWallhack(player)
    local function SetupCharacterVisuals(char)
        if not char then return end
        task.wait(0.5)
        if not IsEnemy(player) then return end
        
        for _, old in pairs(char:GetChildren()) do
            if old.Name == "Skeet_Chams" or old.Name == "Skeet_Box" then old:Destroy() end
        end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "Skeet_Chams"
        Highlight.Parent = char
        Highlight.FillColor = Color3.fromRGB(240, 50, 50)
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.FillTransparency = 0.4
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Enabled = false

        local Box = Instance.new("BoxHandleAdornment")
        Box.Name = "Skeet_Box"
        Box.Parent = char
        Box.AlwaysOnTop = true
        Box.ZIndex = 5
        Box.Adornee = char
        Box.Color3 = Color3.fromRGB(240, 50, 50)
        Box.Size = Vector3.new(4, 5.5, 1)
        Box.Transparency = 0.6
        Box.Visible = false

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(workspace) or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                conn:Disconnect()
                return
            end
            Highlight.Enabled = Config.EspChams
            Box.Visible = Config.EspBoxes
        end)
        table.insert(Connections, conn)
    end

    if player.Character then SetupCharacterVisuals(player.Character) end
    player.CharacterAdded:Connect(SetupCharacterVisuals)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then ApplyWallhack(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then p.CharacterAdded:Connect(function() ApplyWallhack(p) end) end
end)

-- Кнопка UNLOAD (Полное удаление из системы)
UnloadButton.MouseButton1Click:Connect(function()
    for _, connection in pairs(Connections) do
        if connection then connection:Disconnect() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            for _, obj in pairs(p.Character:GetChildren()) do
                if obj.Name == "Skeet_Chams" or obj.Name == "Skeet_Box" then obj:Destroy() end
            end
        end
    end
    
    setreadonly(mt, false)
    mt.__namecall = oldNamecall
    setreadonly(mt, true)
    
    SkeetMenu:Destroy()
end)

-- Скрипт перетаскивания (Drag & Drop)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
