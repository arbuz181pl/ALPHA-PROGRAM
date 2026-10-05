--//==================================================
--// MM2 MENU BY ARBUZ v1BETA
--//==================================================
--// Loaded via loadstring
--//==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS  (state merged into S table)
--==================================================

local ROLE_COLORS = {
	Innocent = Color3.fromRGB(50, 210, 90),
	Murderer = Color3.fromRGB(230, 55, 55),
	Sheriff = Color3.fromRGB(55, 140, 255),
	Hero = Color3.fromRGB(255, 205, 50),
}

local GUN_COLOR = Color3.fromRGB(170, 90, 230)

local S = {
	noclip = false,
	infinityJump = false,
	flingOnTouch = false,
	flingThirdParty = false,
	flyEnabled = false,
	autoNotifyRoles = false,
	autoKillAll = false,
	autoGunTP = false,
	autoSendMurdererChat = false,
	antiVoidEnabled = false,
	antiFlingEnabled = false,
	flySpeed = 50,
	speedhackEnabled = false,
	speedhackSpeed = 45,
	guiLocked = false,
	minimized = false,
	menuVisible = true,
	espEnabled = { Innocent = false, Murderer = false, Sheriff = false, Hero = false },
	gunESPEnabled = false,
	gunHighlights = {},
	originalCollision = {},
	lastChatSentMurderer = nil,
	roundActive = false,
	chatSendCooldown = 0,
	flyPanelOpen = false,
	flingTouchActive = false,
	flingTouchThread = nil,
	dropdownOpen = false,
	selectedPlayer = nil,
	resizing = false,
	dragging = false,
	reopenDragging = false,
	lastSafePosition = nil,
	lastSafeUpdate = 0,
	antiVoidCooldown = false,
	VOID_Y_THRESHOLD = -50,
	ANTI_FLING_MAX_SPEED = 200,
	ANTI_FLING_MAX_ANGULAR = 500,
}

local MurdererName = nil
local SheriffName = nil
local HeroName = nil

local lastNotifiedMurderer = nil
local lastNotifiedSheriff = nil
local lastNotifiedHero = nil

local noMurdererSince = nil
local ROUND_END_DEBOUNCE = 2.0

local GetPlayerData = nil
pcall(function()
	GetPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
end)
local warnedNoRemote = false

--==================================================
-- NOTIFICATION UTILITY
--==================================================

local function sendNotification(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5
		})
	end)
end

--==================================================
-- GUI
--==================================================

local existingGui = playerGui:FindFirstChild("MM2MenuByArbuz")
if existingGui then existingGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MM2MenuByArbuz"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = false
gui.Enabled = true
gui.DisplayOrder = 100
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 330)
frame.Position = UDim2.new(0.5, -140, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(22, 23, 28)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(55, 57, 65)
frameStroke.Thickness = 1
frameStroke.Parent = frame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 MENU BY ARBUZ v0.9BETA"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 2
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.Position = UDim2.new(1, -105, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
closeButton.Text = "X"
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Active = true
closeButton.ZIndex = 5
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

local lockButton = Instance.new("TextButton")
lockButton.Name = "Lock"
lockButton.Size = UDim2.fromOffset(30, 30)
lockButton.Position = UDim2.new(1, -70, 0.5, -15)
lockButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
lockButton.Text = "🔓"
lockButton.TextSize = 14
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.AutoButtonColor = false
lockButton.Active = true
lockButton.ZIndex = 5
lockButton.Parent = header

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 7)
lockCorner.Parent = lockButton

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.fromOffset(30, 30)
minimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
minimizeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 17
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.AutoButtonColor = false
minimizeButton.Active = true
minimizeButton.ZIndex = 5
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 7)
minimizeCorner.Parent = minimizeButton

local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.fromOffset(16, 16)
resizeHandle.Position = UDim2.new(1, -16, 1, -16)
resizeHandle.BackgroundColor3 = Color3.fromRGB(55, 57, 65)
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = ""
resizeHandle.AutoButtonColor = false
resizeHandle.Active = true
resizeHandle.ZIndex = 30
resizeHandle.Parent = frame

local resizeCorner = Instance.new("UICorner")
resizeCorner.CornerRadius = UDim.new(0, 4)
resizeCorner.Parent = resizeHandle

