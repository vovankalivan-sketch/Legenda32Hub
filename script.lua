-- ForestHub Mobile v212 | Без анимаций, без MeshContentProvider ошибок
-- КЛЮЧ: Forest

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== КЛЮЧ ==========
local CORRECT_KEY = "Forest"
local keyVerified = false

local function requestKey()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 150)
    frame.Position = UDim2.new(0.5, -130, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSize = 0
    frame.Parent = keyGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "Введите ключ"
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 30)
    textBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    textBox.PlaceholderText = "Ключ..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Parent = frame
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0.4, 0, 0, 30)
    enterBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
    enterBtn.Text = "Войти"
    enterBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 14
    enterBtn.BorderSize = 0
    enterBtn.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 20)
    msg.Position = UDim2.new(0, 0, 1, -20)
    msg.Text = ""
    msg.BackgroundTransparency = 1
    msg.TextColor3 = Color3.fromRGB(255, 100, 100)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 11
    msg.Parent = frame
    
    enterBtn.MouseButton1Click:Connect(function()
        if textBox.Text == CORRECT_KEY then
            keyVerified = true
            msg.Text = "✅"
            wait(0.3)
            keyGui:Destroy()
        else
            msg.Text = "❌ Неверно"
            textBox.Text = ""
        end
    end)
    
    repeat wait() until keyVerified
end

requestKey()

-- ========== GUI (без анимаций, без эффектов) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ForestHub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BorderSize = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Text = "🌲 ForestHub | Key: Forest"
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
titleBar.TextColor3 = Color3.fromRGB(255, 200, 100)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 13
titleBar.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
tabBar.BorderSize = 0
tabBar.Parent = mainFrame

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, -65)
contentArea.Position = UDim2.new(0, 0, 0, 65)
contentArea.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
contentArea.BorderSize = 0
contentArea.Parent = mainFrame

local tabs = {}
local currentTab = nil

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSize = 0
    btn.Parent = tabBar
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.Parent = contentArea
    content.Visible = false
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.content.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80, 100, 140)
        currentTab = name
    end)
    
    tabs[name] = {btn = btn, content = content, list = list}
    if not currentTab then btn.MouseButton1Click:Fire() end
    return content
end

local function addToggle(parent, text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 32)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    f.BorderSize = 0
    f.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.Position = UDim2.new(1, -45, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
    btn.Text = ""
    btn.BorderSize = 0
    btn.Parent = f
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(80, 80, 110)
        if callback then callback(state) end
    end)
end

local function addSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 60)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    f.BorderSize = 0
    f.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. tostring(default)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = f
    
    local sliderBg = Instance.new("TextButton")
    sliderBg.Size = UDim2.new(1, -20, 0, 15)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderBg.Text = ""
    sliderBg.BorderSize = 0
    sliderBg.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 160, 230)
    fill.BorderSize = 0
    fill.Parent = sliderBg
    
    local value = default
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderBg.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.TouchMoved:Connect(function(input)
        if dragging and sliderBg and sliderBg.AbsoluteSize.X > 0 then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * percent + 0.5)
            fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)
end

local function addDropdown(parent, text, options, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.Position = UDim2.new(0, 5, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
    f.BorderSize = 0
    f.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -5, 0.7, 0)
    btn.Position = UDim2.new(0.5, 5, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
    btn.Text = options[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSize = 0
    btn.Parent = f
    
    local current = options[1]
    btn.MouseButton1Click:Connect(function()
        local list = Instance.new("Frame")
        list.Size = UDim2.new(0.5, -5, 0, #options * 26)
        list.Position = UDim2.new(0.5, 5, 1, 0)
        list.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        list.BorderSize = 0
        list.Parent = f
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
            optBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 10
            optBtn.BorderSize = 0
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

-- ========== НАСТРОЙКИ И ФУНКЦИИ ==========
local Settings = {
    AutoFarm = false,
    AutoClick = false,
    Fly = false,
    NoClip = false,
    Speed = 50,
    AntiAFK = true,
    BossTP = false,
    BossName = "Don Swan"
}

-- Анти-АФК
task.spawn(function()
    while wait(50) do
        if Settings.AntiAFK then
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
        if Settings.AutoFarm and LocalPlayer.Character then
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
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2)
                    if Settings.AutoClick then
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
        if Settings.Fly and not flyActive then
            flyActive = true
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Parent = char.HumanoidRootPart
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.Parent = char.HumanoidRootPart
            end
        elseif not Settings.Fly and flyActive then
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
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                bv.Velocity = move.Unit * Settings.Speed
                bg.CFrame = cam.CFrame
            end)
        end
    end
end)

-- NoClip
task.spawn(function()
    while wait(0.5) do
        if Settings.NoClip and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end
end)

-- Speed
task.spawn(function()
    while wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = (Settings.Fly and 16) or Settings.Speed
        end
    end
end)

-- Телепорт к боссу
task.spawn(function()
    while wait(1) do
        if Settings.BossTP and LocalPlayer.Character then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find(Settings.BossName:lower()) then
                    if v:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        end)
                        break
                    end
                end
            end
            Settings.BossTP = false
        end
    end
end)

-- ========== ПОСТРОЕНИЕ ВКЛАДОК ==========
local mainTab = createTab("Фарм", "🤖")
addToggle(mainTab, "Автофарм", function(v) Settings.AutoFarm = v end)
addToggle(mainTab, "Автоклик", function(v) Settings.AutoClick = v end)

local moveTab = createTab("Движение", "🚀")
addToggle(moveTab, "Fly", function(v) Settings.Fly = v end)
addToggle(moveTab, "NoClip", function(v) Settings.NoClip = v end)
addSlider(moveTab, "Скорость", 16, 200, 50, function(v) Settings.Speed = v end)

local bossTab = createTab("Боссы", "👑")
addToggle(bossTab, "Телепорт к боссу", function(v) 
    if v then Settings.BossTP = true end
end)
addDropdown(bossTab, "Выбор босса", {"Don Swan", "Grey Beard", "Diamond", "Thunder God", "Darkbeard"}, function(v)
    Settings.BossName = v
end)

local miscTab = createTab("Разное", "⚙️")
addToggle(miscTab, "Anti-AFK", function(v) Settings.AntiAFK = v end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestHub",
        Text = "Готово! Без ошибок.",
        Duration = 2
    })
end)

print("ForestHub v212 загружен | Ключ: Forest")
