--[[
    Ноклип + Беск. прыжок + Флай + Скорость + X-Ray
    Delta Executor (Android/iOS)
]]

local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "UltimateCheatsGUI"

-- Главное окно
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 220)
frame.Position = UDim2.new(0.5, -105, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Ultimate Cheats"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14

-- Функция создания переключателя
local function createToggle(y, text, callback)
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, -20, 0, 28)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 120, 0, 24)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
    return btn, label
end

-- Состояния
local noclip = false
local infJump = false
local fly = false
local xray = false
local verticalVel = 0
local walkSpeed = 20
local bv, bg

-- Ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclip and player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Бесконечный прыжок
game:GetService("RunService").Heartbeat:Connect(function()
    if infJump and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
            hum.Jump = true
        end
    end
end)

-- Флай
local function toggleFly(value)
    fly = value
    if not value then
        verticalVel = 0
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        return
    end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(400000, 400000, 400000)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(400000, 400000, 400000)
    bg.CFrame = root.CFrame
    bg.Parent = root
end

game:GetService("RunService").Heartbeat:Connect(function()
    if fly and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and bv and bg then
            bv.Velocity = hum.MoveDirection * 25 + Vector3.new(0, verticalVel, 0)
            bg.CFrame = root.CFrame
        end
    end
end)

-- X-Ray (прозрачность всех частей, кроме игрока)
local xrayTransparency = 0.8
game:GetService("RunService").Heartbeat:Connect(function()
    if xray then
        local char = player.Character
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                obj.Transparency = xrayTransparency
            end
        end
    end
end)

-- Управление скоростью
game:GetService("RunService").Heartbeat:Connect(function()
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end
end)

-- Создаём меню
createToggle(35, "Ноклип", function(v) noclip = v end)
createToggle(65, "Беск. прыжок", function(v) infJump = v end)
local flyToggle, _ = createToggle(95, "Флай", function(v)
    toggleFly(v)
    upBtn.Visible = v
    downBtn.Visible = v
end)
createToggle(125, "X-Ray", function(v) xray = v end)

-- Слайдер скорости
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(0, 120, 0, 24)
speedLabel.Position = UDim2.new(0, 10, 0, 155)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Text = "Скорость: 20"
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 13

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 50, 0, 24)
speedBox.Position = UDim2.new(0.6, 0, 0, 155)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Text = "20"
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 13
speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num >= 16 and num <= 200 then
        walkSpeed = num
        speedLabel.Text = "Скорость: " .. num
    else
        speedBox.Text = walkSpeed
    end
end)

-- Кнопки флая (вверх/вниз)
local upBtn = Instance.new("TextButton", frame)
upBtn.Size = UDim2.new(0, 35, 0, 35)
upBtn.Position = UDim2.new(0.7, 0, 0.5, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "↑"
upBtn.Font = Enum.Font.SourceSansBold
upBtn.TextSize = 20
upBtn.Visible = false

local downBtn = Instance.new("TextButton", frame)
downBtn.Size = UDim2.new(0, 35, 0, 35)
downBtn.Position = UDim2.new(0.7, 0, 0.7, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "↓"
downBtn.Font = Enum.Font.SourceSansBold
downBtn.TextSize = 20
downBtn.Visible = false

upBtn.MouseButton1Down:Connect(function() if fly then verticalVel = 45 end end)
upBtn.MouseButton1Up:Connect(function() verticalVel = 0 end)
downBtn.MouseButton1Down:Connect(function() if fly then verticalVel = -45 end end)
downBtn.MouseButton1Up:Connect(function() verticalVel = 0 end)
