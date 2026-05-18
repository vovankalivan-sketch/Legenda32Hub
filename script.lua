-- ForestHub Mobile v210 | Redz Hub Clone + Key System
-- КЛЮЧ: Forest (регистр важен!)
-- Для Delta Client на телефоне | Оптимизирован | Красивое меню

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-- ========== СИСТЕМА КЛЮЧА ==========
local CORRECT_KEY = "Forest" -- Ключ (регистр важен: F заглавная, остальные строчные)
local keyVerified = false

-- Функция запроса ключа
local function requestKey()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSize = 0
    frame.Parent = keyGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🔑 ForestHub | Введите ключ"
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    textBox.PlaceholderText = "Введите ключ..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Parent = frame
    
    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0.4, 0, 0, 35)
    enterBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
    enterBtn.Text = "Войти"
    enterBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 14
    enterBtn.BorderSize = 0
    enterBtn.Parent = frame
    
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, 0, 0, 20)
    message.Position = UDim2.new(0, 0, 1, -25)
    message.Text = ""
    message.BackgroundTransparency = 1
    message.TextColor3 = Color3.fromRGB(255, 100, 100)
    message.Font = Enum.Font.Gotham
    message.TextSize = 11
    message.Parent = frame
    
    local function verify()
        local input = textBox.Text
        if input == CORRECT_KEY then
            keyVerified = true
            message.Text = "✅ Ключ принят!"
            message.TextColor3 = Color3.fromRGB(100, 255, 100)
            wait(0.5)
            keyGui:Destroy()
        else
            message.Text = "❌ Неверный ключ. Попробуйте ещё раз."
            message.TextColor3 = Color3.fromRGB(255, 100, 100)
            textBox.Text = ""
        end
    end
    
    enterBtn.MouseButton1Click:Connect(verify)
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then verify() end
    end)
    
    -- Блокировка закрытия
    frame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not frame.Visible then
            if not keyVerified then
                frame.Visible = true
            end
        end
    end)
    
    repeat wait() until keyVerified
end

-- Запрашиваем ключ
requestKey()

-- Дальше идёт основной GUI (только если ключ верный)
-- [ВСЁ ОСТАЛЬНОЕ, ЧТО БЫЛО В ПРЕДЫДУЩЕМ СКРИПТЕ, ВСТАВЛЯЕТСЯ СЮДА]
-- Я приведу полный код целиком ниже, чтобы ты просто скопировал

-- ========== GUI БИБЛИОТЕКА (та же самая) ==========
local Library = {}
do
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ForestHub_Mobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSize = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Далее весь код GUI из прошлой версии (копирую компактно)
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = game:GetService("Lighting")
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
    TitleBar.BorderSize = 0
    TitleBar.Parent = MainFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.Text = "🌲 ForestHub Mobile | Key: Forest"
    TitleText.TextColor3 = Color3.fromRGB(255, 200, 100)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.BackgroundTransparency = 1
    TitleText.Parent = TitleBar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.2)
        MainFrame.Visible = false
        Blur.Size = 0
    end)
    
    -- Drag (упрощённо для телефона)
    local DragButton = Instance.new("TextButton")
    DragButton.Size = UDim2.new(1, -40, 1, 0)
    DragButton.BackgroundTransparency = 1
    DragButton.Parent = TitleBar
    local dragging = false
    local dragStart = nil
    local startPos = nil
    DragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    DragButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.TouchMoved:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
    TabContainer.BorderSize = 0
    TabContainer.Parent = MainFrame
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -85)
    Content.Position = UDim2.new(0, 0, 0, 85)
    Content.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
    Content.BorderSize = 0
    Content.Parent = MainFrame
    
    Library.Tabs = {}
    Library.CurrentTab = nil
    
    function Library:CreateTab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 70, 1, 0)
        TabBtn.Text = icon .. " " .. name
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 220)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        TabBtn.BorderSize = 0
        TabBtn.Parent = TabContainer
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        TabContent.Parent = Content
        TabContent.Visible = false
        
        local UIList = Instance.new("UIListLayout")
        UIList.Padding = UDim.new(0, 8)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Parent = TabContent
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Library.Tabs) do
                v.Content.Visible = false
                TweenService:Create(v.Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 28, 40)}):Play()
            end
            TabContent.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 100, 150)}):Play()
            Library.CurrentTab = name
        end)
        
        Library.Tabs[name] = {Button = TabBtn, Content = TabContent, UIList = UIList}
        if not Library.CurrentTab then TabBtn.MouseButton1Click:Fire() end
        return TabContent
    end
    
    function Library:CreateToggle(parent, text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -16, 0, 40)
        frame.Position = UDim2.new(0, 8, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
        frame.BorderSize = 0
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(230, 230, 250)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 24)
        toggle.Position = UDim2.new(1, -58, 0.5, -12)
        toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 130)
        toggle.Text = ""
        toggle.BorderSize = 0
        toggle.Parent = frame
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = UDim2.new(0, 2, 0.5, -10)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSize = 0
        circle.Parent = toggle
        
        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            local targetColor = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 130)
            local circlePos = state and UDim2.new(0, 28, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            TweenService:Create(toggle, TweenInfo.new(0.1), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(circle, TweenInfo.new(0.1), {Position = circlePos}):Play()
            if callback then callback(state) end
        end)
        return toggle
    end
    
    function Library:CreateSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -16, 0, 70)
        frame.Position = UDim2.new(0, 8, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
        frame.BorderSize = 0
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = text .. ": " .. tostring(default)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(230, 230, 250)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = frame
        
        local sliderBg = Instance.new("TextButton")
        sliderBg.Size = UDim2.new(1, -20, 0, 20)
        sliderBg.Position = UDim2.new(0, 10, 0, 35)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        sliderBg.Text = ""
        sliderBg.BorderSize = 0
        sliderBg.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 180, 250)
        fill.BorderSize = 0
        fill.Parent = sliderBg
        
        local value = default
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        sliderBg.InputEnded:Connect(function(input)
            dragging = false
        end)
        UserInputService.TouchMoved:Connect(function(input)
            if dragging and sliderBg then
                local pos = input.Position.X - sliderBg.AbsolutePosition.X
                local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * percent + 0.5)
                fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                label.Text = text .. ": " .. tostring(value)
                if callback then callback(value) end
            end
        end)
        return sliderBg
    end
    
    function Library:CreateDropdown(parent, text, options, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -16, 0, 45)
        frame.Position = UDim2.new(0, 8, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
        frame.BorderSize = 0
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(230, 230, 250)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -10, 0.7, 0)
        btn.Position = UDim2.new(0.5, 10, 0.15, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        btn.Text = options[1]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSize = 0
        btn.Parent = frame
        
        local current = options[1]
        btn.MouseButton1Click:Connect(function()
            local list = Instance.new("Frame")
            list.Size = UDim2.new(0.5, -10, 0, #options * 30)
            list.Position = UDim2.new(0.5, 10, 1, 0)
            list.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            list.BorderSize = 0
            list.Parent = frame
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.Text = opt
                optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                optBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
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
        return btn
    end
    
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 350, 0, 500)}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.2), {Size = 12}):Play()
end