local MIN_WIDTH = 240
local MIN_HEIGHT = 200
local resizeStart
local resizeStartSize

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		S.resizing = true
		resizeStart = input.Position
		resizeStartSize = frame.AbsoluteSize
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not S.resizing then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - resizeStart
		local newWidth = math.max(MIN_WIDTH, resizeStartSize.X + delta.X)
		local newHeight = math.max(MIN_HEIGHT, resizeStartSize.Y + delta.Y)
		frame.Size = UDim2.fromOffset(newWidth, newHeight)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		S.resizing = false
	end
end)

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "Reopen"
reopenButton.Size = UDim2.fromOffset(50, 50)
reopenButton.Position = UDim2.new(0, 15, 0.5, -25)
reopenButton.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
reopenButton.BorderSizePixel = 0
reopenButton.Text = "MM2"
reopenButton.TextColor3 = Color3.fromRGB(245, 245, 250)
reopenButton.TextSize = 13
reopenButton.Font = Enum.Font.GothamBold
reopenButton.AutoButtonColor = false
reopenButton.Active = true
reopenButton.Visible = false
reopenButton.ZIndex = 50
reopenButton.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(1, 0)
reopenCorner.Parent = reopenButton

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(80, 82, 90)
reopenStroke.Thickness = 2
reopenStroke.Parent = reopenButton

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -58)
content.Position = UDim2.fromOffset(10, 53)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
content.CanvasSize = UDim2.fromOffset(0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.Parent = frame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

local currentLayoutOrder = 0
local function getLayoutOrder()
	currentLayoutOrder = currentLayoutOrder + 1
	return currentLayoutOrder
end

--==================================================
-- HELPERS
--==================================================

local function createSectionTitle(text)
	local label = Instance.new("TextLabel")
	label.Name = text .. "Header"
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(150, 153, 165)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = getLayoutOrder()
	label.Parent = content
	return label
end

local function createToggle(name, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(230, 230, 235)
	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = getLayoutOrder()
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(5, 20)
	indicator.Position = UDim2.fromOffset(8, 8)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	indicator.BorderSizePixel = 0
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	return button, indicator
end

local function createActionButton(name, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(230, 230, 235)
	button.TextSize = 13
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.LayoutOrder = getLayoutOrder()
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

local function setToggleOn(button, indicator)
	button.BackgroundColor3 = Color3.fromRGB(35, 70, 45)
	indicator.BackgroundColor3 = Color3.fromRGB(50, 210, 90)
end

local function setToggleOff(button, indicator)
	button.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
end

--==================================================
-- SPAWN CACHE
--==================================================

local cachedSpawns = {}

local function refreshSpawnCache()
	local newCache = {}
	for _, spawnObject in ipairs(workspace:GetDescendants()) do
		if spawnObject:IsA("SpawnLocation") or (spawnObject:IsA("BasePart") and spawnObject.Name == "SpawnPoint") then
			table.insert(newCache, spawnObject)
		end
	end
	cachedSpawns = newCache
end

local function isPlayerInSpawn(target)
	if not target or not target.Character then return true end

	local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyMap")
	if lobby and target.Character:IsDescendantOf(lobby) then
		return true
	end

	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return true end

	for _, spawnObject in ipairs(cachedSpawns) do
		if spawnObject and spawnObject.Parent then
			if (targetRoot.Position - spawnObject.Position).Magnitude < 35 then
				return true
			end
		end
	end

	return false
end

refreshSpawnCache()
task.spawn(function()
	while gui.Parent do
		pcall(refreshSpawnCache)
		task.wait(10)
	end
end)

--==================================================
-- MOVEMENT
--==================================================

createSectionTitle("MOVEMENT SETTINGS")

local noclipButton, noclipIndicator = createToggle("Noclip", "Noclip")

noclipButton.MouseButton1Click:Connect(function()
	S.noclip = not S.noclip
	if S.noclip then
		setToggleOn(noclipButton, noclipIndicator)
		S.originalCollision = {}
		if player.Character then
			for _, object in ipairs(player.Character:GetDescendants()) do
				if object:IsA("BasePart") then
					S.originalCollision[object] = object.CanCollide
					object.CanCollide = false
				end
			end
		end
	else
		setToggleOff(noclipButton, noclipIndicator)
		for object, oldValue in pairs(S.originalCollision) do
			if object and object.Parent then
				object.CanCollide = oldValue
			end
		end
		S.originalCollision = {}
	end
end)

local flyButton, flyIndicator = createToggle("Fly", "Fly")

--==================================================
-- FLY PANEL (element refs in FP table)
--==================================================

local FP = {}

do
	local flyPanel = Instance.new("Frame")
	flyPanel.Name = "FlyPanel"
	flyPanel.Size = UDim2.fromOffset(210, 220)
	flyPanel.Position = UDim2.new(0.5, 150, 0.5, -110)
	flyPanel.BackgroundColor3 = Color3.fromRGB(22, 23, 28)
	flyPanel.BorderSizePixel = 0
	flyPanel.Visible = false
	flyPanel.ZIndex = 20
	flyPanel.Parent = gui

	local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 12) c1.Parent = flyPanel
	local s1 = Instance.new("UIStroke") s1.Color = Color3.fromRGB(55, 57, 65) s1.Thickness = 1 s1.Parent = flyPanel

	local flyHeader = Instance.new("Frame")
	flyHeader.Name = "Header"
	flyHeader.Size = UDim2.new(1, 0, 0, 42)
	flyHeader.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
	flyHeader.BorderSizePixel = 0
	flyHeader.ZIndex = 21
	flyHeader.Parent = flyPanel

	local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 12) c2.Parent = flyHeader

	local flyTitle = Instance.new("TextLabel")
	flyTitle.Name = "Title"
	flyTitle.Size = UDim2.new(1, -20, 1, 0)
	flyTitle.Position = UDim2.fromOffset(10, 0)
	flyTitle.BackgroundTransparency = 1
	flyTitle.Text = "FLY"
	flyTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
	flyTitle.TextSize = 13
	flyTitle.Font = Enum.Font.GothamBold
	flyTitle.TextXAlignment = Enum.TextXAlignment.Left
	flyTitle.TextYAlignment = Enum.TextYAlignment.Center
	flyTitle.ZIndex = 22
	flyTitle.Parent = flyHeader

	local enableBtn = Instance.new("TextButton")
	enableBtn.Name = "Enable"
	enableBtn.Size = UDim2.new(1, -20, 0, 36)
	enableBtn.Position = UDim2.fromOffset(10, 52)
	enableBtn.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	enableBtn.BorderSizePixel = 0
	enableBtn.Text = "Enable Fly"
	enableBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
	enableBtn.TextSize = 13
	enableBtn.Font = Enum.Font.GothamSemibold
	enableBtn.AutoButtonColor = false
	enableBtn.ZIndex = 21
	enableBtn.Parent = flyPanel

	local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 8) c3.Parent = enableBtn

	local enableInd = Instance.new("Frame")
	enableInd.Name = "Indicator"
	enableInd.Size = UDim2.fromOffset(5, 20)
	enableInd.Position = UDim2.fromOffset(8, 8)
	enableInd.BackgroundColor3 = Color3.fromRGB(80, 82, 90)
	enableInd.BorderSizePixel = 0
	enableInd.ZIndex = 22
	enableInd.Parent = enableBtn

	local c4 = Instance.new("UICorner") c4.CornerRadius = UDim.new(1, 0) c4.Parent = enableInd

	local speedLbl = Instance.new("TextLabel")
	speedLbl.Name = "SpeedLabel"
	speedLbl.Size = UDim2.new(1, -20, 0, 20)
	speedLbl.Position = UDim2.fromOffset(10, 98)
	speedLbl.BackgroundTransparency = 1
	speedLbl.Text = "Speed: 50"
	speedLbl.TextColor3 = Color3.fromRGB(150, 153, 165)
	speedLbl.TextSize = 11
	speedLbl.Font = Enum.Font.GothamBold
	speedLbl.TextXAlignment = Enum.TextXAlignment.Left
	speedLbl.ZIndex = 21
	speedLbl.Parent = flyPanel

	local minusBtn = Instance.new("TextButton")
	minusBtn.Name = "Minus"
	minusBtn.Size = UDim2.fromOffset(36, 32)
	minusBtn.Position = UDim2.fromOffset(10, 123)
	minusBtn.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	minusBtn.BorderSizePixel = 0
	minusBtn.Text = "-"
	minusBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
	minusBtn.TextSize = 18
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.AutoButtonColor = false
	minusBtn.ZIndex = 21
	minusBtn.Parent = flyPanel

	local c5 = Instance.new("UICorner") c5.CornerRadius = UDim.new(0, 7) c5.Parent = minusBtn

	local speedBox = Instance.new("TextBox")
	speedBox.Name = "Speed"
	speedBox.Size = UDim2.new(1, -96, 0, 32)
	speedBox.Position = UDim2.fromOffset(52, 123)
	speedBox.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	speedBox.BorderSizePixel = 0
	speedBox.Text = "50"
	speedBox.TextColor3 = Color3.fromRGB(235, 235, 240)
	speedBox.TextSize = 12
	speedBox.Font = Enum.Font.GothamSemibold
	speedBox.ClearTextOnFocus = false
	speedBox.ZIndex = 21
	speedBox.Parent = flyPanel

	local c6 = Instance.new("UICorner") c6.CornerRadius = UDim.new(0, 7) c6.Parent = speedBox

	local plusBtn = Instance.new("TextButton")
	plusBtn.Name = "Plus"
	plusBtn.Size = UDim2.fromOffset(36, 32)
	plusBtn.Position = UDim2.new(1, -46, 0, 123)
	plusBtn.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	plusBtn.BorderSizePixel = 0
	plusBtn.Text = "+"
	plusBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
	plusBtn.TextSize = 18
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.AutoButtonColor = false
	plusBtn.ZIndex = 21
	plusBtn.Parent = flyPanel

	local c7 = Instance.new("UICorner") c7.CornerRadius = UDim.new(0, 7) c7.Parent = plusBtn

	local upBtn = Instance.new("TextButton")
	upBtn.Name = "Up"
	upBtn.Size = UDim2.fromOffset(85, 32)
	upBtn.Position = UDim2.fromOffset(10, 168)
	upBtn.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	upBtn.BorderSizePixel = 0
	upBtn.Text = "UP"
	upBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
	upBtn.TextSize = 12
	upBtn.Font = Enum.Font.GothamBold
	upBtn.AutoButtonColor = false
	upBtn.ZIndex = 21
	upBtn.Parent = flyPanel

	local c8 = Instance.new("UICorner") c8.CornerRadius = UDim.new(0, 7) c8.Parent = upBtn

	local downBtn = Instance.new("TextButton")
	downBtn.Name = "Down"
	downBtn.Size = UDim2.fromOffset(85, 32)
	downBtn.Position = UDim2.new(1, -95, 0, 168)
	downBtn.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
	downBtn.BorderSizePixel = 0
	downBtn.Text = "DOWN"
	downBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
	downBtn.TextSize = 12
	downBtn.Font = Enum.Font.GothamBold
	downBtn.AutoButtonColor = false
	downBtn.ZIndex = 21
	downBtn.Parent = flyPanel

	local c9 = Instance.new("UICorner") c9.CornerRadius = UDim.new(0, 7) c9.Parent = downBtn

	FP.panel = flyPanel
	FP.enableBtn = enableBtn
	FP.enableInd = enableInd
	FP.speedLbl = speedLbl
	FP.minus = minusBtn
	FP.speedBox = speedBox
	FP.plus = plusBtn
	FP.up = upBtn
	FP.down = downBtn
