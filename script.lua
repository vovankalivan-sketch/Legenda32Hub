-- Legenda32Hub [Pet Simulator 99 - Angel Dog Farm]
if not game:IsLoaded() then game.Loaded:Wait() end

-- Глобальные настройки
_G.ScriptEnabled = false
_G.ClimbSpeed = 50
_G.MaxHeight = 70000

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Создание GUI (Удаляем старый, если остался от прошлых запусков)
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_AngelDog") then
    LocalPlayer.PlayerGui.Legenda32Hub_AngelDog:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legenda32Hub_AngelDog"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Главная кнопка Скрыть/Показать
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 120, 0, 30)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Text = "Legenda32 (Скрыть)"
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 14
OpenCloseBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
MainFrame.Parent = ScreenGui

OpenCloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    OpenCloseBtn.Text = MainFrame.Visible and "Legenda32 (Скрыть)" or "Legenda32 (Открыть)"
end)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Text = "Legenda32 Hub"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Переключатель полета
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Полет: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

-- Телепорт под карту
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 210, 0, 40)
TPBtn.Position = UDim2.new(0, 20, 0, 100)
TPBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 150)
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Text = "ТП под карту"
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 16
TPBtn.Parent = MainFrame

-- Настройка скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 210, 0, 40)
SpeedInput.Position = UDim2.new(0, 20, 0, 150)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 16
SpeedInput.Parent = MainFrame

-- Высота
local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 210, 0, 30)
HeightLabel.Position = UDim2.new(0, 20, 0, 200)
HeightLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
HeightLabel.Text = "Высота: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 15
HeightLabel.Parent = MainFrame

-- Статус
local StatusLabel = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 210, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 240)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Ожидание"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Функционал ввода
SpeedInput.FocusLost:Connect(function()
    local num = tonumber(SpeedInput.Text:match("%d+"))
    if num then
        _G.ClimbSpeed = num
        SpeedInput.Text = "Скорость: " .. tostring(num)
    else
        SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
    end
end)

-- Включение/Выключение
ToggleBtn.MouseButton1Click:Connect(function()
    _G.ScriptEnabled = not _G.ScriptEnabled
    if _G.ScriptEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
        ToggleBtn.Text = "Полет: ВКЛ"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleBtn.Text = "Полет: ВЫКЛ"
    end
end)

-- ТП под карту
TPBtn.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -200, 0)
        StatusLabel.Text = "Статус: Сброшен под карту"
    end
end)

-- Функция реконнекта
local function reconnect()
    StatusLabel.Text = "Перезаход..."
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

-- Поиск объектов лестницы (Улучшенный)
local function findStairs()
    -- Ищем по всему Workspace, включая скрытые папки игры
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") or item:IsA("Part") then
            local name = item.Name:lower()
            -- Проверяем ключевые названия элементов Бесконечной Лестницы в PS99
            if string.find(name, "stair") or string.find(name, "staircase") or string.find(name, "inf") then
                -- Убедимся, что объект находится близко к траектории полета
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local dist = (item:GetPivot().Position - character.HumanoidRootPart.Position).Magnitude
                    if dist < 300 then -- Если объект появился в радиусе видимости
                        return item
                    end
                end
            end
        end
    end
    return nil
end

-- Основной цикл
RunService.Heartbeat:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local currentHeight = math.floor(hrp.Position.Y)
    HeightLabel.Text = "Высота: " .. tostring(currentHeight)

    -- Проверка лимита высоты
    if currentHeight >= _G.MaxHeight then
        reconnect()
        return
    end

    if _G.ScriptEnabled then
        if character:FindFirstChild("Humanoid") then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end

        local foundObject = findStairs()

        if foundObject then
            -- Нашли лестницу/награду -> ТП на неё и стоп
            local pCFrame = foundObject:GetPivot()
            hrp.CFrame = pCFrame + Vector3.new(0, 4, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            _G.ScriptEnabled = false
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            ToggleBtn.Text = "Полет: ВЫКЛ"
            StatusLabel.Text = "Найдено: " .. foundObject.Name
        else
            -- Летим вверх
            StatusLabel.Text = "Статус: Подъем..."
            hrp.CFrame = hrp.CFrame * CFrame.new(0, _G.ClimbSpeed * deltaTime, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