-- ========== ОСНОВНЫЕ ФУНКЦИИ (те же самые) ==========
local Settings = {
    AutoFarm = false,
    AutoClick = false,
    AutoSkill = false,
    AutoCollect = false,
    Fly = false,
    NoClip = false,
    Speed = 50,
    AntiAFK = true,
    TeleportToBoss = false,
    BossName = "Don Swan"
}

task.spawn(function()
    while wait(55) do
        if Settings.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end
    end
end)

task.spawn(function()
    while wait(0.3) do
        if Settings.AutoFarm then
            local target = nil
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Y > -50 then
                    target = v
                    break
                end
            end
            if target and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 2)
                if Settings.AutoClick then
                    game:GetService("ReplicatedStorage").Remotes.Combat:FireServer(LocalPlayer.Character.HumanoidRootPart)
                end
            end
        end
    end
end)

local flyActive = false
local bodyVel, bodyGyro
task.spawn(function()
    while wait(0.1) do
        if Settings.Fly and not flyActive then
            flyActive = true
            local char = LocalPlayer.Character
            if char then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyVel.Parent = char.HumanoidRootPart
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                bodyGyro.Parent = char.HumanoidRootPart
            end
        elseif not Settings.Fly and flyActive then
            flyActive = false
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
        if flyActive and bodyVel and LocalPlayer.Character then
            local cam = workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            bodyVel.Velocity = move.Unit * (Settings.Speed or 50)
            bodyGyro.CFrame = cam.CFrame
        end
    end
end)

task.spawn(function()
    while wait(0.5) do
        if Settings.NoClip and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    while wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Fly and 16 or (Settings.Speed or 16)
        end
    end
end)

-- GUI построение
local main = Library:CreateTab("Главная", "🤖")
Library:CreateToggle(main, "Автофарм (враги)", function(v) Settings.AutoFarm = v end)
Library:CreateToggle(main, "Автоклик", function(v) Settings.AutoClick = v end)
Library:CreateToggle(main, "Автоскилл (1 кнопка)", function(v) Settings.AutoSkill = v end)
Library:CreateToggle(main, "Автосбор фруктов", function(v) Settings.AutoCollect = v end)

local move = Library:CreateTab("Движение", "🚀")
Library:CreateToggle(move, "Fly (WASD+Space)", function(v) Settings.Fly = v end)
Library:CreateToggle(move, "NoClip", function(v) Settings.NoClip = v end)
Library:CreateSlider(move, "Скорость ходьбы", 16, 250, 50, function(v) Settings.Speed = v end)

local tele = Library:CreateTab("Телепорты", "🌎")
Library:CreateToggle(tele, "Телепорт к боссу", function(v)
    if v then
        local boss = workspace.Enemies:FindFirstChild(Settings.BossName)
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame
        end
    end
end)
Library:CreateDropdown(tele, "Выбрать босса", {"Don Swan","Grey Beard","Diamond","Thunder God","Darkbeard"}, function(v) Settings.BossName = v end)

local misc = Library:CreateTab("Разное", "⚙️")
Library:CreateToggle(misc, "Anti-AFK", function(v) Settings.AntiAFK = v end)

print("🌲 ForestHub Mobile v210 загружен | Ключ: Forest | Redz Hub стиль")
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "ForestHub Mobile",
    Text = "Ключ принят! Добро пожаловать.",
    Duration = 3
})
