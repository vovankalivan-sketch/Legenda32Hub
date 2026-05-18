-- Legenda32Hub [Pet Simulator 99] | Delta Client (Perfect Stable Edition)
if not game:IsLoaded() then game.Loaded:Wait() end

-- Локальный контроль (Строго ручное управление, никакого автостарта!)
local scriptRunning = true
_G.ScriptEnabled = false 
_G.ClimbSpeed = 50
_G.MaxHeight = 200000
_G.FpsBoostEnabled = false

-- Глобальная статистика
if not _G.TotalRejoins then _G.TotalRejoins = 0 end
if not _G.TotalDistance then _G.TotalDistance = 0 end
if not _G.SessionStartTime then _G.SessionStartTime = os.time() end
_G.DiscordWebhookURL = "https://discord.com_" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Безопасный изолированный Discord поток
local function sendSystemNotify(title, desc, color, fields)
    if not _G.DiscordWebhookURL or _G.DiscordWebhookURL == "" then return end
    task.spawn(function()
        pcall(function()
            local data = {
                ["embeds"] = {{
                    ["title"] = title,
                    ["description"] = desc,
                    ["color"] = color,
                    ["fields"] = fields or {},
                    ["footer"] = {["text"] = "Legenda32 Angel Dog Farm Tracker"}
                }}
            }
            local json = HttpService:JSONEncode(data)
            local req = syn and syn.request or http and http.request or request
            if req then
                req({Url = _G.DiscordWebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
            end
        end)
    end)
end

-- Изолированный Anti-AFK
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

-- Удаление старых копий меню
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_Delta")
if oldGui then oldGui:Destroy() end

-- Создание основы интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legenda32Hub_Delta"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- Компактная кнопка Скрыть/Показать
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 160, 0, 35)
OpenCloseBtn.Position = UDim2.new(0, 10, 0, 10)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Text = "Legenda Hub [Открыть]"
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 14
OpenCloseBtn.Parent = ScreenGui

-- Главное фрейм-окно хаба
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 260)
MainFrame.Position = UDim2.new(0, 10, 0, 55)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Visible = false -- Скрыто по умолчанию при инжекте
MainFrame.Parent = ScreenGui

-- Скрипт Drag & Drop (Перетаскивание меню)
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
    OpenCloseBtn.Text = MainFrame.Visible and "Legenda Hub [Скрыть]" or "Legenda Hub [Открыть]"
end)

-- --- ПАНЕЛЬ ВКЛАДОК (ВЕРХ ХАБА) ---
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local BtnTab1 = Instance.new("TextButton")
BtnTab1.Size = UDim2.new(0.33, 0, 1, 0)
BtnTab1.Position = UDim2.new(0, 0, 0, 0)
BtnTab1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BtnTab1.TextColor3 = Color3.fromRGB(0, 255, 150)
BtnTab1.Text = "ФАРМ"
BtnTab1.Font = Enum.Font.SourceSansBold
BtnTab1.TextSize = 13
BtnTab1.Parent = TabBar

local BtnTab2 = Instance.new("TextButton")
BtnTab2.Size = UDim2.new(0.33, 0, 1, 0)
BtnTab2.Position = UDim2.new(0.33, 0, 0, 0)
BtnTab2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BtnTab2.TextColor3 = Color3.fromRGB(180, 180, 180)
BtnTab2.Text = "НАСТРОЙКИ"
BtnTab2.Font = Enum.Font.SourceSansBold
BtnTab2.TextSize = 12
BtnTab2.Parent = TabBar

local BtnTab3 = Instance.new("TextButton")
BtnTab3.Size = UDim2.new(0.34, 0, 1, 0)
BtnTab3.Position = UDim2.new(0.66, 0, 0, 0)
BtnTab3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BtnTab3.TextColor3 = Color3.fromRGB(180, 180, 180)
BtnTab3.Text = "ИНФО"
BtnTab3.Font = Enum.Font.SourceSansBold
BtnTab3.TextSize = 12
BtnTab3.Parent = TabBar

