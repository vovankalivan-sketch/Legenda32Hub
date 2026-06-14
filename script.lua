--[[
    Ноклип + Бесконечный прыжок + Флай (Рабочее меню)
    Для Delta Executor (Android/iOS)
]]

local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "NoclipJumpFlyGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 170)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Ноклип + Прыжок + Флай"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14

-- Вспомогательная функция для создания переключателя
local function createToggle(yPos, labelText, callback)
    local back = Instance.new("Frame", frame)
    back.Size = UDim2.new(1, -20, 0, 28)
    back.Position = UDim2.new(0, 10, 0, yPos)
    back.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", back)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    local lbl = Instance.new("TextLabel", back)
    lbl.Size = UDim2.new(0, 110, 0, 24)
    lbl.Position = UDim2.new(0, 60, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Text = labelText
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = active and "ON" or "OFF"
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        callback(active)
    end)
    return btn, lbl
end

-- Состояния
local noclipEnabled = false
local jumpEnabled = false
local flyEnabled = false
local verticalVelocity = 0
local bodyVelocity, bodyGyro

-- Ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Бесконечный прыжок (исправлено)
game:GetService("RunService").Heartbeat:Connect(function()
    if jumpEnabled and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and (hum:GetState() == Enum.HumanoidStateType.Landed or hum:GetState() == Enum.HumanoidStateType.Running) then
            hum.Jump = true
        end
    end
end)

-- Управление флаем
local function onFlyChanged(value)
    flyEnabled = value
    if not value then
        -- Выключаем
        verticalVelocity = 0
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        return
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
end

game:GetService("RunService").Heartbeat:Connect(function()
    if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and bodyVelocity and bodyGyro then
            local moveDir = hum.MoveDirection * 30 -- горизонтальная скорость
            bodyVelocity.Velocity = moveDir + Vector3.new(0, verticalVelocity, 0)
            bodyGyro.CFrame = root.CFrame
        end
    end
end)

-- Создаем тогглы
createToggle(30, "Ноклип", function(v) noclipEnabled = v end)
createToggle(60, "Беск. прыжок", function(v) jumpEnabled = v end)
local flyToggle, _ = createToggle(90, "Флай", onFlyChanged)

-- Кнопки подъема/спуска (появляются только при активном флае)
local upBtn = Instance.new("TextButton", frame)
upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(0.7, 0, 0.55, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "↑"
upBtn.Font = Enum.Font.SourceSansBold
upBtn.TextSize = 24
upBtn.Visible = false

local downBtn = Instance.new("TextButton", frame)
downBtn.Size = UDim2.new(0, 40, 0, 40)
downBtn.Position = UDim2.new(0.7, 0, 0.82, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "↓"
downBtn.Font = Enum.Font.SourceSansBold
downBtn.TextSize = 24
downBtn.Visible = false

-- Обработчики нажатий
upBtn.MouseButton1Down:Connect(function()
    if flyEnabled then verticalVelocity = 50 end
end)
upBtn.MouseButton1Up:Connect(function()
    verticalVelocity = 0
end)
downBtn.MouseButton1Down:Connect(function()
    if flyEnabled then verticalVelocity = -50 end
end)
downBtn.MouseButton1Up:Connect(function()
    verticalVelocity = 0
end)

-- При переключении флая показываем/скрываем кнопки
flyToggle.MouseButton1Click:Connect(function()
    -- не трогаем, уже обработано в createToggle
end)
-- Подправим: нужно после создания flyToggle обновить видимость кнопок при его активации
-- Проще всего добавить проверку в onFlyChanged
-- Переопределим onFlyChanged
local oldFlyChanged = onFlyChanged
onFlyChanged = function(value)
    oldFlyChanged(value)
    upBtn.Visible = value
    downBtn.Visible = value
end
-- Теперь свяжем заново (уже поздно, надо было до createToggle)
-- Просто удалим старый flyToggle и создадим новый с правильным колбэком
flyToggle:Destroy()
local flyToggleNew, _ = createToggle(90, "Флай", onFlyChanged)
-- Кнопки остались те же, onFlyChanged теперь управляет их видимостью
