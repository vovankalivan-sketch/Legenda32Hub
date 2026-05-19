-- ForestHub Mobile v216 | Максимально простая, без глюков
-- Для Delta Client

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ГЛАВНОЕ ОКНО
local gui = Instance.new("ScreenGui")
gui.Name = "ForestHub"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then return end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(20,20,35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.Text = "🌲 ForestHub"
title.BackgroundColor3 = Color3.fromRGB(40,40,60)
title.TextColor3 = Color3.fromRGB(255,200,100)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
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

-- ПАНЕЛЬ ВКЛАДОК
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,35)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,50)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

-- КОНТЕЙНЕР ДЛЯ КОНТЕНТА (простой Frame, без ScrollingFrame)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1,0,1,-70)
contentContainer.Position = UDim2.new(0,0,0,70)
contentContainer.BackgroundColor3 = Color3.fromRGB(25,27,40)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = main

-- СОЗДАЁМ ВКЛАДКИ
local tabs = {}
local currentTab = nil

local function createTab(name, icon, yOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    -- Контент вкладки — просто Frame с кнопками
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = contentContainer
    
    -- Сдвигаем кнопки по вертикали
    local y = yOffset or 10
    
    tabs[name] = {btn = btn, content = content, y = y}
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.content.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80,100,140)
        currentTab = name
    end)
    
    return content, y
end

-- Функция добавления кнопки-переключателя
local function addToggle(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.Position = UDim2.new(0.5, -130, 0, y)
    btn.Text = text .. " [ВЫКЛ]"
    btn.BackgroundColor3 = Color3.fromRGB(40,45,65)
    btn.TextColor3 = Color3.fromRGB(220,220,240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ВКЛ]" or " [ВЫКЛ]")
        btn.BackgroundColor3 = state and Color3.fromRGB(70,130,70) or Color3.fromRGB(40,45,65)
        if callback then callback(state) end
    end)
    return btn
end

local function addSlider(parent, text, y, minVal, maxVal, defaultVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 260, 0, 20)
    label.Position = UDim2.new(0.5, -130, 0, y)
    label.Text = text .. ": " .. tostring(defaultVal)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200,200,220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = parent
    
    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(0, 260, 0, 15)
    sliderBg.Position = UDim2.new(0.5, -130, 0, y + 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,80)
    sliderBg.Text = ""
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100,180,250)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local val = defaultVal
    local drag = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    sliderBg.InputEnded:Connect(function() drag = false end)
    
    UserInputService.TouchMoved:Connect(function(input)
        if drag and sliderBg and sliderBg.AbsoluteSize.X > 0 then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            val = math.floor(minVal + (maxVal - minVal) * percent + 0.5)
            fill.Size = UDim2.new((val-minVal)/(maxVal-minVal), 0, 1, 0)
            label.Text = text .. ": " .. tostring(val)
            if callback then callback(val) end
        end
    end)
    
    return label
end

local function addDropdown(parent, text, y, options, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 160, 0, 25)
    label.Position = UDim2.new(0.5, -140, 0, y)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200,200,220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 25)
    btn.Position = UDim2.new(0.5, 40, 0, y)
    btn.Text = options[1]
    btn.BackgroundColor3 = Color3.fromRGB(60,60,85)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local current = options[1]
    btn.MouseButton1Click:Connect(function()
        local list = Instance.new("Frame")
        list.Size = UDim2.new(0, 100, 0, #options * 25)
        list.Position = UDim2.new(0.5, 40, 0, y + 25)
        list.BackgroundColor3 = Color3.fromRGB(50,50,70)
        list.BorderSizePixel = 0
        list.Parent = parent
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1,0,0,25)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(55,55,80)
            optBtn.TextColor3 = Color3.fromRGB(240,240,255)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 10
            optBtn.BorderSizePixel = 0
            optBtn.Parent = list
            optBtn.MouseButton1Click:Connect(function()
                current = opt
                btn.Text = opt
                if callback then callback(opt) end
                list:Destroy()
            end)
        end
    end)
end

-- === НАСТРОЙКИ ===
local S = {
    farm = false,
    click = false,
    fly = false,
    noclip = false,
    speed = 50,
    antiafk = true,
    bosstp = false,
    bossname = "Don Swan"
}

-- АНТИ-АФК
task.spawn(function()
    while wait(55) do
        if S.antiafk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end
    end
end)

-- АВТОФАРМ
task.spawn(function()
    while wait(0.3) do
        if S.farm and LocalPlayer.Character then
            local target = nil
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    if v.Humanoid.Health > 0 and v.Name ~= LocalPlayer.Name then
                        target = v
                        break
                    end
                end
            end
            if target then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,2,2)
                    if S.click then
                        local remote = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Combat")
                        if remote then remote:FireServer(LocalPlayer.Character.HumanoidRootPart) end
                    end
                end)
            end
        end
    end
end)

-- FLY
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

-- NOCLIP
task.spawn(function()
    while wait(0.5) do
        if S.noclip and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
            end
        end
    end
end)

-- SPEED
task.spawn(function()
    while wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = (S.fly and 16) or S.speed
        end
    end
end)

-- ТЕЛЕПОРТ К БОССУ
task.spawn(function()
    while wait(1) do
        if S.bosstp and LocalPlayer.Character then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find(S.bossname:lower()) then
                    if v:FindFirstChild("HumanoidRootPart") then
                        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame end)
                        break
                    end
                end
            end
            S.bosstp = false
        end
    end
end)

-- === СОЗДАНИЕ ВКЛАДОК И КНОПОК ===

-- Вкладка Фарм
local farmContent, fy = createTab("Фарм", "🤖", 10)
addToggle(farmContent, "Автофарм", fy, function(v) S.farm = v end)
addToggle(farmContent, "Автоклик", fy + 45, function(v) S.click = v end)

-- Вкладка Движение
local moveContent, my = createTab("Движение", "🚀", 10)
addToggle(moveContent, "Fly (WASD+Space)", my, function(v) S.fly = v end)
addToggle(moveContent, "NoClip", my + 45, function(v) S.noclip = v end)
addSlider(moveContent, "Скорость", my + 90, 16, 200, 50, function(v) S.speed = v end)

-- Вкладка Боссы
local bossContent, by = createTab("Боссы", "👑", 10)
addToggle(bossContent, "Телепорт к боссу", by, function(v) if v then S.bosstp = true end end)
addDropdown(bossContent, "Босс", by + 45, {"Don Swan","Grey Beard","Diamond","Thunder God","Darkbeard"}, function(v) S.bossname = v end)

-- Вкладка Разное
local miscContent, msy = createTab("Разное", "⚙️", 10)
addToggle(miscContent, "Anti-AFK", msy, function(v) S.antiafk = v end)

-- Выбрать первую вкладку по умолчанию
for _, v in pairs(tabs) do
    v.content.Visible = false
end
tabs["Фарм"].content.Visible = true
tabs["Фарм"].btn.BackgroundColor3 = Color3.fromRGB(80,100,140)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestHub",
        Text = "Загружен! Нажми на вкладки",
        Duration = 2
    })
end)

print("ForestHub v216 загружен | Нажми на вкладки Фарм, Движение, Боссы, Разное")