-- Контейнеры страниц вкладок
local PageFarm = Instance.new("Frame")
PageFarm.Size = UDim2.new(1, 0, 1, -35)
PageFarm.Position = UDim2.new(0, 0, 0, 35)
PageFarm.BackgroundTransparency = 1
PageFarm.Visible = true
PageFarm.Parent = MainFrame

local PageSettings = Instance.new("ScrollingFrame")
PageSettings.Size = UDim2.new(1, 0, 1, -35)
PageSettings.Position = UDim2.new(0, 0, 0, 35)
PageSettings.BackgroundTransparency = 1
PageSettings.ScrollBarThickness = 2
PageSettings.CanvasSize = UDim2.new(0, 0, 0, 240)
PageSettings.Visible = false
PageSettings.Parent = MainFrame

local PageInfo = Instance.new("ScrollingFrame")
PageInfo.Size = UDim2.new(1, 0, 1, -35)
PageInfo.Position = UDim2.new(0, 0, 0, 35)
PageInfo.BackgroundTransparency = 1
PageInfo.ScrollBarThickness = 2
PageInfo.CanvasSize = UDim2.new(0, 0, 0, 260)
PageInfo.Visible = false
PageInfo.Parent = MainFrame

local function selectTab(id)
    PageFarm.Visible = (id == 1)
    PageSettings.Visible = (id == 2)
    PageInfo.Visible = (id == 3)
    BtnTab1.BackgroundColor3 = (id == 1) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
    BtnTab1.TextColor3 = (id == 1) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
    BtnTab2.BackgroundColor3 = (id == 2) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
    BtnTab2.TextColor3 = (id == 2) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
    BtnTab3.BackgroundColor3 = (id == 3) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
    BtnTab3.TextColor3 = (id == 3) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
end

BtnTab1.MouseButton1Click:Connect(function() selectTab(1) end)
BtnTab2.MouseButton1Click:Connect(function() selectTab(2) end)
BtnTab3.MouseButton1Click:Connect(function() selectTab(3) end)

-- --- СТРУКТУРА ВКЛАДКИ: ФАРМ ---
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30) -- Выключена по умолчанию
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = PageFarm

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(0, 220, 0, 35)
DropBtn.Position = UDim2.new(0, 20, 0, 60)
DropBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropBtn.Text = "Прыгнуть под карту"
DropBtn.Font = Enum.Font.SourceSansBold
DropBtn.TextSize = 14
DropBtn.Parent = PageFarm

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 220, 0, 35)
SpeedInput.Position = UDim2.new(0, 20, 0, 105)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 14
SpeedInput.Parent = PageFarm

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 220, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 150)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Нажми ТП под карту"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.Parent = PageFarm

-- --- СТРУКТУРА ВКЛАДКИ: НАСТРОЙКИ ---
local FpsBtn = Instance.new("TextButton")
FpsBtn.Size = UDim2.new(0, 220, 0, 30)
FpsBtn.Position = UDim2.new(0, 20, 0, 10)
FpsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsBtn.Text = "Boost FPS (Черный Экран): ВЫКЛ"
FpsBtn.Font = Enum.Font.SourceSansBold
FpsBtn.TextSize = 11
FpsBtn.Parent = PageSettings

local WebhookInput = Instance.new("TextBox")
WebhookInput.Size = UDim2.new(0, 220, 0, 30)
WebhookInput.Position = UDim2.new(0, 20, 0, 45)
WebhookInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WebhookInput.TextColor3 = Color3.fromRGB(150, 150, 255)
WebhookInput.PlaceholderText = "Твой Discord Webhook"
WebhookInput.Text = _G.DiscordWebhookURL or ""
WebhookInput.Font = Enum.Font.SourceSans
WebhookInput.TextSize = 11
WebhookInput.Parent = PageSettings

