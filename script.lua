-- ForestHub Mobile v215 | Без ключа, без анимаций, без ошибок
-- Для Delta Client на телефон

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- === ГЛАВНОЕ МЕНЮ ===
local gui = Instance.new("ScreenGui")
gui.Name = "ForestHub"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
    pcall(function() gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui end)
end
if not gui.Parent then return end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 350)
main.Position = UDim2.new(0.5, -140, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25,25,40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Text = "🌲 ForestHub Mobile"
title.BackgroundColor3 = Color3.fromRGB(40,40,60)
title.TextColor3 = Color3.fromRGB(255,180,80)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.BorderSizePixel = 0
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,1,0)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,100,100)
close.BackgroundTransparency = 1
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.BorderSizePixel = 0
close.Parent = title
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,30)
tabBar.Position = UDim2.new(0,0,0,30)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,50)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1,0,1,-60)
content.Position = UDim2.new(0,0,0,60)
content.BackgroundColor3 = Color3.fromRGB(20,20,35)
content.BorderSizePixel = 0
content.Parent = main

local tabs = {}
local currentTab = nil

local function addTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    local panel = Instance.new("ScrollingFrame")
    panel.Size = UDim2.new(1,0,1,0)
    panel.BackgroundTransparency = 1
    panel.ScrollBarThickness = 2
    panel.BorderSizePixel = 0
    panel.Parent = content
    panel.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = panel
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.panel.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
        end
        panel.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80,100,140)
        currentTab = name
    end)
    
    tabs[name] = {btn = btn, panel = panel, layout = layout}
    if not currentTab then btn.MouseButton1Click:Fire() end
    return panel
end

local function addToggle(parent, text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 32)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(35,37,50)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.BorderSizePixel = 0
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 22)
    b.Position = UDim2.new(1, -45, 0.5, -11)
    b.BackgroundColor3 = Color3.fromRGB(80,80,110)
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = f
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(70,180,70) or Color3.fromRGB(80,80,110)
        if callback then callback(state) end
    end)
end

local function addSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 55)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(35,37,50)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,18)
    l.Text = text .. ": " .. tostring(defaultVal)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.BorderSizePixel = 0
    l.Parent = f
    
    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(1, -20, 0, 14)
    bg.Position = UDim2.new(0, 10, 0, 32)
    bg.BackgroundColor3 = Color3.fromRGB(55,55,75)
    bg.Text = ""
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100,160,230)
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

local function addDropdown(parent, text, options, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 38)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(35,37,50)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.45, 0, 1, 0)
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.BorderSizePixel = 0
    l.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -5, 0.7, 0)
    btn.Position = UDim2.new(0.5, 5, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,85)
    btn.Text = options[1]
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = f
    
    local current = options[1]
    btn.MouseButton1Click:Connect(function()
        local list = Instance.new("Frame")
        list.Size = UDim2.new(0.5, -5, 0, #options * 24)
        list.Position = UDim2.new(0.5, 5, 1, 0)
        list.BackgroundColor3 = Color3.fromRGB(50,50,70)
        list.BorderSizePixel = 0
        list.Parent = f
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 24)
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

-- Анти-АФК
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

-- Автофарм + автоклик
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

-- NoClip
task.spawn(function()
    while wait(0.5) do
        if S.noclip and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
            end
        end
    end
end)

-- Speed
task.spawn(function()
    while wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = (S.fly and 16) or S.speed
        end
    end
end)

-- Телепорт к боссу
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

-- === СОЗДАНИЕ ВКЛАДОК ===
local t1 = addTab("Фарм", "🤖")
addToggle(t1, "Автофарм", function(v) S.farm = v end)
addToggle(t1, "Автоклик", function(v) S.click = v end)

local t2 = addTab("Движение", "🚀")
addToggle(t2, "Fly", function(v) S.fly = v end)
addToggle(t2, "NoClip", function(v) S.noclip = v end)
addSlider(t2, "Скорость", 16, 200, 50, function(v) S.speed = v end)

local t3 = addTab("Боссы", "👑")
addToggle(t3, "Телепорт к боссу", function(v) if v then S.bosstp = true end end)
addDropdown(t3, "Босс", {"Don Swan","Grey Beard","Diamond","Thunder God","Darkbeard"}, function(v) S.bossname = v end)

local t4 = addTab("Разное", "⚙️")
addToggle(t4, "Anti-AFK", function(v) S.antiafk = v end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestHub",
        Text = "Загружен!",
        Duration = 2
    })
end)

print("ForestHub v215 загружен | Без ключа")