end

local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyChar = nil
local flyHum = nil
local flyRootPart = nil
local flyUpFlag = 0
local flyDownFlag = 0

local function updateFlySpeed(value)
	value = tonumber(value)
	if not value then value = S.flySpeed end
	value = math.clamp(math.floor(value), 1, 500)
	S.flySpeed = value
	FP.speedLbl.Text = "Speed: " .. tostring(S.flySpeed)
	FP.speedBox.Text = tostring(S.flySpeed)
end

FP.minus.MouseButton1Click:Connect(function() updateFlySpeed(S.flySpeed - 1) end)
FP.plus.MouseButton1Click:Connect(function() updateFlySpeed(S.flySpeed + 1) end)
FP.speedBox.FocusLost:Connect(function() updateFlySpeed(FP.speedBox.Text) end)

local function stopFly()
	S.flyEnabled = false
	if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
	flyChar = nil
	flyHum = nil
	flyRootPart = nil

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
	end

	FP.enableBtn.Text = "Enable Fly"
	setToggleOff(FP.enableBtn, FP.enableInd)
	setToggleOff(flyButton, flyIndicator)
end

local function startFly()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	if flyBodyVelocity then flyBodyVelocity:Destroy() end
	if flyBodyGyro then flyBodyGyro:Destroy() end

	S.flyEnabled = true
	flyChar = character
	flyHum = humanoid
	flyRootPart = root

	humanoid.PlatformStand = true

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.P = 90000
	flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Velocity = Vector3.zero
	flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBodyVelocity.Parent = root

	FP.enableBtn.Text = "Disable Fly"
	setToggleOn(FP.enableBtn, FP.enableInd)
	setToggleOn(flyButton, flyIndicator)
