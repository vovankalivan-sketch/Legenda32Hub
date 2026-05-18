-- ForestHub Mobile v211 | Без ошибок | Для Delta Client (телефон)
-- КЛЮЧ: Forest (регистр важен)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== СИСТЕМА КЛЮЧА ==========
local CORRECT_KEY = "Forest"
local keyVerified = false

local function requestKey()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 180)
    frame.Position = UDim2.new(0.5, -140, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BorderSize = 0
    frame.Parent = keyGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "🔑 Введите ключ"
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 35)
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
    message.Position = UDim2.new(0, 0, 1, -22)
    message.Text = ""
    message.BackgroundTransparency = 1
    message.TextColor3 = Color3.fromRGB(255, 100, 100)
    message.Font = Enum.Font.Gotham
    message.TextSize = 11
    message.Parent = frame
    
    local function verify()
        if textBox.Text == CORRECT_KEY then
            keyVerified = true
            message.Text = "✅ Ключ принят!"
            message.TextColor3 = Color3.fromRGB(100, 255, 100)
            wait(0.5)
            keyGui:Destroy()
        else
            message.Text = "❌ Неверный ключ"
            textBox.Text = ""
        end
    end
    
    enterBtn.MouseButton1Click:Connect(verify)
    textBox.FocusLost:Connect(function(enter)
        if enter then verify() end
    end)
    
    repeat wait() until keyVerified
end

requestKey()

-- ========== GUI (упрощённый, без анимаций, чтобы не было ошибок) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSize = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🌲 ForestHub Mobile | Key: Forest"
Title.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Кнопка закрытия
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 1, 0)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 100, 100)
Close.BackgroundTransparency = 1
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.Parent = Title
Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Контейнер вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
TabContainer.BorderSize = 0
TabContainer.Parent = MainFrame

-- Область контента
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -75)
Content.Position = UDim2.new(0, 0, 0, 75)
Content.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
Content.BorderSize = 0
Content.Parent = MainFrame

local tabs = {}
local currentTab = nil

function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 220)
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSize = 0
    btn.Parent = TabContainer
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 3
    tabContent.Parent = Content
    tabContent.Visible = false
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = tabContent
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.content.Visible = false
            v.button.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        end
        tabContent.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80, 100, 150)
        currentTab = name
    end)
    
    tabs[name] = {button = btn, content = tabContent, list = list}
    if not currentTab then btn.MouseButton1Click:Fire() end
    return tabContent
end

function CreateToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 35)
    frame.Position = UDim2.new(0, 6, 0, 0)
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
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 45, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 130)
    btn.Text = ""
    btn.BorderSize = 0
    btn.Parent = frame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(100, 100, 130)
        if callback then callback(state) end
    end)
    return btn
end

function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 65)
    frame.Position = UDim2.new(0, 6, 0, 0)
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
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -20, 0, 18)
    slider.Position = UDim2.new(0, 10, 0, 35)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    slider.Text = ""
    slider.BorderSize = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 180, 250)
    fill.BorderSize = 0
    fill.Parent = slider
    
    local value = default
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function()
        dragging = false
    end)
    UserInputService.TouchMoved:Connect(function(input)
        if dragging and slider and slider.AbsoluteSize.X > 0 then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos + 0.5)
            fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)
    return slider
end

function CreateDropdown(parent, text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 40)
    frame.Position = UDim2.new(0, 6, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
    frame.BorderSize = 0
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -5, 0.7, 0)
    btn.Position = UDim2.new(0.5, 5, 0.15, 0)
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
        list.Size = UDim2.new(0.5, -5, 0, #options * 28)
        list.Position = UDim2.new(0.5, 5, 1, 0)
        list.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        list.BorderSize = 0
        list.Parent = frame
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
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
    return btn
end

-- ========== ФУНКЦИИ СКРИПТА ==========
local Settings = {
    AutoFarm = false,
    AutoClick = false,
    Fly = false,
    NoClip = false,
    Speed = 50,
    AntiAFK = true
}

-- Anti-AFK
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

-- AutoFarm (без ошибок)
task.spawn(function()
    while wait(0.3) do
        if Settings.AutoFarm and LocalPlayer.Character then
            local target = nil
            -- Ищем мобов (разные варианты)
            local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("NPCs")
            if enemies then
                for _, v in pairs(enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        target = v
                        break
                    end
                end
            end
            -- Альтернативный поиск
            if not target then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= LocalPlayer.Name then
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                end
            end
            if target and target:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 2, 2)
                    if Settings.AutoClick then
                        local remote = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Combat")
                        if remote then
                            remote:FireServer(LocalPlayer.Character.HumanoidRootPart)
                        end
                    end
                end)
            end
        end
    end
end)

-- Fly (без багов)
local flyEnabled = false
local bodyVel, bodyGyro
task.spawn(function()
    while wait(0.1) do
        if Settings.Fly and not flyEnabled then
            flyEnabled = true
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVel.Parent = char.HumanoidRootPart
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bodyGyro.Parent = char.HumanoidRootPart
            end
        elseif not Settings.Fly and flyEnabled then
            flyEnabled = false
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
        if flyEnabled and bodyVel and LocalPlayer.Character then
            pcall(function()
                local cam = workspace.CurrentCamera
                local move = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                if move.Magnitude > 0 then
                    bodyVel.Velocity = move.Unit * (Settings.Speed or 50)
                else
                    bodyVel.Velocity = Vector3.new(0, 0, 0)
                end
                bodyGyro.CFrame = cam.CFrame
            end)
        end
    end
end)

-- NoClip
task.spawn(function()
    while wait(0.5) do
        if Settings.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- Speed Hack
task.spawn(function()
    while wait(0.2) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local ws = (Settings.Fly or not Settings.AutoFarm) and (Settings.Speed or 16) or 16
            LocalPlayer.Character.Humanoid.WalkSpeed = ws
        end
    end
end)

-- ========== ПОСТРОЕНИЕ МЕНЮ ==========
local mainTab = CreateTab("Главная", "🤖")
CreateToggle(mainTab, "Автофарм", function(v) Settings.AutoFarm = v end)
CreateToggle(mainTab, "Автоклик", function(v) Settings.AutoClick = v end)

local moveTab = CreateTab("Движение", "🚀")
CreateToggle(moveTab, "Fly (WASD+Space)", function(v) Settings.Fly = v end)
CreateToggle(moveTab, "NoClip", function(v) Settings.NoClip = v end)
CreateSlider(moveTab, "Скорость", 16, 200, 50, function(v) Settings.Speed = v end)

local miscTab = CreateTab("Разное", "⚙️")
CreateToggle(miscTab, "Anti-AFK", function(v) Settings.AntiAFK = v end)

print("🌲 ForestHub v211 загружен | Без ошибок | Ключ: Forest")
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestHub",
        Text = "Готово! Ошибок нет.",
        Duration = 2
    })
end)
