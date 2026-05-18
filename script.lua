-- Legenda32Hub [Pet Simulator 99 - Angel Dog Farm] | Delta Client (Tabbed UI)
if not game:IsLoaded() then game.Loaded:Wait() end

-- Статистика в глобальной памяти
if not _G.TotalRejoins then _G.TotalRejoins = 0 end
if not _G.TotalDistance then _G.TotalDistance = 0 end
if not _G.SessionStartTime then _G.SessionStartTime = os.time() end

local scriptRunning = true
_G.ScriptEnabled = true
_G.ClimbSpeed = 50
_G.MaxHeight = 200000
_G.FpsBoostEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Встроенный Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
local afkConnection
afkConnection = LocalPlayer.Idled:Connect(function()
    if scriptRunning then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    else
        if afkConnection then afkConnection:Disconnect() end
    end
end)

-- Удаление старого GUI
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_Delta")
if oldGui then oldGui:Destroy() end

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legenda32Hub_Delta"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- Кнопка Скрыть/Показать
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 140, 0, 35)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Text = "Legenda Hub (Скрыть)"
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 14
OpenCloseBtn.Parent = ScreenGui

-- Главное компактное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 320) -- Размер сильно уменьшен благодаря вкладкам
MainFrame.Position = UDim2.new(0, 10, 0, 55)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Parent = ScreenGui

-- Логика перемещения меню (Drag & Drop)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
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
    if input == dragInput and dragging then updateDrag(input) end
end)

OpenCloseBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    MainFrame.Visible = not MainFrame.Visible
    OpenCloseBtn.Text = MainFrame.Visible and "Legenda Hub (Скрыть)" or "Legenda Hub (Открыть)"
end)

-- Заголовок хаба
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "Legenda32 Hub [PRO]"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.Parent = MainFrame

-- --- СОЗДАНИЕ ПАНЕЛИ ВКЛАДОК ---
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Size = UDim2.new(0.33, 0, 1, 0)
Tab1Btn.Position = UDim2.new(0, 0, 0, 0)
Tab1Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 150)
Tab1Btn.Text = "Фарм"
Tab1Btn.Font = Enum.Font.SourceSansBold
Tab1Btn.Parent = TabFrame

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Size = UDim2.new(0.33, 0, 1, 0)
Tab2Btn.Position = UDim2.new(0.33, 0, 0, 0)
Tab2Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2Btn.Text = "Настройки"
Tab2Btn.Font = Enum.Font.SourceSansBold
Tab2Btn.Parent = TabFrame

local Tab3Btn = Instance.new("TextButton")
Tab3Btn.Size = UDim2.new(0.34, 0, 1, 0)
Tab3Btn.Position = UDim2.new(0.66, 0, 0, 0)
Tab3Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Tab3Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab3Btn.Text = "Инфо / Стата"
Tab3Btn.Font = Enum.Font.SourceSansBold
Tab3Btn.Parent = TabFrame

-- --- СОЗДАНИЕ КОНТЕЙНЕРОВ ДЛЯ ВКЛАДОК ---
local FarmTab = Instance.new("Frame")
FarmTab.Size = UDim2.new(1, 0, 1, -65)
FarmTab.Position = UDim2.new(0, 0, 0, 65)
FarmTab.BackgroundTransparency = 1
FarmTab.Visible = true
FarmTab.Parent = MainFrame

local SettingsTab = Instance.new("Frame")
SettingsTab.Size = UDim2.new(1, 0, 1, -65)
SettingsTab.Position = UDim2.new(0, 0, 0, 65)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false
SettingsTab.Parent = MainFrame

local InfoTab = Instance.new("ScrollingFrame") -- Скролл-панель для статы и гайда
InfoTab.Size = UDim2.new(1, 0, 1, -65)
InfoTab.Position = UDim2.new(0, 0, 0, 65)
InfoTab.BackgroundTransparency = 1
InfoTab.ScrollBarThickness = 4
InfoTab.CanvasSize = UDim2.new(0, 0, 0, 320)
InfoTab.Visible = false
InfoTab.Parent = MainFrame

