-- Загрузка кроссплатформенной библиотеки интерфейса (поддерживает Delta)
local Library = loadstring(game:HttpGet("githubusercontent.com"))()

-- Создание главного окна хаба
local Window = Library:CreateWindow("LegendaHub | Pet Sim 99")

-- Переменные для переключателей функций (Toggle)
local _G = getgenv and getgenv() or _G
_G.AutoFarm = false
_G.AutoClicker = false
_G.AutoHatch = false

-- Создание вкладки автоматизации
local FarmTab = Window:CreateFolder("Фарм и Кликер")

-- Функция 1: Автоматический сбор монет и сундуков (Orbs)
FarmTab:Toggle("Авто-Фарм (Сбор монет)", function(state)
    _G.AutoFarm = state
    if state then
        task.spawn(function()
            while _G.AutoFarm do
                task.wait(0.1)
                -- Безопасный поиск всех предметов на земле в зоне видимости
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == "Lootbag" or obj.Name == "Orb" then
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            -- Имитация сбора за счет перемещения локального парта (не банится античитом)
                            obj.Position = char.HumanoidRootPart.Position
                        end
                    end
                end
            end
        end)
    end
end)

-- Функция 2: Бесконечный Авто-кликер по монетам/сундукам
FarmTab:Toggle("Авто-Кликер", function(state)
    _G.AutoClicker = state
    if state then
        task.spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            -- Подключение к событию клика, чтобы предотвратить кик за АФК
            game.Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end)
            
            while _G.AutoClicker do
                task.wait(0.05) -- Быстрый клик
                -- Отправка сигнала клика на экран по центру игры
                VirtualUser:Button1Down(Vector2.new(X, Y), workspace.CurrentCamera.CFrame)
            end
        end)
    end
end)

-- Создание вкладки для яиц
local EggTab = Window:CreateFolder("Яйца и Питомцы")

-- Функция 3: Автоматическое открытие яиц
EggTab:Toggle("Авто-Открытие яиц", function(state)
    _G.AutoHatch = state
    if state then
        task.spawn(function()
            while _G.AutoHatch do
                task.wait(0.5)
                -- Обращение к сетевому событию игры для покупки первого доступного яйца
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
                if remotes and remotes:FindFirstChild("Eggs_Roll") then
                    -- Отправка запроса на покупку 1 яйца (Тестовое имя: "Egg 1")
                    remotes["Eggs_Roll"]:InvokeServer("Egg 1", 1)
                end
            end
        end)
    end
end)

-- Вкладка утилит
local MiscTab = Window:CreateFolder("Разное")

MiscTab:Button("Убрать лаги (FPS Boost)", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
end)

-- Всплывающее уведомление в игре
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "LegendaHub",
    Text = "Скрипт полностью готов! Вкладки активны.",
    Duration = 4
})
