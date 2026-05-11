-- ====================================================================
-- СВЕРХСЛОЖНАЯ ИНЖЕНЕРНАЯ СБОРКА LEGENDA32HUB С МАТРИЦЕЙ ОШИБОК
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

-- Универсальная функция логирования ошибок с жесткими кодами
local function sendHubError(funcName, errorCode, rawError)
    pcall(function()
        local descriptions = {
            [1] = "Не работает (Критический сбой потока)",
            [2] = "Ошибка патча (Сервер изменил структуру данных/объектов)",
            [3] = "Функция недоступна (Экзекутор заблокирован античитом игры)"
        }
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = string.format("[Legenda32Hub ERROR]: Функция '%s' -> Код %d: %s. Лог: %s", funcName, errorCode, descriptions[errorCode], tostring(rawError)),
            Color = Color3.fromRGB(255, 50, 50),
            Font = Enum.Font.GothamBold,
            TextSize = 13
        })
    end)
end

-- Авто-очистка при перезапуске
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubUniversal") then 
    LocalPlayer.PlayerGui.LegendaHubUniversal:Destroy() 
end

-- Инициализация глобального окружения getgenv() (15+ функций контроля)
local env = getgenv()
env.ActiveThreads = {}
env.SelectedZone = "38"

-- Переключатели функций
local flags = {
    "AutoFarm", "AutoClicker", "OrbMagnet", "InstantCollect",
    "AutoRNG", "AutoLuckyDice", "AutoUpgrades", "AutoClaimGifts",
    "AntiAfk", "FpsBoost", "Disable3DRender", "ServerHop",
    "Noclip", "InfJump", "WalkSpeedToggle"
}
for _, flag in ipairs(flags) do env[flag] = false end

-- Безопасная функция запуска фоновых процессов
local function startThread(name, loopDelay, func)
    if env.ActiveThreads[name] then return end
    env.ActiveThreads[name] = true
    task.spawn(function()
        while env[name] do
            local success, err = pcall(func)
            if not success then
                env[name] = false
                env.ActiveThreads[name] = nil
                -- Динамический анализ кода ошибки
                local code = 1
                if err:find("nil") or err:find("not found") then code = 2 end
                if err:find("allow") or err:find("security") or err:find("privilege") then code = 3 end
                sendHubError(name, code, err)
                break
            end
            task.wait(loopDelay)
        end
        env.ActiveThreads[name] = nil
    end)
end

-- ==========================================
-- ИНТЕРФЕЙС И ГЕОМЕТРИЯ ОКНА
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubUniversal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Алгоритм перемещения по дельтам (Любое сенсорное устройство)
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

local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Visible = true
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Legenda32Hub | 15+ Сборка"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Навигация
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 35)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local tabs = {"Фарм", "Эвенты", "ТП", "Игрок", "Опции"}
local tabFrames = {}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.19, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.20, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(130, 130, 140)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = TabNavFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local content = Instance.new("ScrollingFrame")
    content.Position = UDim2.new(0, 10, 0, 75)
    content.Size = UDim2.new(1, -20, 1, -85)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    content.ScrollBarThickness = 2
    content.Visible = (i == 1)
    content.Parent = MainFrame
    
    tabFrames[tabName] = content
    tabButtons[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(22, 22, 32); b.TextColor3 = Color3.fromRGB(130, 130, 140) end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
tabButtons["Фарм"].BackgroundColor3 = Color3.fromRGB(40, 40, 55)
tabButtons["Фарм"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Вспомогательная функция создания кнопок-переключателей
local btnCounter = {}
local function createToggle(tabName, flagName, labelText, callback)
    btnCounter[tabName] = (btnCounter[tabName] or 0) + 1
    local idx = btnCounter[tabName]
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (idx - 1) * 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    btn.Text = labelText .. ": ВЫКЛ"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = tabFrames[tabName]
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        env[flagName] = not env[flagName]
        if env[flagName] then
            btn.Text = labelText .. ": ВКЛ"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.BackgroundColor3 = Color3.fromRGB(25, 40, 25)
        else
            btn.Text = labelText .. ": ВЫКЛ"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        end
        callback(env[flagName])
    end)
end

-- ==========================================
-- РЕАЛИЗАЦИЯ 15+ ИНЖЕНЕРНЫХ ФУНКЦИЙ
-- ==========================================

-- Вкладка: Фарм
createToggle("Фарм", "AutoFarm", "1. Пушечный Удержатель", function(state)
    if state then startThread("AutoFarm", 0.5, function()
        local net = ReplicatedStorage:FindFirstChild("Network")
        local remote = net and (net:FindFirstChild("Cannons_Fire") or net:FindFirstChild("Cannon_Fire"))
        if not remote then error("Папка Network повреждена") end
        remote:InvokeServer("Area " .. tostring(env.SelectedZone))
    end) end
end)

createToggle("Фарм", "AutoClicker", "2. Авто-Кликер по кубам", function(state)
    if state then startThread("AutoClicker", 0.05, function()
        local vu = game:GetService("VirtualUser")
        vu:Button1Down(Vector2.new(100, 100), workspace.CurrentCamera.CFrame)
    end) end
end)

createToggle("Фарм", "OrbMagnet", "3. Физический Магнит", function(state)
    if state then startThread("OrbMagnet", 0.2, function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                    obj.CFrame = root.CFrame
                end
            end
        end
    end) end
end)

createToggle("Фарм", "InstantCollect", "4. Пакетный сбор сфер", function(state)
    if state then startThread("InstantCollect", 0.3, function()
        local net = ReplicatedStorage:FindFirstChild("Network")
        local claim = net and (net:FindFirstChild("Orbs_Claim") or net:FindFirstChild("Orbs:Claim"))
        if claim then
            local orbIds = {}
            local orbsFolder = Workspace:FindFirstChild("Network") and Workspace.Network:FindFirstChild("Orbs")
            if orbsFolder then
                for _, o in ipairs(orbsFolder:GetChildren()) do table.insert(orbIds, o.Name) end
                if #orbIds > 0 then claim:FireServer(orbIds) end
            end
        end
    end) end
end)

-- Вкладка: Эвенты
createToggle("Эвенты", "AutoRNG", "5. Авто RNG Крутилка", function(state)
    if state then startThread("AutoRNG", 0.1, function()
        local net = ReplicatedStorage.Network
        local roll = net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll")
        if roll then roll:InvokeServer() end
    end) end
end)

createToggle("Эвенты", "AutoLuckyDice", "6. Авто-Крафт кубиков", function(state)
    if state then startThread("AutoLuckyDice", 1, function()
        local net = ReplicatedStorage.Network
        local craft = net:FindFirstChild("RNG_CraftDice") or net:FindFirstChild("RNG_LuckyDice_Upgrade")
        if craft then craft:InvokeServer("Lucky Dice", 1) end
    end) end
end)

createToggle("Эвенты", "AutoUpgrades", "7. Авто-Покупка RNG баффов", function(state)
    if state then startThread("AutoUpgrades", 2, function()
        local net = ReplicatedStorage.Network
        local upg = net:FindFirstChild("RNG_PurchaseUpgrade")
        if upg then upg:InvokeServer("Roll Speed", 1) end
    end) end
end)

createToggle("Эвенты", "AutoClaimGifts", "8. Авто-Сбор подарков", function(state)
    if state then startThread("AutoClaimGifts", 5, function()
        local net = ReplicatedStorage.Network
        local claim = net:FindFirstChild("Rewards_ClaimGifts") or net:FindFirstChild("FreeRewards_Claim")
        if claim then for i = 1, 12 do claim:FireServer(i) end end
    end) end
end)

-- Вкладка: ТП
local zones = {"1", "10", "20", "30", "38", "50"}
for i, zName in ipairs(zones) do
    btnCounter["ТП"] = (btnCounter["ТП"] or 0) + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (btnCounter["ТП"] - 1) * 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = "9. Выстрел из пушки в Зону " .. zName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = tabFrames["ТП"]
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        env.SelectedZone = zName
        local success, err = pcall(function()
            ReplicatedStorage.Network.Cannons_Fire:InvokeServer("Area " .. zName)
        end)
        if not success then sendHubError("CannonTeleport", 2, err) end
    end)