-- Логика переключения вкладок
local function switchTab(tabNumber)
    FarmTab.Visible = (tabNumber == 1)
    SettingsTab.Visible = (tabNumber == 2)
    InfoTab.Visible = (tabNumber == 3)
    
    Tab1Btn.BackgroundColor3 = (tabNumber == 1) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Tab1Btn.TextColor3 = (tabNumber == 1) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    
    Tab2Btn.BackgroundColor3 = (tabNumber == 2) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Tab2Btn.TextColor3 = (tabNumber == 2) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    
    Tab3Btn.BackgroundColor3 = (tabNumber == 3) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Tab3Btn.TextColor3 = (tabNumber == 3) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)
Tab3Btn.MouseButton1Click:Connect(function() switchTab(3) end)

-- --- ЭЛЕМЕНТЫ ВКЛАДКИ «ФАРМ» ---
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Авто-Подъем: ВКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = FarmTab

local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 220, 0, 40)
TPBtn.Position = UDim2.new(0, 20, 0, 75)
TPBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Text = "Прыгнуть под карту"
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 14
TPBtn.Parent = FarmTab

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 220, 0, 40)
SpeedInput.Position = UDim2.new(0, 20, 0, 130)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 14
SpeedInput.Parent = FarmTab

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 220, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 185)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Авто-подъем запущен"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.Parent = FarmTab

-- --- ЭЛЕМЕНТЫ ВКЛАДКИ «НАСТРОЙКИ» ---
local FpsBtn = Instance.new("TextButton")
FpsBtn.Size = UDim2.new(0, 220, 0, 40)
FpsBtn.Position = UDim2.new(0, 20, 0, 20)
FpsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsBtn.Text = "Boost FPS (Черный Экран): ВЫКЛ"
FpsBtn.Font = Enum.Font.SourceSansBold
FpsBtn.TextSize = 12
FpsBtn.Parent = SettingsTab

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 220, 0, 40)
UnloadBtn.Position = UDim2.new(0, 20, 0, 75)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
UnloadBtn.Text = "ФУЛ ВЫГРУЗКА СКРИПТА"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 14
UnloadBtn.Parent = SettingsTab

-- --- ЭЛЕМЕНТЫ ВКЛАДКИ «ИНФО / СТАТА» ---
local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 220, 0, 20)
HeightLabel.Position = UDim2.new(0, 20, 0, 10)
HeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeightLabel.Text = "Текущая высота Y: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 13
HeightLabel.TextXAlignment = Enum.TextXAlignment.Left
HeightLabel.Parent = InfoTab

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0, 220, 0, 20)
TimerLabel.Position = UDim2.new(0, 20, 0, 35)
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerLabel.Text = "Время в игре: 00:00:00"
TimerLabel.Font = Enum.Font.SourceSans
TimerLabel.TextSize = 13
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerLabel.Parent = InfoTab

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 220, 0, 20)
DistLabel.Position = UDim2.new(0, 20, 0, 60)
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistLabel.Text = "Всего пролетено: 0 studs"
DistLabel.Font = Enum.Font.SourceSans
DistLabel.TextSize = 13
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = InfoTab

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Size = UDim2.new(0, 220, 0, 20)
ServerLabel.Position = UDim2.new(0, 20, 0, 85)
ServerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerLabel.Text = "Пройдено серверов: " .. tostring(_G.TotalRejoins)
ServerLabel.Font = Enum.Font.SourceSans
ServerLabel.TextSize = 13
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerLabel.Parent = InfoTab

-- Текстовый Гайд и данные о Хуге
local GuideLabel = Instance.new("TextLabel")
GuideLabel.Size = UDim2.new(0, 220, 0, 180)
GuideLabel.Position = UDim2.new(0, 20, 0, 115)
GuideLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
GuideLabel.Text = "=== HUGE ANGEL DOG ===\nRAP: Неоценен (Бесценный)\nExists: 6 шт на весь мир!\n\nГайд: Шанс появления алтаря\nсоставляет 1 к 1 000 000.\nЛестница генерируется по\nмере полета. Скрипт сам\nсделает ТП и выключит полет,\nесли комната заспавнится.\nКаждые 200к высоты чит сам\nобновляет сервер от багов."
GuideLabel.Font = Enum.Font.SourceSans
GuideLabel.TextSize = 13
GuideLabel.TextYAlignment = Enum.TextYAlignment.Top
GuideLabel.TextXAlignment = Enum.TextXAlignment.Left
GuideLabel.Parent = InfoTab

