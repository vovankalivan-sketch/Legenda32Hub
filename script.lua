--[[
    Legenda32Hub | Pet Simulator 99
    GitHub: https://raw.githubusercontent.com/vovankalivan-sketch/Legenda32Hub/refs/heads/main/script.lua
]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Character
local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

--// Settings
local Settings = {
    AutoFarm = {Enabled = false, Zone = "Best"},
    AutoEgg = {Enabled = false, Egg = "Best", OpenAll = false},
    AutoCoin = {Enabled = false, Method = "Zone"},
    AutoRebirth = {Enabled = false, Rebirths = 1},
    AutoUpgrade = {Enabled = false},
    AutoEnchant = {Enabled = false},
    AutoPotion = {Enabled = false},
    ESP = {Enabled = false, ShowPets = true, ShowCoins = true, ShowEggs = true},
    Teleport = {Enabled = false, Target = "Spawn"},
    Speed = {Enabled = false, Value = 50},
    Jump = {Enabled = false, Power = 100}
}

--// Remote Finder
local function findRemote(path)
    local remote = ReplicatedStorage
    for _, part in ipairs(path:split(".")) do
        remote = remote:FindFirstChild(part)
        if not remote then return nil end
    end
    return remote
end

--// Pet Simulator 99 Specific Functions
local function collectCoins()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:find("Coin") or obj.Name:find("Gem") or obj.Name:find("Diamond")) then
            local hrp = getHRP()
            if hrp then
                firetouchinterest(hrp, obj, 0)
                task.wait()
                firetouchinterest(hrp, obj, 1)
            end
        end
    end
end

local function openEggs()
    local eggs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Egg") then
            table.insert(eggs, obj)
        end
    end
    
    if #eggs > 0 then
        local targetEgg = Settings.AutoEgg.Egg == "Best" and eggs[#eggs] or eggs[1]
        local hrp = getHRP()
        if hrp and targetEgg and targetEgg.PrimaryPart then
            hrp.CFrame = targetEgg.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
            task.wait(0.5)
            
            -- Click egg multiple times
            for i = 1, 10 do
                fireclickdetector(targetEgg)
                task.wait(0.1)
            end
        end
    end
end

local function farmZone()
    local zones = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Zone") then
            table.insert(zones, {obj = obj, number = tonumber(obj.Name:match("%d+")) or 0})
        end
    end
    
    table.sort(zones, function(a, b) return a.number > b.number end)
    
    if #zones > 0 then
        local targetZone = Settings.AutoFarm.Zone == "Best" and zones[1].obj or zones[math.random(1, #zones)].obj
        local hrp = getHRP()
        if hrp and targetZone and targetZone.PrimaryPart then
            hrp.CFrame = targetZone.PrimaryPart.CFrame + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10))
        end
    end
end

local function rebirth()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Rebirth") and obj:FindFirstChild("ClickDetector") then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.5)
                fireclickdetector(obj)
            end
        end
    end
end

local function enchantPets()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Enchant") and obj:FindFirstChild("ClickDetector") then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.5)
                fireclickdetector(obj)
            end
        end
    end
end

local function usePotions()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Potion") and obj:FindFirstChild("ClickDetector") then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.3)
                fireclickdetector(obj)
            end
        end
    end
end

local function upgradePets()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("Upgrade") and obj:FindFirstChild("ClickDetector") then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.5)
                fireclickdetector(obj)
            end
        end
    end
end

--// Fly System
local FlyConnections = {}
function createFly()
    local hrp = getHRP()
    if not hrp then return end
    
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.P = 9e4
    gyro.Parent = hrp
    
    local vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    vel.P = 9e4
    vel.Velocity = Vector3.zero
    vel.Parent = hrp
    
    local conn = RunService.Heartbeat:Connect(function()
        if not getHRP() or not Settings.Teleport.Enabled then return end
        gyro.CFrame = Camera.CFrame
        
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        
        vel.Velocity = dir * 50
    end)
    table.insert(FlyConnections, conn)
end

function destroyFly()
    for _, c in pairs(FlyConnections) do c:Disconnect() end
    FlyConnections = {}
    local hrp = getHRP()
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

