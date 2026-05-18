-- Legenda32Hub [Pet Simulator 99 - Angel Dog Farm] | Delta Client (Safe Net Edition)
if not game:IsLoaded() then game.Loaded:Wait() end

-- Глобальные переменные сохранения статистики
if not _G.TotalRejoins then _G.TotalRejoins = 0 end
if not _G.TotalDistance then _G.TotalDistance = 0 end
if not _G.SessionStartTime then _G.SessionStartTime = os.time() end
_G.DiscordWebhookURL = "https://discord.com_" 

local scriptRunning = true
_G.ScriptEnabled = true 
_G.ClimbSpeed = 50
_G.MaxHeight = 200000 
_G.FpsBoostEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Безопасная функция отправки уведомлений (Игнорирует ошибки интернета и DnsResolve)
local function sendSystemNotify(title, desc, color, fields)
    if _G.DiscordWebhookURL and _G.DiscordWebhookURL ~= "" then
        -- Используем pcall, чтобы при ошибке интернета скрипт НЕ вылетал
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
    end
end

-- Отправка лога о запуске (Теперь абсолютно безопасная)
sendSystemNotify("🚀 Скрипт успешно перезапущен!", "Legenda32 Hub автоматически загрузился на новом сервере и начал подъем.", 3447003, {
    {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
    {["name"] = "Пройдено серверов:", ["value"] = tostring(_G.TotalRejoins), ["inline"] = true}
})

-- Встроенный Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if scriptRunning then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

-- Удаление старых копий GUI
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Legenda32Hub_Delta")
if oldGui then oldGui:Destroy() end

-- Создание интерфейса под Delta Client
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

-- Главный фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 560)
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
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "Legenda32 Hub [PRO]"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Переключатель автоматического подъема
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 220, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Авто-Подъем: ВКЛ"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

-- Мгновенный сброс под карту
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0, 220, 0, 35)
TPBtn.Position = UDim2.new(0, 20, 0, 90)
TPBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.Text = "Прыгнуть под карту"
TPBtn.Font = Enum.Font.SourceSansBold
TPBtn.TextSize = 14
TPBtn.Parent = MainFrame

-- ОПТИМИЗАЦИЯ: Boost FPS
local FpsBtn = Instance.new("TextButton")
FpsBtn.Size = UDim2.new(0, 220, 0, 35)
FpsBtn.Position = UDim2.new(0, 20, 0, 130)
FpsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsBtn.Text = "Boost FPS (Черный Экран): ВЫКЛ"
FpsBtn.Font = Enum.Font.SourceSansBold
FpsBtn.TextSize = 12
FpsBtn.Parent = MainFrame

-- Поле изменения скорости
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 220, 0, 35)
SpeedInput.Position = UDim2.new(0, 20, 0, 170)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "Скорость: " .. tostring(_G.ClimbSpeed)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 14
SpeedInput.Parent = MainFrame

-- Поле ввода Discord Webhook
local WebhookInput = Instance.new("TextBox")
WebhookInput.Size = UDim2.new(0, 220, 0, 35)
WebhookInput.Position = UDim2.new(0, 20, 0, 210)
WebhookInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WebhookInput.TextColor3 = Color3.fromRGB(150, 150, 255)
WebhookInput.PlaceholderText = "Вставь Ссылку на Discord Webhook"
WebhookInput.Text = _G.DiscordWebhookURL or ""
WebhookInput.Font = Enum.Font.SourceSans
WebhookInput.TextSize = 11
WebhookInput.Parent = MainFrame

-- КНОПКА ПРОВЕРКИ ВЕБХУКА
local TestWebhookBtn = Instance.new("TextButton")
TestWebhookBtn.Size = UDim2.new(0, 220, 0, 35)
TestWebhookBtn.Position = UDim2.new(0, 20, 0, 250)
TestWebhookBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TestWebhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestWebhookBtn.Text = "ТЕСТ ВЕБХУКА"
TestWebhookBtn.Font = Enum.Font.SourceSansBold
TestWebhookBtn.TextSize = 14
TestWebhookBtn.Parent = MainFrame

-- Кнопка полной очистки и выгрузки чита
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 220, 0, 35)
UnloadBtn.Position = UDim2.new(0, 20, 0, 290)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
UnloadBtn.Text = "ФУЛ ВЫГРУЗКА СКРИПТА"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 14
UnloadBtn.Parent = MainFrame

-- СЕКЦИЯ СТАТИСТИКИ
local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(0, 220, 0, 20)
StatsTitle.Position = UDim2.new(0, 20, 0, 335)
StatsTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
StatsTitle.Text = "--- СТАТИСТИКА ФАРМА ---"
StatsTitle.Font = Enum.Font.SourceSansBold
StatsTitle.TextSize = 13
StatsTitle.Parent = MainFrame