-- --- ЛОГИКА ФУНКЦИОНАЛА СКРИПТА ---
SpeedInput.FocusLost:Connect(function()
    if not scriptRunning then return end
    local num = tonumber(SpeedInput.Text:match("%d+"))
    if num then _G.ClimbSpeed = num SpeedInput.Text = "Скорость: " .. tostring(num)
    else SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed) end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.ScriptEnabled = not _G.ScriptEnabled
    ToggleBtn.BackgroundColor3 = _G.ScriptEnabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(150, 30, 30)
    ToggleBtn.Text = _G.ScriptEnabled and "Авто-Подъем: ВКЛ" or "Авто-Подъем: ВЫКЛ"
end)

FpsBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.FpsBoostEnabled = not _G.FpsBoostEnabled
    RunService:Set3dRenderingEnabled(not _G.FpsBoostEnabled)
    FpsBtn.BackgroundColor3 = _G.FpsBoostEnabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(40, 40, 40)
    FpsBtn.Text = _G.FpsBoostEnabled and "Boost FPS (Черный Экран): ВКЛ" or "Boost FPS (Черный Экран): ВЫКЛ"
end)

local function doDrop()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -260, 0)
        StatusLabel.Text = "Статус: Упал под карту"
    end
end
TPBtn.MouseButton1Click:Connect(doDrop)

task.spawn(function()
    task.wait(2.5)
    doDrop()
end)

local function unloadScript()
    scriptRunning = false 
    _G.ScriptEnabled = false
    RunService:Set3dRenderingEnabled(true)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then 
        character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) 
    end
    if ScreenGui then ScreenGui:Destroy() end
end
UnloadBtn.MouseButton1Click:Connect(unloadScript)

local function reconnect()
    if not scriptRunning then return end
    _G.TotalRejoins = _G.TotalRejoins + 1
    StatusLabel.Text = "Лимит 200к! Перезаход..."
    
    local launchCode = [[loadstring(game:HttpGet("https://githubusercontent.com" .. tostring(math.random(1,9999))))()]]
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
    if qot then pcall(function() qot(launchCode) end) end
    
    task.wait(1)
    pcall(function()
        if #Players:GetPlayers() <= 1 then 
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
        end
    end)
end

local function findStairsPart()
    local foundPart = nil
    pcall(function()
        for _, item in ipairs(workspace:GetChildren()) do
            if item:IsA("Model") then
                local name = item.Name:lower()
                if string.find(name, "stair") or string.find(name, "climb") or string.find(name, "cloud") or string.find(name, "staircase") then
                    local pPart = item.PrimaryPart or item:FindFirstChildOfClass("Part") or item:FindFirstChildOfClass("MeshPart")
                    if pPart then
                        local character = LocalPlayer.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local dist = (pPart.Position - character.HumanoidRootPart.Position).Magnitude
                            if dist < 200 then
                                foundPart = pPart
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    return foundPart
end

local connection
local lastY = 0

connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then 
        if connection then connection:Disconnect() end 
        return 
    end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local currentHeight = math.floor(hrp.Position.Y)
    HeightLabel.Text = "Текущая высота Y: " .. tostring(currentHeight)

    local elapsed = os.time() - _G.SessionStartTime
    TimerLabel.Text = string.format("Время в игре: %02d:%02d:%02d", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)

    if _G.ScriptEnabled and currentHeight > lastY then
        _G.TotalDistance = _G.TotalDistance + (currentHeight - lastY)
        DistLabel.Text = "Всего пролетено: " .. tostring(math.floor(_G.TotalDistance)) .. " studs"
    end
    lastY = currentHeight

    if currentHeight >= _G.MaxHeight then 
        reconnect() 
        return 
    end

    if _G.ScriptEnabled then
        if character:FindFirstChild("Humanoid") then 
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) 
        end

        local targetPart = findStairsPart()

        if targetPart then
            _G.ScriptEnabled = false
            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 5, 0))
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
            ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
            StatusLabel.Text = "Найдено: " .. tostring(targetPart.Parent.Name)
        else
            StatusLabel.Text = "Статус: Полет вверх..."
            hrp.CFrame = hrp.CFrame * CFrame.new(0, _G.ClimbSpeed * deltaTime, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