local TestWebhookBtn = Instance.new("TextButton")
TestWebhookBtn.Size = UDim2.new(0, 220, 0, 30)
TestWebhookBtn.Position = UDim2.new(0, 20, 0, 80)
TestWebhookBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TestWebhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestWebhookBtn.Text = "ПРОВЕРИТЬ СВЯЗЬ ДИСКОРД"
TestWebhookBtn.Font = Enum.Font.SourceSansBold
TestWebhookBtn.TextSize = 11
TestWebhookBtn.Parent = PageSettings

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 220, 0, 35)
UnloadBtn.Position = UDim2.new(0, 20, 0, 120)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
UnloadBtn.Text = "ФУЛ ВЫГРУЗКА СКРИПТА"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 13
UnloadBtn.Parent = PageSettings

-- --- СТРУКТУРА ВКЛАДКИ: ИНФО ---
local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 220, 0, 20)
HeightLabel.Position = UDim2.new(0, 20, 0, 10)
HeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeightLabel.Text = "Высота Y: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 13
HeightLabel.TextXAlignment = Enum.TextXAlignment.Left
HeightLabel.Parent = PageInfo

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0, 220, 0, 20)
TimerLabel.Position = UDim2.new(0, 20, 0, 30)
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerLabel.Text = "Время: 00:00:00"
TimerLabel.Font = Enum.Font.SourceSans
TimerLabel.TextSize = 13
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
TimerLabel.Parent = PageInfo

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 220, 0, 20)
DistLabel.Position = UDim2.new(0, 20, 0, 50)
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistLabel.Text = "Пролетено: 0 studs"
DistLabel.Font = Enum.Font.SourceSans
DistLabel.TextSize = 13
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = PageInfo

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Size = UDim2.new(0, 220, 0, 20)
ServerLabel.Position = UDim2.new(0, 20, 0, 70)
ServerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerLabel.Text = "Серверов пройдено: " .. tostring(_G.TotalRejoins)
ServerLabel.Font = Enum.Font.SourceSans
ServerLabel.TextSize = 13
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerLabel.Parent = PageInfo

local GuideLabel = Instance.new("TextLabel")
GuideLabel.Size = UDim2.new(0, 220, 0, 140)
GuideLabel.Position = UDim2.new(0, 20, 0, 95)
GuideLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
GuideLabel.Text = "=== HUGE ANGEL DOG ===\nRAP: Неоценен (Бесценный)\nExists: 6 шт на весь мир!\n\nШанс появления алтаря - 1 к 1 000 000.\nСкрипт сделает ТП на ступень и\nвыключит полет при спавне комнаты.\nКаждые 200к высоты чит обновляет\nсервер во избежание тупиков."
GuideLabel.Font = Enum.Font.SourceSans
GuideLabel.TextSize = 12
GuideLabel.TextYAlignment = Enum.TextYAlignment.Top
GuideLabel.TextXAlignment = Enum.TextXAlignment.Left
GuideLabel.Parent = PageInfo

-- --- ЛОГИКА ВЗАИМОДЕЙСТВИЯ С КНОПКАМИ ---
SpeedInput.FocusLost:Connect(function()
    if not scriptRunning then return end
    local num = tonumber(SpeedInput.Text:match("%d+"))
    if num then _G.ClimbSpeed = num SpeedInput.Text = "Скорость: " .. tostring(num)
    else SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed) end
end)

WebhookInput.FocusLost:Connect(function() _G.DiscordWebhookURL = WebhookInput.Text end)

ToggleBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    _G.ScriptEnabled = not _G.ScriptEnabled
    ToggleBtn.BackgroundColor3 = _G.ScriptEnabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(150, 30, 30)
    ToggleBtn.Text = _G.ScriptEnabled and "Авто-Подъем: ВКЛ" or "Авто-Подъем: ВЫКЛ"
    StatusLabel.Text = _G.ScriptEnabled and "Статус: Полет вверх..." or "Статус: Полет остановлен"
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
DropBtn.MouseButton1Click:Connect(doDrop)

TestWebhookBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    local currentHeight = math.floor(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position.Y or 0)
    sendSystemNotify("🔔 Ручной тест связи", "Твой вебхук в хабе настроен правильно и готов к работе.", 3447003, {
        {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
        {["name"] = "Высота Y:", ["value"] = tostring(currentHeight), ["inline"] = true}
    })
    StatusLabel.Text = "Статус: Тест отправлен!"
end)

local function unloadScript()
    scriptRunning = false _G.ScriptEnabled = false
    RunService:Set3dRenderingEnabled(true)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    if ScreenGui then ScreenGui:Destroy() end
end
UnloadBtn.MouseButton1Click:Connect(unloadScript)

local function reconnect()
    if not scriptRunning then return end
    _G.TotalRejoins = _G.TotalRejoins + 1
    
    sendSystemNotify("🔄 Авто-смена сервера", "Достигнут лимит 200,000 высоты. Чит перезаходит на новый сервер.", 16753920, {
        {["name"] = "Кругов пройдено:", ["value"] = tostring(_G.TotalRejoins), ["inline"] = true},
        {["name"] = "Всего пролетено:", ["value"] = tostring(math.floor(_G.TotalDistance)) .. " studs", ["inline"] = false}
    })

    local launchCode = [[loadstring(game:HttpGet("https://githubusercontent.com" .. tostring(math.random(1,9999))))()]]
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport)
    if qot then pcall(function() qot(launchCode) end) end
    
    task.wait(1)
    pcall(function()
        if #Players:GetPlayers() <= 1 then TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
    end)
end

-- Безопасный поиск деталей без падений и GetPivot
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
                            if dist < 200 then foundPart = pPart break end
                        end
                    end
                end
            end
        end
    end)
    return foundPart
end

-- Идеально плавный и стабильный рабочий цикл
local connection
local lastY = 0

connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then if connection then connection:Disconnect() end return end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local currentHeight = math.floor(hrp.Position.Y)
    HeightLabel.Text = "Высота Y: " .. tostring(currentHeight)

    local elapsed = os.time() - _G.SessionStartTime
    TimerLabel.Text = string.format("Время: %02d:%02d:%02d", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)

    -- Накопительный просчет расстояния
    if _G.ScriptEnabled and currentHeight > lastY then
        _G.TotalDistance = _G.TotalDistance + (currentHeight - lastY)
        DistLabel.Text = "Пролетено: " .. tostring(math.floor(_G.TotalDistance)) .. " studs"
    end
    lastY = currentHeight

    -- Лимит авто-реконнекта
    if currentHeight >= _G.MaxHeight then reconnect() return end

    if _G.ScriptEnabled then
        if character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) end

        local targetPart = findStairsPart()

        if targetPart then
            -- Остановка на найденных ступенях
            _G.ScriptEnabled = false
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 5, 0))
            
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
            ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
            StatusLabel.Text = "Найдено: " .. tostring(targetPart.Parent.Name)
            
            -- Оповещение в Discord
            sendSystemNotify("@everyone 🚨 НАЙДЕН ОБЪЕКТ НА ЛЕСТНИЦЕ! 🚨", "Скрипт успешно зафиксировал новые текстуры и остановил подъем. Срочно зайди в игру!", 65280, {
                {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "Высота Y:", ["value"] = tostring(currentHeight) .. " studs", ["inline"] = true},
                {["name"] = "Имя модели:", ["value"] = tostring(targetPart.Parent.Name), ["inline"] = false}
            })
        else
            -- Плавное смещение по вектору позиции (без лагов CFrame)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.Position = hrp.Position + Vector3.new(0, _G.ClimbSpeed * deltaTime, 0)
        end
    end
end)
