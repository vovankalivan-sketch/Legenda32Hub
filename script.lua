local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Полная очистка предыдущих сессий перед запуском
local OldGui = game:GetService("CoreGui"):FindFirstChild("SkeetMenu_BS") or LocalPlayer.PlayerGui:FindFirstChild("SkeetMenu_BS")
if OldGui then OldGui:Destroy() end

-- Создание UI контейнера
local SkeetMenu = Instance.new("ScreenGui")
SkeetMenu.Name = "SkeetMenu_BS"
SkeetMenu.DisplayOrder = 9999
SkeetMenu.ResetOnSpawn = false
SkeetMenu.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия/закрытия
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

-- Главное меню Skeet
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Visible = true

MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Верхняя неоновая линия
local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)

-- Панель вкладок (Слева)
local LeftTabs = Instance.new("Frame")
LeftTabs.Parent = MainFrame
LeftTabs.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LeftTabs.BorderColor3 = Color3.fromRGB(25, 25, 25)
LeftTabs.Position = UDim2.new(0, 10, 0, 15)
LeftTabs.Size = UDim2.new(0, 100, 1, -55)

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Parent = LeftTabs

-- Кнопка выгрузки скрипта (UNLOAD)
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

-- Контейнер для страниц (Справа)
local PageContainer = Instance.new("Frame")
PageContainer.Parent = MainFrame
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 120, 0, 15)
PageContainer.Size = UDim2.new(1, -130, 1, -25)

-- Таблица глобальной конфигурации
local Config = {
    Aimbot = false, SilentAim = false, NoRecoil = false,
    EspBoxes = false, EspChams = false, BunnyHop = false
}

local Connections = {}
local Pages = {}

-- Функция создания страниц и вкладок
local function CreatePage(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = LeftTabs
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundTransparency = 1
    TabButton.Font = Enum.Font.Code
    TabButton.Text = name:upper()
    TabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabButton.TextSize = 11

    local Page = Instance.new("Frame")
    Page.Name = name .. "Page"
    Page.Parent = PageContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    local Groupbox = Instance.new("Frame")
    Groupbox.Parent = Page
    Groupbox.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    Groupbox.BorderColor3 = Color3.fromRGB(30, 30, 30)
    Groupbox.Position = UDim2.new(0, 0, 0, 0)
    Groupbox.Size = UDim2.new(1, 0, 1, 0)

    local GroupboxLabel = Instance.new("TextLabel")
    GroupboxLabel.Parent = Groupbox
    GroupboxLabel.Position = UDim2.new(0, 12, 0, -6)
    GroupboxLabel.Size = UDim2.new(0, 65, 0, 12)
    GroupboxLabel.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    GroupboxLabel.Font = Enum.Font.Code
    GroupboxLabel.Text = " " .. name .. " "
    GroupboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GroupboxLabel.TextSize = 10

    local ElementsLayout = Instance.new("UIListLayout")
    ElementsLayout.Parent = Groupbox
    ElementsLayout.Padding = UDim.new(0, 6)
    ElementsLayout.Position = UDim2.new(0, 0, 0, 12)

    TabButton.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(LeftTabs:GetChildren()) do 
            if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(140, 140, 140) end 
        end
        Page.Visible = true
        TabButton.TextColor3 = Color3.fromRGB(163, 212, 47)
    end)

    Pages[name] = Page
    return Groupbox
end

-- Создание чекбоксов
local function AddToggle(name, parent, config_key)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 20)

    local Box = Instance.new("TextButton")
    Box.Parent = Frame
    Box.Position = UDim2.new(0, 12, 0, 4)
    Box.Size = UDim2.new(0, 9, 0, 9)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Box.Text = ""

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

    Box.MouseButton1Click:Connect(function()
        Config[config_key] = not Config[config_key]
        Box.BackgroundColor3 = Config[config_key] and Color3.fromRGB(163, 212, 47) or Color3.fromRGB(30, 30, 30)
        Label.TextColor3 = Config[config_key] and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(150, 150, 150)
    end)
end

-- Инициализация вкладок
local RageSection = CreatePage("Rage")
local LegitSection = CreatePage("Legit")
local VisualsSection = CreatePage("Visuals")
local MiscSection = CreatePage("Misc")

-- Сортировка функций по вкладкам
AddToggle("Enabled Aimbot", RageSection, "Aimbot")
AddToggle("Silent Aim", RageSection, "SilentAim")
AddToggle("Remove Recoil", RageSection, "NoRecoil")

AddToggle("Player Boxes (Enemy)", VisualsSection, "EspBoxes")
AddToggle("Chams Wallhack (Enemy)", VisualsSection, "EspChams")

AddToggle("BunnyHop (Space)", MiscSection, "BunnyHop")

-- Дефолтный выбор вкладки при старте
Pages["Rage"].Visible = true
LeftTabs:FindFirstChildOfClass("TextButton").TextColor3 = Color3.fromRGB(163, 212, 47)

-- =================================================================
-- РАБОЧАЯ ЛОГИКА ФУНКЦИЙ (AIM / NO RECOIL / ENEMY CHECK)
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

-- Главный игровой цикл
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

    -- ЛОГИКА РАБОЧЕГО BUNNYHOP (Распрыжка)
    if Config.BunnyHop and UIS:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.FloorMaterial ~= Enum.Material.Air then
            char.Humanoid.Jump = true
        end
    end
end))

-- Сайлент Аим хук метатаблицы Xeno
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

-- =================================================================
-- НАСТОЯЩИЙ WALLHACK (ПОДСВЕЧИВАЕТ ТОЛЬКО ВРАГОВ КРАСНЫМ)
-- =================================================================
local function ApplyWallhack(player)
    local function SetupCharacterVisuals(char)
        if not char then return end
        if not IsEnemy(player) then return end -- Пропускаем союзников
        
        for _, old in pairs(char:GetChildren()) do
            if old.Name == "Skeet_Chams" or old.Name == "Skeet_Box" then old:Destroy() end
        end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "Skeet_Chams"
        Highlight.Parent = char
        Highlight.FillColor = Color3.fromRGB(240, 50, 50) -- Красный цвет для врагов
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.FillTransparency = 0.4
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        local Box = Instance.new("BoxHandleAdornment")
        Box.Name = "Skeet_Box"
        Box.Parent = char
        Box.AlwaysOnTop = true
        Box.ZIndex = 5
        Box.Adornee = char
        Box.Color3 = Color3.fromRGB(240, 50, 50)
        Box.Size = Vector3.new(4, 5.5, 1)
        Box.Transparency = 0.6

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

-- =================================================================
-- СТАТИЧЕСКАЯ ВЫГРУЗКА И ОЧИСТКА ПАМЯТИ (UNLOAD)
-- =================================================================
UnloadButton.MouseButton1Click:Connect(function()
    -- Отключаем циклы отрисовки и событий
    for _, connection in pairs(Connections) do
        if connection then connection:Disconnect() end
    end
    
    -- Очищаем все Highlight и Боксы с игроков на карте
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            for _, obj in pairs(p.Character:GetChildren()) do
                if obj.Name == "Skeet_Chams" or obj.Name == "Skeet_Box" then obj:Destroy() end
            end
        end
    end
    
    -- Возвращаем метатаблицу Xeno в исходное состояние
    setreadonly(mt, false)
    mt.__namecall = oldNamecall
    setreadonly(mt, true)
    
    -- Полностью уничтожаем меню
    SkeetMenu:Destroy()
end)

-- Плавный Drag для меню мышкой
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