--// ESP System
local ESPObjects = {}
function createESP()
    for _, o in pairs(ESPObjects) do if o then o:Destroy() end end
    ESPObjects = {}
    
    if not Settings.ESP.Enabled then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local add = false
            if Settings.ESP.ShowPets and obj.Name:find("Pet") then add = true
            elseif Settings.ESP.ShowCoins and (obj.Name:find("Coin") or obj.Name:find("Gem")) then add = true
            elseif Settings.ESP.ShowEggs and obj.Name:find("Egg") then add = true end
            
            if add then
                local h = Instance.new("Highlight")
                h.FillColor = obj.Name:find("Egg") and Color3.fromRGB(255, 100, 0) or 
                             (obj.Name:find("Coin") and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 100))
                h.FillTransparency = 0.5
                h.Parent = obj
                table.insert(ESPObjects, h)
            end
        end
    end
end

// Tween Teleport
function tweenTP(pos)
    local hrp = getHRP()
    if hrp then
        TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = CFrame.new(pos)}):Play()
    end
end

// Main Loop
local function mainLoop()
    task.spawn(function()
        while task.wait(0.1) do
            if Settings.AutoCoin.Enabled then collectCoins() end
            if Settings.AutoEgg.Enabled then openEggs() end
            if Settings.AutoFarm.Enabled then farmZone() end
            if Settings.AutoRebirth.Enabled then rebirth() end
            if Settings.AutoUpgrade.Enabled then upgradePets() end
            if Settings.AutoEnchant.Enabled then enchantPets() end
            if Settings.AutoPotion.Enabled then usePotions() end
        end
    end)
end

// Speed & Jump
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    local hum = char:WaitForChild("Humanoid")
    if Settings.Speed.Enabled then hum.WalkSpeed = Settings.Speed.Value end
    if Settings.Jump.Enabled then hum.JumpPower = Settings.Jump.Power end
end)

// GUI
local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Legenda32_PS99"
    gui.Parent = LocalPlayer.PlayerGui
    gui.ResetOnSpawn = false
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 400)
    main.Position = UDim2.new(0.5, -125, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    title.Text = "Pet Simulator 99 Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    local y = 45
    local function addToggle(name, setting, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.Parent = main
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 22)
        btn.Position = UDim2.new(1, -55, 0.5, -11)
        btn.Text = "OFF"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = frame
        
        local enabled = false
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
            btn.Text = enabled and "ON" or "OFF"
            callback(enabled)
        end)
        
        y += 35
    end
    
    addToggle("Auto Farm", Settings.AutoFarm, function(v) 
        Settings.AutoFarm.Enabled = v 
    end)
    
    addToggle("Auto Eggs", Settings.AutoEgg, function(v) 
        Settings.AutoEgg.Enabled = v 
    end)
    
    addToggle("Auto Coins", Settings.AutoCoin, function(v) 
        Settings.AutoCoin.Enabled = v 
    end)
    
    addToggle("Auto Rebirth", Settings.AutoRebirth, function(v) 
        Settings.AutoRebirth.Enabled = v 
    end)
    
    addToggle("Auto Upgrade", Settings.AutoUpgrade, function(v) 
        Settings.AutoUpgrade.Enabled = v 
    end)
    
    addToggle("Auto Enchant", Settings.AutoEnchant, function(v) 
        Settings.AutoEnchant.Enabled = v 
    end)
    
    addToggle("Auto Potions", Settings.AutoPotion, function(v) 
        Settings.AutoPotion.Enabled = v 
    end)
    
    addToggle("ESP", Settings.ESP, function(v) 
        Settings.ESP.Enabled = v 
        createESP()
    end)
    
    addToggle("Speed Hack", Settings.Speed, function(v)
        Settings.Speed.Enabled = v
        local hum = getChar() and getChar():FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v and Settings.Speed.Value or 16 end
    end)
    
    addToggle("Fly/TP", Settings.Teleport, function(v)
        Settings.Teleport.Enabled = v
        if v then createFly() else destroyFly() end
    end)
end

// Start
createGUI()
mainLoop()

warn("Legenda32Hub | Pet Simulator 99 Loaded!")
warn("Optimized for Delta Client Mobile")