local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0, 220, 0, 20)
HeightLabel.Position = UDim2.new(0, 20, 0, 360)
HeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeightLabel.Text = "Текущая высота Y: 0"
HeightLabel.Font = Enum.Font.SourceSans
HeightLabel.TextSize = 13
HeightLabel.Parent = MainFrame

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0, 220, 0, 20)
TimerLabel.Position = UDim2.new(0, 20, 0, 385)
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerLabel.Text = "Время в игре: 00:00:00"
TimerLabel.Font = Enum.Font.SourceSans
TimerLabel.TextSize = 13
TimerLabel.Parent = MainFrame

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 220, 0, 20)
DistLabel.Position = UDim2.new(0, 20, 0, 410)
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistLabel.Text = "Всего пролетено: 0 studs"
DistLabel.Font = Enum.Font.SourceSans
DistLabel.TextSize = 13
DistLabel.Parent = MainFrame

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Size = UDim2.new(0, 220, 0, 20)
ServerLabel.Position = UDim2.new(0, 20, 0, 435)
ServerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerLabel.Text = "Пройдено серверов: " .. tostring(_G.TotalRejoins)
ServerLabel.Font = Enum.Font.SourceSans
ServerLabel.TextSize = 13
ServerLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 220, 0, 25)
StatusLabel.Position = UDim2.new(0, 20, 0, 465)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Статус: Авто-подъем запущен"
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

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
    task.wait(3)
    doDrop()
end)

local function unloadScript()
    scriptRunning = false _G.ScriptEnabled = false
    RunService:Set3dRenderingEnabled(true)
    sendSystemNotify("🛑 Скрипт остановлен", "Пользователь вручную нажал кнопку полной выгрузки.", 16711680, {
        {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
        {["name"] = "Пройдено серверов:", ["value"] = tostring(_G.TotalRejoins), ["inline"] = true}
    })
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    ScreenGui:Destroy()
end
UnloadBtn.MouseButton1Click:Connect(unloadScript)

TestWebhookBtn.MouseButton1Click:Connect(function()
    if not scriptRunning then return end
    local currentHeight = math.floor(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position.Y or 0)
    sendSystemNotify("🔔 Тест связи", "Твой вебхук настроен правильно и готов ловить Ангелдога.", 3447003, {
        {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
        {["name"] = "Высота Y:", ["value"] = tostring(currentHeight), ["inline"] = true}
    })
    StatusLabel.Text = "Статус: Тест отправлен в Discord!"
end)

local function reconnect()
    if not scriptRunning then return end
    _G.TotalRejoins = _G.TotalRejoins + 1
    StatusLabel.Text = "Лимит 200к! Перезаход..."
    
    sendSystemNotify("🔄 Перезаход на сервер", "Достигнут лимит высоты 200,000. Скрипт обновляет сервер для продолжения фарма.", 16753920, {
        {["name"] = "Никнейм:", ["value"] = LocalPlayer.Name, ["inline"] = true},
        {["name"] = "Всего кругов:", ["value"] = tostring(_G.TotalRejoins), ["inline"] = true},
        {["name"] = "Всего пролетено:", ["value"] = tostring(math.floor(_G.TotalDistance)) .. " studs", ["inline"] = false}
    })
    
    local launchCode = [[loadstring(game:HttpGet("https://githubusercontent.com" .. tostring(math.random(1,9999))))()]]
    if queue_on_teleport then queue_on_teleport(launchCode)
    elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(launchCode) end
    
    task.wait(1.5)
    if #Players:GetPlayers() <= 1 then TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
end

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

local connection
local lastY = 0

connection = RunService.Heartbeat:Connect(function(deltaTime)
    if not scriptRunning then if connection then connection:Disconnect() end return end

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

    if currentHeight >= _G.MaxHeight then reconnect() return end

    if _G.ScriptEnabled then
        if character:FindFirstChild("Humanoid") then character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) end

        local foundObject = findStairs()

        if foundObject then
            local bPart = Instance.new("Part")
            bPart.Size = Vector3.new(20, 1, 20) bPart.Transparency = 1 bPart.Anchored = true bPart.Parent = workspace
            
            local pCFrame = foundObject:GetPivot()
            bPart.CFrame = pCFrame + Vector3.new(0, 3, 0)
            hrp.CFrame = pCFrame + Vector3.new(0, 5, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            
            _G.ScriptEnabled = false
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
            ToggleBtn.Text = "Авто-Подъем: ВЫКЛ"
            StatusLabel.Text = "Найдено: " .. foundObject.Name
            
            sendSystemNotify("@everyone 🚨 ОБНАРУЖЕН ОБЪЕКТ НА ЛЕСТНИЦЕ! 🚨", "Скрипт зафиксировал новые текстуры и остановил подъем. Срочно зайди в игру!", 65280, {
                {["name"] = "Игрок:", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "Высота обнаружения Y:", ["value"] = tostring(currentHeight) .. " studs", ["inline"] = true},
                {["name"] = "Имя объекта:", ["value"] = tostring(foundObject.Name), ["inline"] = false}
            })
            
            task.wait(5)
            if bPart then bPart:Destroy() end
        else
            StatusLabel.Text = "Статус: Полет вверх..."
            hrp.CFrame = hrp.CFrame * CFrame.new(0, _G.ClimbSpeed * deltaTime, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
