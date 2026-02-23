local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local flying = false
local speed = 100

-- Создаем объекты управления силой
local bv = Instance.new("BodyVelocity")
local bg = Instance.new("BodyGyro")

bv.MaxForce = Vector3.new(0, 0, 0) -- По умолчанию выключено
bg.MaxTorque = Vector3.new(0, 0, 0)
bg.P = 90000 -- Мощность стабилизации

bv.Parent = rootPart
bg.Parent = rootPart

local function toggleFly()
	flying = not flying
	if flying then
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		character.Humanoid.PlatformStand = true
	else
		bv.MaxForce = Vector3.new(0, 0, 0)
		bg.MaxTorque = Vector3.new(0, 0, 0)
		character.Humanoid.PlatformStand = false
	end
end

-- Кнопка E для включения
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E then
		toggleFly()
	end
end)

-- Цикл обновления
game:GetService("RunService").RenderStepped:Connect(function()
	if flying then
		bv.Velocity = camera.CFrame.LookVector * speed
		bg.CFrame = camera.CFrame
	end
end)