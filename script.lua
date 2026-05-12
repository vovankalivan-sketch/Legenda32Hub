-- Инициализация и обход лимитов Xeno
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local TargetGui = game:GetService("CoreGui"):FindFirstChild("SkeetMenu_BS") or LocalPlayer.PlayerGui:FindFirstChild("SkeetMenu_BS")
if TargetGui then TargetGui:Destroy() end

-- Создание UI контейнера
local SkeetMenu = Instance.new("ScreenGui")
SkeetMenu.Name = "SkeetMenu_BS"
SkeetMenu.DisplayOrder = 9999
SkeetMenu.ResetOnSpawn = false
SkeetMenu.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Главное меню Skeet
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 520, 0, 360)

-- Оригинальная неоновая линия сверху
local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)

-- Скрипт бинда: Открытие / Закрытие на клавишу DELETE
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Таблица состояний функций (Конфиг)
local Config = {
    Aimbot = false,
    SilentAim = false,
    EspBoxes = false,
    NoRecoil = false
}

-- Групповые коробки (Groupboxes) как в Skeet
local function CreateGroupbox(title, position, size)
    local Box = Instance.new("Frame")
    Box.Parent = MainFrame
    Box.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Box.BorderColor3 = Color3.fromRGB(30, 30, 30)
    Box.Position = position
    Box.Size = size

    local Label = Instance.new("TextLabel")
    Label.Parent = Box
    Label.Position = UDim2.new(0, 12, 0, -6)
    Label.Size = UDim2.new(0, 60, 0, 10)
    Label.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Label.Font = Enum.Font.Code
    Label.Text = " " .. title .. " "
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 10

    local List = Instance.new("UIListLayout")
    List.Parent = Box
    List.Padding = UDim.new(0, 6)
    List.Position = UDim2.new(0, 0, 0, 12)
    
    return Box
end

-- Создаем две колонки: Rage (Аим) и Visuals (Валхак)
local RageBox = CreateGroupbox("Ragebot", UDim2.new(0, 15, 0, 25), UDim2.new(0.46, 0, 0.9, 0))
local VisualsBox = CreateGroupbox("Visuals", UDim2.new(0.52, 0, 0.25, 0), UDim2.new(0.46, 0, 0.9, 0))

-- Функция чекбокса в Skeet-стиле
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

-- Наполняем меню кнопками
AddToggle("Enabled Aimbot", RageBox, "Aimbot")
AddToggle("Silent Aim", RageBox, "SilentAim")
AddToggle("Remove Recoil", RageBox, "NoRecoil")
AddToggle("Player Boxes", VisualsBox, "EspBoxes")

----------------------------------------------------------------
-- РАБОЧИЙ ФУНКЦИОНАЛ ДЛЯ BLOX STRIKE
----------------------------------------------------------------

-- Поиск ближайшего противника
local function GetClosestPlayer()
    local closest = nil
    local maxDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UIS:GetMouseLocation()
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < maxDist then
                    closest = p.Character
                    maxDist = dist
                end
            end
        end
    end
    return closest
end

-- Логика Аимбота и Сайлент Аима (Каждый кадр)
RunService.RenderStepped:Connect(function()
    local target = GetClosestPlayer()
    if target and target:FindFirstChild("Head") then
        -- Обычный жесткий Аимбот (Наведение камеры)
        if Config.Aimbot then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        end
    end
    
    -- Функция No Recoil (Антиотдача) через зануление смещения осей
    if Config.NoRecoil then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate") then
                -- Патч локальных значений отдачи оружия в Blox Strike
                for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name == "Recoil" or v.Name == "Spread") then
                        v.Value = 0
                    end
                end
            end
        end)
    end
end)

-- Логика Сайлент Аима (Перехват выстрела через хук метатаблицы Xeno)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcstackclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim and (method == "FireServer" or method == "InvokeServer") and self.Name == "Shoot" then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild("Head") then
            -- Подменяем координаты направления пули на голову противника
            args[1] = target.Head.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Функция создания ESP бокса
local function CreateEsp(player)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = "SkeetESP"
    Box.AlwaysOnTop = true
    Box.ZIndex = 5
    Box.Adornee = player.Character
    Box.Color3 = Color3.fromRGB(163, 212, 47) -- Зеленый Skeet цвет
    Box.Size = Vector3.new(4, 5.5, 1)
    Box.Transparency = 0.5
    
    -- Проверка на то, чтобы ESP обновлялось динамически
    player.CharacterAdded:Connect(function(char)
        Box.Adornee = char
    end)
    
    RunService.RenderStepped:Connect(function()
        Box.Visible = Config.EspBoxes and (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0) or false
    end)
end

-- Вешаем ESP на игроков
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then pcall(CreateEsp, p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then p.CharacterAdded:Connect(function() pcall(CreateEsp, p) end) end
end)

-- Скрипт плавного перемещения меню мышкой
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