end

-- Вкладка: Игрок
createToggle("Игрок", "AntiAfk", "10. Защита от вылета (Анти-АФК)", function(state)
    if state then
        env.AntiAfkConnection = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0))
        end)
    else
        if env.AntiAfkConnection then env.AntiAfkConnection:Disconnect() end
    end
end)

createToggle("Игрок", "Noclip", "11. Проход сквозь стены (Noclip)", function(state)
    if state then
        env.NoclipLoop = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if env.NoclipLoop then env.NoclipLoop:Disconnect() end
    end
end)

createToggle("Игрок", "InfJump", "12. Бесконечные прыжки", function(state)
    if state then
        env.InfJumpLoop = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end)
    else
        if env.InfJumpLoop then env.InfJumpLoop:Disconnect() end
    end
end)

-- Вкладка: Опции (Оптимизация систем)
createToggle("Опции", "FpsBoost", "13. Очистить текстуры (FPS Boost)", function(state)
    if state then pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end) end
end)

createToggle("Опции", "Disable3DRender", "14. Отключить 3D Рендер экрана", function(state)
    game:GetService("RunService"):Set3DRenderEnabled(not state)
end)

createToggle("Опции", "RGB_Enabled", "15. Переливающийся RGB режим", function(state) end)

RunService.RenderStepped:Connect(function()
    if env.RGB_Enabled then
        local color = Color3.fromHSV((tick() % 4)/4, 1, 1)
        Title.TextColor3 = color; ToggleButton.TextColor3 = color
    end
end)

-- Дополнительная кнопка уничтожения
btnCounter["Опции"] = btnCounter["Опции"] + 1
local ShutdownBtn = Instance.new("TextButton")
ShutdownBtn.Size = UDim2.new(1, -6, 0, 35)
ShutdownBtn.Position = UDim2.new(0, 0, 0, (btnCounter["Опции"] - 1) * 36)
ShutdownBtn.BackgroundColor3 = Color3.fromRGB(70, 20, 20)
ShutdownBtn.Text = "ПОЛНОСТЬЮ УДАЛИТЬ ХАБ"
ShutdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShutdownBtn.Font = Enum.Font.GothamBold; ShutdownBtn.TextSize = 11; ShutdownBtn.Parent = tabFrames["Опции"]
Instance.new("UICorner", ShutdownBtn).CornerRadius = UDim.new(0, 5)

ShutdownBtn.MouseButton1Click:Connect(function()
    for _, flag in ipairs(flags) do env[flag] = false end
    game:GetService("RunService"):Set3DRenderEnabled(true)
    if env.NoclipLoop then env.NoclipLoop:Disconnect() end
    if env.InfJumpLoop then env.InfJumpLoop:Disconnect() end
    if env.AntiAfkConnection then env.AntiAfkConnection:Disconnect() end
    ScreenGui:Destroy()
end)

-- Финальный отчет об успешной загрузке
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Сборка 15+ успешно скомпилирована. Архитектура игры просканирована.",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
