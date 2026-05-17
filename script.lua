-- Legenda32Hub [Pet Simulator 99 - Angel Dog Farm] | Delta Client (AI Edition)
if not game:IsLoaded() then game.Loaded:Wait() end

-- Переменные контроля
local scriptRunning = true
_G.ScriptEnabled = false
_G.AiEnabled = false
_G.ClimbSpeed = 50
_G.MaxHeight = 200000 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Защита от дублирования
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_Delta")
if oldGui then oldGui:Destroy() end

-- Интерфейс GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legenda32Hub_Delta"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 140, 0, 35)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Text = "Legenda Hub (Скрыть)"
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 14
OpenCloseBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 380) -- Увеличили под кнопку ИИ
MainFrame.Position = UDim2.new(0, 10, 0, 55)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Parent = ScreenGui

OpenCloseBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    MainFrame.Visible = not MainFrame.Visible
    OpenCloseBtn.Text = MainFrame.Visible and "Legenda Hub (Скрыть)" or "Legenda Hub (Открыть)"
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "Legenda32 Hub [AI]"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- НОВАЯ КНОПКА: ИИ Автофарм
local AiBtn = Instance.new("TextButton")
AiBtn.Size = UDim2.new(0, 200, 0, 40)
AiBtn.Position = UDim2.new(0, 20, 0, 50)
AiBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 120)
AiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AiBtn.Text = "AI Автофарм: ВЫКЛ"
AiBtn.Font = Enum.Font.SourceSansBold
AiBtn.TextSize = 15
AiBtn.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 100)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 15
ToggleBtn.Parent = MainFrame

local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 200, 0, 40)
TPBtn.Position = UDim2.new(0, 20, 0, 150)
TPBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Text = "Прыгнуть под карту"
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 15
TPBtn.Parent = MainFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 200, 0, 40)
SpeedInput.Position = UDim2.new(0, 20, 0, 200)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 15
SpeedInput.Parent = MainFrame

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 200, 0, 40)
UnloadBtn.Position = UDim2.new(0, 20, 0, 250)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
UnloadBtn.Text = "ФУЛ ВЫГРУЗКА"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 15
UnloadBtn.Parent = MainFrame

local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 200, 0, 25)
HeightLabel.Position = UDim2.new(0, 20, 0, 300)
HeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeightLabel.Text = "Высота Y: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 14
HeightLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 200, 0, 25)
StatusLabel.Position = UDim2.new(0, 20, 0, 330)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Готов"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- Логика кнопок
SpeedInput.FocusLost:Connect(function()
    if not scriptRunning then return end
    local num = tonumber(SpeedInput.Text:match("%d+"))
    if num then _G.ClimbSpeed = num SpeedInput.Text = "Скорость: "..tostring(num) end
end)

local function updateButtons()
    ToggleBtn.BackgroundColor3 = _G.ScriptEnabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(150, 30, 30)
    ToggleBtn.Text = _G.ScriptEnabled and "Авто-Подъем: ВКЛ" or "Авто-Подъем: ВЫКЛ"
    AiBtn.BackgroundColor3 = _G.AiEnabled and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(70, 20, 120)
    AiBtn.Text = _G.AiEnabled and "AI Автофарм: ВКЛ" or "AI Автофарм: ВЫКЛ"
end

ToggleBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.ScriptEnabled = not _G.ScriptEnabled
    if _G.ScriptEnabled then _G.AiEnabled = false end -- Ручной режим отключает ИИ
    updateButtons()
end)

local function dropUnderMap()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -260, 0)
        StatusLabel.Text = "Статус: Упал под карту"
    end
end
TPBtn.MouseButton1Click:Connect(dropUnderMap)

-- Функция безопасного авто-реконнекта
local function reconnect(reason)
    if not scriptRunning then return end
    StatusLabel.Text = reason or "Перезаход..."
    task.wait(1)
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

-- Активация ИИ режима
AiBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.AiEnabled = not _G.AiEnabled
    if _G.AiEnabled then
        _G.ScriptEnabled = true
        dropUnderMap()
    else
        _G.ScriptEnabled = false
    end
    updateButtons()
end)

local function unloadScript()
    scriptRunning = false _G.ScriptEnabled = false _G.AiEnabled = false
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    ScreenGui:Destroy()
end
UnloadBtn.MouseButton1Click:Connect(unloadScript)

local function findStairs()
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Model") then
            local name = item.Name:lower()
            if string.find(name, "stair") or string.find(name, "climb") or string.find(name, "cloud") or string.find(name, "staircase") then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if (item:GetPivot().Position - character.HumanoidRootPart.Position).Magnitude < 200 then return item end
                end
            end
        end
    end
    return nil
end

-- Переменные ИИ для отслеживания ступора (зависания)
local lastHeight = 0
local timeInStuck = 0

local connection
connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then if connection then connection:Disconnect() end return end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local currentHeight = math.floor(hrp.Position.Y)
    HeightLabel.Text = "Высота Y: " .. tostring(currentHeight)

    -- Проверка критической высоты
    if currentHeight >= _G.MaxHeight then reconnect("Лимит высоты! Реконнект...") return end

    -- ЛОГИКА ИИ КОНТРОЛЯ ЗАВИСАНИЯ
    if _G.AiEnabled and _G.ScriptEnabled then
        if math.abs(currentHeight - lastHeight) < 5 then
            timeInStuck = timeInStuck + deltaTime
            if timeInStuck > 5 then -- Если стоим на месте дольше 5 секунд (уперлись в бортик)
                _G.AiEnabled = false _G.ScriptEnabled = false updateButtons()
                reconnect("ИИ: Обнаружен тупик! Реконнект...")
                return
            end
        else
            timeInStuck = 0
            -- ИИ настраивает оптимальную скорость "на лету"
            if currentHeight < 5000 then
                _G.ClimbSpeed = 40 -- Медленный старт для стабильной инициализации
            else
                _G.ClimbSpeed = 90 -- Разгон на чистой высоте
            end
            SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
        end
        lastHeight = currentHeight
    end

    -- ОСНОВНОЙ ЦИКЛ ПОЛЕТА
    if _G.ScriptEnabled then
        if character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) end

        local foundObject = findStairs()
        if foundObject then
            local pCFrame = foundObject:GetPivot()
            hrp.CFrame = pCFrame + Vector3.new(0, 5, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            _G.ScriptEnabled = false _G.AiEnabled = false updateButtons()
            StatusLabel.Text = "ИИ Нашел: " .. foundObject.Name
        else
            StatusLabel.Text = _G.AiEnabled and "Статус: ИИ ведет полет..." or "Статус: Полет вверх..."
            hrp.CFrame = hrp.CFrame * CFrame.new(0, _G.ClimbSpeed * deltaTime, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
