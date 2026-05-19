-- ForestPS99 v2.1 | Телефон-фикс | Delta Client
-- Ручное позиционирование, без ScrollingFrame

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ForestPS99"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
    pcall(function() gui.Parent = LocalPlayer.PlayerGui end)
end
if not gui.Parent then return end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 420)
main.Position = UDim2.new(0.5, -150, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(20,20,40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.Text = "🐾 ForestPS99 v2.1 | Телефон"
title.BackgroundColor3 = Color3.fromRGB(40,40,65)
title.TextColor3 = Color3.fromRGB(255,200,100)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.BorderSizePixel = 0
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,35,1,0)
close.Position = UDim2.new(1,-35,0,0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,100,100)
close.BackgroundTransparency = 1
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.BorderSizePixel = 0
close.Parent = title
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Панель вкладок
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,35)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,55)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

-- Контейнер для содержимого (простой Frame)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1,0,1,-70)
contentContainer.Position = UDim2.new(0,0,0,70)
contentContainer.BackgroundColor3 = Color3.fromRGB(25,27,45)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = main

-- Хранилище вкладок
local tabs = {}
local currentTab = nil

-- Функция создания вкладки (с ручным управлением видимостью)
local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,60)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    -- Контейнер для кнопок этой вкладки (простой Frame)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1,0,1,0)
    panel.BackgroundTransparency = 1
    panel.Visible = false
    panel.Parent = contentContainer
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.panel.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(35,35,60)
        end
        panel.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(90,110,160)
        currentTab = name
    end)
    
    tabs[name] = {btn = btn, panel = panel}
    return panel
end

-- Функция добавления кнопки-тумблера (ручной Y)
local function addToggle(parent, text, y, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 36)
    f.Position = UDim2.new(0.5, -130, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(35,37,55)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.BorderSizePixel = 0
    l.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -55, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,110)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = f
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(70,180,70) or Color3.fromRGB(80,80,110)
        if callback then callback(state) end
    end)
end

-- Функция добавления слайдера
local function addSlider(parent, text, y, minVal, maxVal, defaultVal, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 60)
    f.Position = UDim2.new(0.5, -130, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(35,37,55)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20)
    l.Text = text .. ": " .. tostring(defaultVal)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.BorderSizePixel = 0
    l.Parent = f
    
    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(1, -20, 0, 16)
    bg.Position = UDim2.new(0, 10, 0, 35)
    bg.BackgroundColor3 = Color3.fromRGB(55,55,80)
    bg.Text = ""
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100,180,250)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local val = defaultVal
    local drag = false
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    bg.InputEnded:Connect(function() drag = false end)
    
    UserInputService.TouchMoved:Connect(function(input)
        if drag and bg and bg.AbsoluteSize.X > 0 then
            local percent = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.floor(minVal + (maxVal - minVal) * percent + 0.5)
            fill.Size = UDim2.new((val-minVal)/(maxVal-minVal), 0, 1, 0)
            l.Text = text .. ": " .. tostring(val)
            if callback then callback(val) end
        end
    end)
end

-- ========== НАСТРОЙКИ ==========
local S = {
    autoBreak = false,
    autoCollect = false,
    autoOpenEggs = false,
    autoUpgrade = false,
    fly = false,
    speed = 50
}

-- ========== ФУНКЦИИ ==========
task.spawn(function()
    while wait(0.2) do
        if S.autoBreak and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("BreakBlock")
                    if remote then remote:FireServer(tool, CFrame.new()) end
                end)
            end
        end
    end
end)

task.spawn(function()
    while wait(0.3) do
        if S.autoCollect then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("coin") or v.Name:lower():find("diamond") or v.Name:lower():find("chest")) then
                    local part = v:FindFirstChild("Part") or v:FindFirstChild("HumanoidRootPart")
                    if part then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                        end)
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while wait(0.5) do
        if S.autoOpenEggs then
            local egg = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if egg and egg:FindFirstChild("ClickDetector") then
                pcall(function() egg.ClickDetector:Click() end)
            end
        end
    end
end)

task.spawn(function()
    while wait(1) do
        if S.autoUpgrade then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("upgrade") or v.Name:lower():find("rebirth")) then
                    if v:FindFirstChild("ClickDetector") then
                        pcall(function() v.ClickDetector:Click() end)
                    end
                end
            end
        end
    end
end)

-- Fly
local flyActive = false
local bv, bg
task.spawn(function()
    while wait(0.1) do
        if S.fly and not flyActive then
            flyActive = true
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Parent = c.HumanoidRootPart
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                bg.Parent = c.HumanoidRootPart
            end
        elseif not S.fly and flyActive then
            flyActive = false
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        if flyActive and bv and LocalPlayer.Character then
            pcall(function()
                local cam = workspace.CurrentCamera
                local move = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                bv.Velocity = move.Unit * S.speed
                bg.CFrame = cam.CFrame
            end)
        end
    end
end)

-- Анти-АФК
task.spawn(function()
    while wait(55) do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
    end
end)

-- ========== СОЗДАНИЕ ВКЛАДОК (ручные Y) ==========
local farmPanel = createTab("Фарм", "⚡")
addToggle(farmPanel, "Авто-ломание", 10, function(v) S.autoBreak = v end)
addToggle(farmPanel, "Авто-сбор монет", 55, function(v) S.autoCollect = v end)
addToggle(farmPanel, "Авто-открытие яиц", 100, function(v) S.autoOpenEggs = v end)
addToggle(farmPanel, "Авто-апгрейд", 145, function(v) S.autoUpgrade = v end)

local movePanel = createTab("Движение", "🚀")
addToggle(movePanel, "Fly (WASD+Space)", 10, function(v) S.fly = v end)
addSlider(movePanel, "Скорость", 60, 20, 200, 70, function(v) S.speed = v end)

-- Активация первой вкладки
tabs["Фарм"].btn.MouseButton1Click:Fire()

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestPS99",
        Text = "Телефон-версия | Вкладки работают",
        Duration = 3
    })
end)

print("ForestPS99 v2.1 | Вкладки: Фарм и Движение")
