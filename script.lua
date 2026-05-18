-- Legenda32Hub [Pet Simulator 99 - Angel Dog Farm] | Delta Client (Перетаскиваемый)
if not game:IsLoaded() then game.Loaded:Wait() end

-- Переменные контроля
local scriptRunning = true
_G.ScriptEnabled = false
_G.ClimbSpeed = 50
_G.MaxHeight = 200000 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Встроенный Anti-AFK (Чтобы игра не кикнула за АФК)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if scriptRunning then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

-- Удаление старых копий
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_Delta")
if oldGui then oldGui:Destroy() end

-- Интерфейс GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legenda32Hub_Delta"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- Главная кнопка Скрыть/Показать
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 140, 0, 35)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Text = "Legenda Hub (Скрыть)"
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 14
OpenCloseBtn.Parent = ScreenGui

-- Главный фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Position = UDim2.new(0, 10, 0, 55)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Parent = ScreenGui

-- ЛОГИКА ПЕРЕМЕЩЕНИЯ МЕНЮ (Drag & Drop)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Сворачивание меню по клику
OpenCloseBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    MainFrame.Visible = not MainFrame.Visible
    OpenCloseBtn.Text = MainFrame.Visible and "Legenda Hub (Скрыть)" or "Legenda Hub (Открыть)"
end)

-- Заголовок хаба (За него тоже можно тащить)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "Legenda32 Hub [Delta]"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Переключатель автоматического подъема
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 15
ToggleBtn.Parent = MainFrame

-- Мгновенный сброс под текстуры PS99
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 200, 0, 40)
TPBtn.Position = UDim2.new(0, 20, 0, 100)
TPBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Text = "Прыгнуть под карту"
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 15
TPBtn.Parent = MainFrame

-- Поле изменения скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 200, 0, 40)
SpeedInput.Position = UDim2.new(0, 20, 0, 150)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 15
SpeedInput.Parent = MainFrame

-- Кнопка полной очистки и выгрузки чита
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 200, 0, 40)
UnloadBtn.Position = UDim2.new(0, 20, 0, 200)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
UnloadBtn.Text = "ФУЛ ВЫГРУЗКА"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 15
UnloadBtn.Parent = MainFrame

-- Индикатор высоты
local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 200, 0, 25)
HeightLabel.Position = UDim2.new(0, 20, 0, 250)
HeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeightLabel.Text = "Высота Y: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 14
HeightLabel.Parent = MainFrame

-- Текстовый статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 200, 0, 25)
StatusLabel.Position = UDim2.new(0, 20, 0, 280)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Готов"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- Обработка ввода скорости
SpeedInput.FocusLost:Connect(function()
    if not scriptRunning then return end
    local num = tonumber(SpeedInput.Text:match("%d+"))
    if num then
        _G.ClimbSpeed = num
        SpeedInput.Text = "Скорость: " .. tostring(num)
    else
        SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
    end
end)

-- Переключатель On/Off
ToggleBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.ScriptEnabled = not _G.ScriptEnabled
    if _G.ScriptEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
        ToggleBtn.Text = "Авто-Подъем: ВКЛ"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
        ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
    end
end)

-- Телепортация под текстуры карты
TPBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -260, 0)
        StatusLabel.Text = "Статус: Упал под карту"
    end
end)

-- Логика полной выгрузки для Delta Client
local function unloadScript()
    scriptRunning = false
    _G.ScriptEnabled = false
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    ScreenGui:Destroy()
end
UnloadBtn.MouseButton1Click:Connect(unloadScript)

-- Функция безопасного серверного реконнекта
local function reconnect()
    if not scriptRunning then return end
    StatusLabel.Text = "Реконнект..."
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

-- Поиск динамических объектов лестницы в PS99 (Стабильный радиус)
local function findStairs()
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Model") then
            local name = item.Name:lower()
            if string.find(name, "stair") or string.find(name, "climb") or string.find(name, "cloud") or string.find(name, "staircase") then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local dist = (item:GetPivot().Position - character.HumanoidRootPart.Position).Magnitude
                    if dist < 200 then 
                        return item
                    end
                end
            end
        end
    end
    return nil
end

-- Основной рабочий поток Delta Client
local connection
connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then
        if connection then connection:Disconnect() end
        return
    end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local currentHeight = math.floor(hrp.Position.Y)
    HeightLabel.Text = "Высота Y: " .. tostring(currentHeight)

    -- Перезаход при достижении лимита высоты
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
            -- Функция Anti-Fall (Создание временной невидимой платформы под игроком, чтобы не упасть)
            local bPart = Instance.new("Part")
            bPart.Size = Vector3.new(20, 1, 20)
            bPart.Transparency = 1
            bPart.Anchored = true
            bPart.Parent = workspace
            
            local pCFrame = foundObject:GetPivot()
            bPart.CFrame = pCFrame + Vector3.new(0, 3, 0)
            hrp.CFrame = pCFrame + Vector3.new(0, 5, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            _G.ScriptEnabled = false
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
            ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
            StatusLabel.Text = "Найдено: " .. foundObject.Name
            
            -- Удаляем платформу через 5 секунд, когда игрок сориентируется
            task.wait(5)
            if bPart then bPart:Destroy() end
        else
            -- Стабильный полет вверх
            StatusLabel.Text = "Статус: Полет вверх..."
            hrp.CFrame = hrp.CFrame * CFrame.new(0, _G.ClimbSpeed * deltaTime, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