end

FP.enableBtn.MouseButton1Click:Connect(function()
	if S.flyEnabled then stopFly() else startFly() end
end)

flyButton.MouseButton1Click:Connect(function()
	S.flyPanelOpen = not S.flyPanelOpen
	FP.panel.Visible = S.flyPanelOpen
	if S.flyPanelOpen then
		flyButton.BackgroundColor3 = Color3.fromRGB(45, 47, 56)
	else
		if S.flyEnabled then
			setToggleOn(flyButton, flyIndicator)
		else
			setToggleOff(flyButton, flyIndicator)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not S.flyEnabled or not flyBodyVelocity or not flyBodyGyro then return end
	local character = player.Character
	if not character then stopFly() return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not root or not camera then return end

	local direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		direction = direction + camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		direction = direction - camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		direction = direction - camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		direction = direction + camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) or flyUpFlag == 1 then
		direction = direction + Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or flyDownFlag == -1 then
		direction = direction - Vector3.new(0, 1, 0)
	end

	if direction.Magnitude > 0 then
		flyBodyVelocity.Velocity = direction.Unit * S.flySpeed
	else
		flyBodyVelocity.Velocity = Vector3.zero
	end

	flyBodyGyro.CFrame = camera.CFrame
end)

FP.up.MouseButton1Down:Connect(function() flyUpFlag = 1 end)
FP.up.MouseButton1Up:Connect(function() flyUpFlag = 0 end)
FP.down.MouseButton1Down:Connect(function() flyDownFlag = -1 end)
FP.down.MouseButton1Up:Connect(function() flyDownFlag = 0 end)

-- INFINITY JUMP
local infinityJumpButton, infinityJumpIndicator = createToggle("InfinityJump", "Infinity Jump")

infinityJumpButton.MouseButton1Click:Connect(function()
	S.infinityJump = not S.infinityJump
	if S.infinityJump then
		setToggleOn(infinityJumpButton, infinityJumpIndicator)
	else
		setToggleOff(infinityJumpButton, infinityJumpIndicator)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if not S.infinityJump then return end
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

--==================================================
-- FLING 3RD PARTY
--==================================================

local flingThirdPartyButton, flingThirdPartyIndicator = createToggle("FlingOnTouch", "Fling 3rd party")

flingThirdPartyButton.MouseButton1Click:Connect(function()
	S.flingThirdParty = not S.flingThirdParty
	if S.flingThirdParty then
		flingThirdPartyButton.BackgroundColor3 = Color3.fromRGB(70, 45, 35)
		flingThirdPartyIndicator.BackgroundColor3 = Color3.fromRGB(230, 100, 55)
		local success = pcall(function()
			loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Ultimate-Fling-GUI-41909"))()
		end)
		if not success then
			sendNotification("MM2 Menu", "Failed to load 3rd party fling script.")
		end
	else
		setToggleOff(flingThirdPartyButton, flingThirdPartyIndicator)
	end
end)

--==================================================
-- FLING ON TOUCH
--==================================================

local function flingOnTouchLoop()
	local lp = player
	local c, hrp, vel, movel = nil, nil, nil, 0.1

	while S.flingTouchActive do
		RunService.Heartbeat:Wait()
		c = lp.Character
		hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			vel = hrp.Velocity
			hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
			RunService.RenderStepped:Wait()
			hrp.Velocity = vel
			RunService.Stepped:Wait()
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

local flingOnTouchButton, fl