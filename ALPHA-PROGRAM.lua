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
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- PALETTE
--==================================================

local COLORS = {
	bg = Color3.fromRGB(22, 23, 28),
	header = Color3.fromRGB(29, 30, 37),
	row = Color3.fromRGB(34, 36, 43),
	rowActive = Color3.fromRGB(35, 70, 45),
	rowHover = Color3.fromRGB(45, 47, 56),
	rowDanger = Color3.fromRGB(70, 40, 40),
	rowDangerHover = Color3.fromRGB(88, 46, 46),
	rowFling = Color3.fromRGB(70, 45, 35),
	stroke = Color3.fromRGB(55, 57, 65),
	offIndicator = Color3.fromRGB(80, 82, 90),
	text = Color3.fromRGB(230, 230, 235),
	textDim = Color3.fromRGB(150, 153, 165),
	textBright = Color3.fromRGB(245, 245, 250),
	green = Color3.fromRGB(50, 210, 90),
	orange = Color3.fromRGB(230, 100, 55),
	red = Color3.fromRGB(230, 55, 55),
	blue = Color3.fromRGB(55, 140, 255),
	gold = Color3.fromRGB(255, 205, 50),
	purple = Color3.fromRGB(160, 80, 220),
	gun = Color3.fromRGB(255, 160, 60),
}

local ROLE_COLORS = {
	Innocent = Color3.fromRGB(50, 210, 90),
	Murderer = Color3.fromRGB(230, 55, 55),
	Sheriff = Color3.fromRGB(55, 140, 255),
	Hero = Color3.fromRGB(255, 205, 50),
}

--==================================================
-- SETTINGS
--==================================================

local noclip = false
local infinityJump = false
local flingOnTouch = false
local flingThirdParty = false
local flyEnabled = false
local flyPanelOpen = false
local autoNotifyRoles = false
local autoKillAll = false
local autoGunTP = false
local autoSendMurdererChat = false
local autoSendSheriffChat = false
local gunESPEnabled = false
local showDistance = false

local antiVoidEnabled = false
local antiFlingEnabled = false

local flySpeed = 50
local flyMaxSpeed = 50
local flyCurrentSpeed = 0
local flyAccelTime = 0.14
local flyDecelTime = 0.16

local SPEEDHACK_MIN = 1
local SPEEDHACK_MAX = 120
local SPEEDHACK_SAFE = 60
local SPEEDHACK_DEFAULT = 16
local speedhackEnabled = false
local speedhackSpeed = SPEEDHACK_DEFAULT

local VOID_Y_THRESHOLD = -50
local ANTI_FLING_MAX_SPEED = 200
local ANTI_FLING_MAX_ANGULAR = 500
local GUN_MURDERER_RADIUS = 30
local KILL_ALL_PASSES = 3
local CHAT_COOLDOWN = 1.5

local guiLocked = false
local menuVisible = true
local scriptActive = true

local espEnabled = {
	Innocent = false,
	Murderer = false,
	Sheriff = false,
	Hero = false,
}

local originalCollision = {}

pcall(function()
	if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = Instance.new("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = ReplicatedStorage
	end
end)

--==================================================
-- ROLE TRACKING / ROUND STATE
--==================================================

local GetPlayerData = nil
pcall(function()
	GetPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
end)

local MurdererName = nil
local SheriffName = nil
local HeroName = nil

local lastNotifiedMurderer = nil
local lastNotifiedSheriff = nil
local lastNotifiedHero = nil
local lastChatSentMurderer = nil
local lastChatSentSheriff = nil
local lastChatSentAt = 0

local roundLive = false
local killAllRunning = false
local suspendGunTP = 0
local flingTouchActive = false
local lastSafePosition = nil
local lastSafeUpdate = 0
local antiVoidCooldownUntil = 0
local selectedPlayer = nil
local bindCaptureName = nil

-- forward declarations (assigned once the owning section is built)
local updateRoleStatusLabel = function() end

--==================================================
-- FLY STATE
--==================================================

local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyLastUpdate = 0
local flyControls = { f = 0, b = 0, l = 0, r = 0, up = 0, down = 0 }
local lastFlyControls = { f = 0, b = 0, l = 0, r = 0, up = 0, down = 0 }

--==================================================
-- UI UTILITIES
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

local function tweenColor(guiObject, property, target, duration)
	pcall(function()
		TweenService:Create(guiObject, TweenInfo.new(duration or 0.12, Enum.EasingStyle.Quad), {
			[property] = target
		}):Play()
	end)
end

local function setRowColor(button, color)
	button:SetAttribute("RowBase", color)
	if button:GetAttribute("RowHover") then return end
	tweenColor(button, "BackgroundColor3", color, 0.1)
end

local function attachRowHover(button)
	button:SetAttribute("RowBase", COLORS.row)
	button:SetAttribute("RowHover", false)

	button.MouseEnter:Connect(function()
		button:SetAttribute("RowHover", true)
		tweenColor(button, "BackgroundColor3", COLORS.rowHover, 0.1)
	end)
	button.MouseLeave:Connect(function()
		button:SetAttribute("RowHover", false)
		tweenColor(button, "BackgroundColor3", button:GetAttribute("RowBase") or COLORS.row, 0.1)
	end)
end

local function isPlayerAlive(target)
	if not target or not target.Character then return false end
	local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function isPlayerInSpawn(target)
	if not target or not target.Character then return true end

	local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyMap")
	if lobby and target.Character:IsDescendantOf(lobby) then
		return true
	end

	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return true end

	for _, spawnObject in ipairs(workspace:GetDescendants()) do
		if spawnObject:IsA("SpawnLocation") or (spawnObject:IsA("BasePart") and spawnObject.Name == "SpawnPoint") then
			if (targetRoot.Position - spawnObject.Position).Magnitude < 35 then
				return true
			end
		end
	end

	return false
end

local function getPlayerRoot(target)
	if not target or not target.Character then return nil end
	return target.Character:FindFirstChild("HumanoidRootPart")
end

local function getMyRoot()
	if not player.Character then return nil end
	return player.Character:FindFirstChild("HumanoidRootPart")
end

local function getDistanceTo(target)
	local myRoot = getMyRoot()
	local targetRoot = getPlayerRoot(target)
	if not myRoot or not targetRoot then return nil end
	return (myRoot.Position - targetRoot.Position).Magnitude
end

local function formatDistance(value)
	if not value then return "--" end
	if value >= 1000 then
		return string.format("%.0fk", value / 1000)
	end
	return string.format("%.1f", value)
end

local function sendChatMessage(message)
	local sent = false

	pcall(function()
		local TCS = game:GetService("TextChatService")
		if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
			local channels = TCS:FindFirstChild("TextChannels")
			if channels then
				local general = channels:FindFirstChild("RBXGeneral")
				if general then
					general:SendAsync(message)
					sent = true
				end
			end
		end
	end)

	if sent then return true end

	pcall(function()
		StarterGui:SetCore("ChatSendMessage", message)
		sent = true
	end)

	return sent
end

local function roleDisplayName(name)
	local target = name and Players:FindFirstChild(name)
	if target then
		return target.DisplayName .. " (@" .. target.Name .. ")"
	end
	return name or "None"
end

local function getFormattedRoleText(roleName, userName)
	return roleName .. ": " .. roleDisplayName(userName)
end

local function notifyAllRoles()
	local mText = getFormattedRoleText("Murderer", MurdererName)
	local sText = getFormattedRoleText("Sheriff", SheriffName)
	local hText = getFormattedRoleText("Hero", HeroName)
	sendNotification("MM2 Roles", mText .. "\n" .. sText .. "\n" .. hText)
end

local function announceRoleChat(roleLabel, name)
	if not name then
		sendNotification("MM2 Menu", roleLabel .. " not found yet!")
		return false
	end

	local now = tick()
	if now - lastChatSentAt < CHAT_COOLDOWN then
		task.wait(CHAT_COOLDOWN - (now - lastChatSentAt))
	end

	local message = roleLabel .. " is: " .. roleDisplayName(name)
	local ok = sendChatMessage(message)
	lastChatSentAt = tick()

	if ok then
		sendNotification("MM2 Menu", "Sent in chat: " .. message)
	else
		sendNotification("MM2 Menu", "Failed to send chat message.")
	end
	return ok
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

--==================================================
-- MAIN FRAME
--==================================================

local DEFAULT_WIDTH = 280
local DEFAULT_HEIGHT = 330

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(DEFAULT_WIDTH, DEFAULT_HEIGHT)
frame.Position = UDim2.new(0.5, -DEFAULT_WIDTH / 2, 0.5, -DEFAULT_HEIGHT / 2)
frame.BackgroundColor3 = COLORS.bg
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = COLORS.stroke
frameStroke.Thickness = 1
frameStroke.Parent = frame

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = COLORS.header
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -125, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 MENU BY ARBUZ v1.0BETA"
title.TextColor3 = COLORS.textBright
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 2
title.Parent = header

--==================================================
-- HEADER BUTTONS
--==================================================

local function createHeaderButton(name, text, textColor, offset)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(30, 30)
	button.Position = UDim2.new(1, offset, 0.5, -15)
	button.BackgroundColor3 = COLORS.row
	button.Text = text
	button.TextSize = 16
	button.TextColor3 = textColor
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Active = true
	button.ZIndex = 5
	button.Parent = header

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	return button
end

local closeButton = createHeaderButton("Close", "X", Color3.fromRGB(255, 200, 200), -105)
local lockButton = createHeaderButton("Lock", "UNLOCK", COLORS.textBright, -70)
lockButton.TextSize = 9
local minimizeButton = createHeaderButton("Minimize", "-", Color3.new(1, 1, 1), -35)

--==================================================
-- RESIZE HANDLE
--==================================================

local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.fromOffset(16, 16)
resizeHandle.Position = UDim2.new(1, -16, 1, -16)
resizeHandle.BackgroundColor3 = COLORS.stroke
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = ""
resizeHandle.AutoButtonColor = false
resizeHandle.Active = true
resizeHandle.ZIndex = 30
resizeHandle.Parent = frame

local resizeCorner = Instance.new("UICorner")
resizeCorner.CornerRadius = UDim.new(0, 4)
resizeCorner.Parent = resizeHandle

local MIN_WIDTH = 250
local MIN_HEIGHT = 210

local resizing = false
local resizeStart = nil
local resizeStartSize = nil

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStart = input.Position
		resizeStartSize = frame.AbsoluteSize
	end
end)

--==================================================
-- REOPEN BUTTON
--==================================================

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "Reopen"
reopenButton.Size = UDim2.fromOffset(50, 50)
reopenButton.Position = UDim2.new(0, 15, 0.5, -25)
reopenButton.BackgroundColor3 = COLORS.header
reopenButton.BorderSizePixel = 0
reopenButton.Text = "MM2"
reopenButton.TextColor3 = COLORS.textBright
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

--==================================================
-- CONTENT CONTAINER + TAB BAR
--==================================================

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -20, 1, -58)
contentContainer.Position = UDim2.fromOffset(10, 53)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = frame

local TAB_ROW_HEIGHT = 22
local TAB_ROW_GAP = 2
local TAB_BAR_HEIGHT = TAB_ROW_HEIGHT * 2 + TAB_ROW_GAP * 2

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, TAB_BAR_HEIGHT)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.Parent = contentContainer

local body = Instance.new("ScrollingFrame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -(TAB_BAR_HEIGHT + 4))
body.Position = UDim2.fromOffset(0, TAB_BAR_HEIGHT + 4)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 5
body.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.CanvasSize = UDim2.fromOffset(0, 0)
body.ElasticBehavior = Enum.ElasticBehavior.Never
body.Parent = contentContainer

--==================================================
-- TABS
--==================================================

local TAB_LIST = {
	{ Key = "Movement", Label = "Move", Color = COLORS.blue },
	{ Key = "ESP", Label = "ESP", Color = COLORS.red },
	{ Key = "Notify", Label = "Chat", Color = COLORS.gold },
	{ Key = "Murderer", Label = "Kill", Color = COLORS.red },
	{ Key = "Sheriff", Label = "Sheriff", Color = COLORS.blue },
	{ Key = "Teleport", Label = "TP", Color = COLORS.purple },
	{ Key = "Utility", Label = "Util", Color = COLORS.green },
	{ Key = "Keys", Label = "Keys", Color = Color3.fromRGB(130, 140, 160) },
}

local pages = {}
local tabButtons = {}
local currentTab = nil
local currentPage = nil

local function createPage(key)
	local page = Instance.new("Frame")
	page.Name = key
	page.Size = UDim2.new(1, 0, 0, 0)
	page.AutomaticSize = Enum.AutomaticSize.Y
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = body

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	pages[key] = { Frame = page, Layout = layout }
	return page
end

for _, tab in ipairs(TAB_LIST) do
	createPage(tab.Key)
end

local function createTabButton(tab, index)
	local column = index % 4
	local row = math.floor(index / 4)

	local button = Instance.new("TextButton")
	button.Name = "Tab_" .. tab.Key
	button.Size = UDim2.new(0.25, -3, 0, TAB_ROW_HEIGHT)
	button.Position = UDim2.new(column * 0.25, 1, 0, row * (TAB_ROW_HEIGHT + TAB_ROW_GAP))
	button.BackgroundColor3 = COLORS.row
	button.BorderSizePixel = 0
	button.Text = tab.Label
	button.TextColor3 = COLORS.textDim
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = tabBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	attachRowHover(button)

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Size = UDim2.new(1, -14, 0, 2)
	accent.Position = UDim2.new(0.5, 0, 1, -3)
	accent.BackgroundColor3 = tab.Color
	accent.BackgroundTransparency = 1
	accent.BorderSizePixel = 0
	accent.Parent = button

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = accent

	tabButtons[tab.Key] = { Button = button, Accent = accent, Color = tab.Color }
	return button
end

local function updateCanvas()
	if not currentTab or not pages[currentTab] then return end
	local layout = pages[currentTab].Layout
	body.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
end

local function selectTab(key)
	if currentTab == key then return end

	for pageKey, page in pairs(pages) do
		page.Frame.Visible = pageKey == key
	end

	for tabKey, tab in pairs(tabButtons) do
		local active = tabKey == key
		if active then
			setRowColor(tab.Button, tab.Color:Lerp(COLORS.bg, 0.68))
			tweenColor(tab.Button, "TextColor3", tab.Color, 0.1)
		else
			setRowColor(tab.Button, COLORS.row)
			tweenColor(tab.Button, "TextColor3", COLORS.textDim, 0.1)
		end
		tweenColor(tab.Accent, "BackgroundTransparency", active and 0 or 1, 0.1)
	end

	currentTab = key
	currentPage = pages[key].Frame
	body.CanvasPosition = Vector2.new(0, 0)
	updateCanvas()
	task.defer(updateCanvas)
end

for index, tab in ipairs(TAB_LIST) do
	local tabButton = createTabButton(tab, index - 1)
	tabButton.MouseButton1Click:Connect(function() selectTab(tab.Key) end)
end

for _, page in pairs(pages) do
	page.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if pages[currentTab] == page then updateCanvas() end
	end)
end

local function useTab(key)
	selectTab(key)
	return pages[key].Frame
end

--==================================================
-- CONTROL HELPERS
--==================================================

local currentLayoutOrder = 0
local function getLayoutOrder()
	currentLayoutOrder = currentLayoutOrder + 1
	return currentLayoutOrder
end

local function createSectionLabel(text)
	local label = Instance.new("TextLabel")
	label.Name = text .. "Header"
	label.Size = UDim2.new(1, 0, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.textDim
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = getLayoutOrder()
	label.Parent = currentPage
	return label
end

local function styleRow(button)
	button.BackgroundColor3 = COLORS.row
	button.BorderSizePixel = 0
	button.TextColor3 = COLORS.text
	button.TextSize = 12
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	attachRowHover(button)
end

local function createToggle(name, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 34)
	button.Text = text
	button.LayoutOrder = getLayoutOrder()
	button.Parent = currentPage
	styleRow(button)

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(5, 18)
	indicator.Position = UDim2.fromOffset(8, 8)
	indicator.BackgroundColor3 = COLORS.offIndicator
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
	button.Size = UDim2.new(1, 0, 0, 34)
	button.Text = text
	button.LayoutOrder = getLayoutOrder()
	button.Parent = currentPage
	styleRow(button)

	return button
end

local function createInfoLabel(text)
	local label = Instance.new("TextLabel")
	label.Name = "Info"
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.textDim
	label.TextSize = 10
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.LayoutOrder = getLayoutOrder()
	label.Parent = currentPage
	return label
end

local function createNumberRow(name, minValue, maxValue, step, initialValue, onChanged)
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundTransparency = 1
	row.LayoutOrder = getLayoutOrder()
	row.Parent = currentPage

	local minus = Instance.new("TextButton")
	minus.Name = "Minus"
	minus.Size = UDim2.fromOffset(34, 32)
	minus.BackgroundColor3 = COLORS.row
	minus.BorderSizePixel = 0
	minus.Text = "-"
	minus.TextColor3 = COLORS.text
	minus.TextSize = 18
	minus.Font = Enum.Font.GothamBold
	minus.AutoButtonColor = false
	minus.Parent = row

	local minusCorner = Instance.new("UICorner")
	minusCorner.CornerRadius = UDim.new(0, 7)
	minusCorner.Parent = minus

	local box = Instance.new("TextBox")
	box.Name = "Value"
	box.Size = UDim2.fromOffset(52, 32)
	box.Position = UDim2.fromOffset(40, 0)
	box.BackgroundColor3 = COLORS.row
	box.BorderSizePixel = 0
	box.Text = tostring(initialValue)
	box.TextColor3 = COLORS.text
	box.TextSize = 12
	box.Font = Enum.Font.GothamSemibold
	box.ClearTextOnFocus = false
	box.Parent = row

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 7)
	boxCorner.Parent = box

	local plus = Instance.new("TextButton")
	plus.Name = "Plus"
	plus.Size = UDim2.fromOffset(34, 32)
	plus.Position = UDim2.fromOffset(98, 0)
	plus.BackgroundColor3 = COLORS.row
	plus.BorderSizePixel = 0
	plus.Text = "+"
	plus.TextColor3 = COLORS.text
	plus.TextSize = 18
	plus.Font = Enum.Font.GothamBold
	plus.AutoButtonColor = false
	plus.Parent = row

	local plusCorner = Instance.new("UICorner")
	plusCorner.CornerRadius = UDim.new(0, 7)
	plusCorner.Parent = plus

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -142, 0, 32)
	label.Position = UDim2.fromOffset(140, 0)
	label.BackgroundTransparency = 1
	label.Text = ""
	label.TextColor3 = COLORS.textDim
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = row

	local value = initialValue

	local function apply(newValue)
		newValue = tonumber(newValue)
		if not newValue then newValue = value end
		newValue = math.clamp(math.floor(newValue), minValue, maxValue)
		value = newValue
		box.Text = tostring(value)
		onChanged(value)
	end

	minus.MouseButton1Click:Connect(function() apply(value - step) end)
	plus.MouseButton1Click:Connect(function() apply(value + step) end)
	box.FocusLost:Connect(function() apply(box.Text) end)

	return {
		Row = row,
		Box = box,
		Label = label,
		Get = function() return value end,
		Set = function(newValue) apply(newValue) end,
	}
end

local function setToggleOn(button, indicator)
	setRowColor(button, COLORS.rowActive)
	tweenColor(indicator, "BackgroundColor3", COLORS.green, 0.1)
end

local function setToggleOff(button, indicator)
	setRowColor(button, COLORS.row)
	tweenColor(indicator, "BackgroundColor3", COLORS.offIndicator, 0.1)
end

--==================================================
-- KEYBIND REGISTRY
--==================================================

local keybindRegistry = {}
local keybindRows = {}

local function updateKeybindLabel(entry)
	local suffix = entry.KeyLabel or "None"
	if entry.Button then
		entry.Button.Text = entry.BaseText .. "  [" .. suffix .. "]"
		entry.Button.TextSize = entry.BaseText:len() > 14 and 10 or 12
	end
	local row = keybindRows[entry.Name]
	if row then
		row.Value.Text = suffix
		row.Value.TextColor3 = entry.KeyLabel and COLORS.gold or COLORS.offIndicator
	end
end

local function registerKeybind(name, button, getState, toggleFn)
	local entry = {
		Name = name,
		Button = button,
		GetState = getState,
		Toggle = toggleFn,
		Key = nil,
		KeyLabel = nil,
		BaseText = button and button.Text or name,
	}
	keybindRegistry[name] = entry
	updateKeybindLabel(entry)
	return entry
end

local function clearKeybind(name)
	local entry = keybindRegistry[name]
	if not entry then return end
	entry.Key = nil
	entry.KeyLabel = nil
	updateKeybindLabel(entry)
end

local function setKeybind(name, keyCode)
	for otherName, other in pairs(keybindRegistry) do
		if otherName ~= name and other.Key == keyCode then
			other.Key = nil
			other.KeyLabel = nil
			updateKeybindLabel(other)
		end
	end

	local entry = keybindRegistry[name]
	if not entry then return end
	entry.Key = keyCode
	entry.KeyLabel = keyCode.Name
	updateKeybindLabel(entry)
end

--==================================================
-- TAB 1 — MOVEMENT
--==================================================

useTab("Movement")

-- NOCLIP
local noclipButton, noclipIndicator = createToggle("Noclip", "Noclip")

local function setCollisionDisabled(disabled)
	local character = player.Character
	if not character then return end

	if disabled then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") and originalCollision[object] == nil then
				originalCollision[object] = object.CanCollide
			end
		end
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			local previous = originalCollision[object]
			if disabled then
				object.CanCollide = false
			elseif previous ~= nil then
				object.CanCollide = previous
			else
				object.CanCollide = true
			end
		end
	end

	if not disabled then originalCollision = {} end
end

local function toggleNoclip()
	noclip = not noclip
	setCollisionDisabled(noclip)
	if noclip then setToggleOn(noclipButton, noclipIndicator) else setToggleOff(noclipButton, noclipIndicator) end
end

noclipButton.MouseButton1Click:Connect(toggleNoclip)
registerKeybind("Noclip", noclipButton, function() return noclip end, toggleNoclip)

-- FLY
local flyButton, flyIndicator = createToggle("Fly", "Fly")

local flyPanel = Instance.new("Frame")
flyPanel.Name = "FlyPanel"
flyPanel.Size = UDim2.fromOffset(210, 236)
flyPanel.Position = UDim2.new(0.5, 150, 0.5, -118)
flyPanel.BackgroundColor3 = COLORS.bg
flyPanel.BorderSizePixel = 0
flyPanel.Visible = false
flyPanel.Active = true
flyPanel.ZIndex = 20
flyPanel.Parent = gui

local flyPanelCorner = Instance.new("UICorner")
flyPanelCorner.CornerRadius = UDim.new(0, 12)
flyPanelCorner.Parent = flyPanel

local flyPanelStroke = Instance.new("UIStroke")
flyPanelStroke.Color = COLORS.stroke
flyPanelStroke.Thickness = 1
flyPanelStroke.Parent = flyPanel

local flyHeader = Instance.new("Frame")
flyHeader.Name = "Header"
flyHeader.Size = UDim2.new(1, 0, 0, 42)
flyHeader.BackgroundColor3 = COLORS.header
flyHeader.BorderSizePixel = 0
flyHeader.ZIndex = 21
flyHeader.Parent = flyPanel

local flyHeaderCorner = Instance.new("UICorner")
flyHeaderCorner.CornerRadius = UDim.new(0, 12)
flyHeaderCorner.Parent = flyHeader

local flyTitle = Instance.new("TextLabel")
flyTitle.Name = "Title"
flyTitle.Size = UDim2.new(1, -20, 1, 0)
flyTitle.Position = UDim2.fromOffset(10, 0)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "FLY"
flyTitle.TextColor3 = COLORS.textBright
flyTitle.TextSize = 13
flyTitle.Font = Enum.Font.GothamBold
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.TextYAlignment = Enum.TextYAlignment.Center
flyTitle.ZIndex = 22
flyTitle.Parent = flyHeader

local flyEnableButton = Instance.new("TextButton")
flyEnableButton.Name = "Enable"
flyEnableButton.Size = UDim2.new(1, -20, 0, 34)
flyEnableButton.Position = UDim2.fromOffset(10, 52)
flyEnableButton.Text = "Enable Fly"
flyEnableButton.ZIndex = 21
flyEnableButton.Parent = flyPanel
styleRow(flyEnableButton)

local flyEnableIndicator = Instance.new("Frame")
flyEnableIndicator.Name = "Indicator"
flyEnableIndicator.Size = UDim2.fromOffset(5, 18)
flyEnableIndicator.Position = UDim2.fromOffset(8, 8)
flyEnableIndicator.BackgroundColor3 = COLORS.offIndicator
flyEnableIndicator.BorderSizePixel = 0
flyEnableIndicator.ZIndex = 22
flyEnableIndicator.Parent = flyEnableButton

local flyEnableIndicatorCorner = Instance.new("UICorner")
flyEnableIndicatorCorner.CornerRadius = UDim.new(1, 0)
flyEnableIndicatorCorner.Parent = flyEnableIndicator

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Name = "SpeedLabel"
flySpeedLabel.Size = UDim2.new(1, -20, 0, 20)
flySpeedLabel.Position = UDim2.fromOffset(10, 96)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Speed: " .. tostring(flySpeed)
flySpeedLabel.TextColor3 = COLORS.textDim
flySpeedLabel.TextSize = 11
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.ZIndex = 21
flySpeedLabel.Parent = flyPanel

local function createFlyStepButton(name, text, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(36, 32)
	button.Position = position
	button.Text = text
	button.ZIndex = 21
	button.Parent = flyPanel
	styleRow(button)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	return button
end

local flyMinus = createFlyStepButton("Minus", "-", UDim2.fromOffset(10, 121))
local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Name = "Speed"
flySpeedBox.Size = UDim2.new(1, -96, 0, 32)
flySpeedBox.Position = UDim2.fromOffset(52, 121)
flySpeedBox.BackgroundColor3 = COLORS.row
flySpeedBox.BorderSizePixel = 0
flySpeedBox.Text = tostring(flySpeed)
flySpeedBox.TextColor3 = COLORS.text
flySpeedBox.TextSize = 12
flySpeedBox.Font = Enum.Font.GothamSemibold
flySpeedBox.ClearTextOnFocus = false
flySpeedBox.ZIndex = 21
flySpeedBox.Parent = flyPanel

local flySpeedBoxCorner = Instance.new("UICorner")
flySpeedBoxCorner.CornerRadius = UDim.new(0, 7)
flySpeedBoxCorner.Parent = flySpeedBox

local flyPlus = createFlyStepButton("Plus", "+", UDim2.new(1, -46, 0, 121))

local flyUp = createFlyStepButton("Up", "UP", UDim2.fromOffset(10, 168))
flyUp.Size = UDim2.fromOffset(85, 32)
flyUp.TextSize = 12
local flyDown = createFlyStepButton("Down", "DOWN", UDim2.new(1, -95, 0, 168))
flyDown.Size = UDim2.fromOffset(85, 32)
flyDown.TextSize = 12

local function updateFlySpeed(value)
	value = tonumber(value)
	if not value then value = flySpeed end
	value = math.clamp(math.floor(value), 1, 500)
	flySpeed = value
	flyMaxSpeed = value
	flyCurrentSpeed = 0
	flySpeedLabel.Text = "Speed: " .. tostring(flySpeed)
	flySpeedBox.Text = tostring(flySpeed)
end

flyMinus.MouseButton1Click:Connect(function() updateFlySpeed(flySpeed - 5) end)
flyPlus.MouseButton1Click:Connect(function() updateFlySpeed(flySpeed + 5) end)
flySpeedBox.FocusLost:Connect(function() updateFlySpeed(flySpeedBox.Text) end)

local function stopFly()
	flyEnabled = false
	if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
	flyCurrentSpeed = 0
	flyLastUpdate = 0

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
			for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
				pcall(function() humanoid:SetStateEnabled(state, true) end)
			end
			humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		end
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = false end
	end

	if flyEnableButton then
		flyEnableButton.Text = "Enable Fly"
		setToggleOff(flyEnableButton, flyEnableIndicator)
	end
	if flyButton then setToggleOff(flyButton, flyIndicator) end
end

local function startFly()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	stopFly()
	flyEnabled = true
	flySpeed = flyMaxSpeed
	flyCurrentSpeed = 0
	flyLastUpdate = tick()

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.P = 90000
	flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
	flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBodyVelocity.Parent = root

	humanoid.PlatformStand = true
	local animate = character:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(0)
	end

	for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
		pcall(function() humanoid:SetStateEnabled(state, false) end)
	end
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	flyEnableButton.Text = "Disable Fly"
	setToggleOn(flyEnableButton, flyEnableIndicator)
	setToggleOn(flyButton, flyIndicator)
end

local function toggleFlyEngine()
	if flyEnabled then stopFly() else startFly() end
end

flyEnableButton.MouseButton1Click:Connect(toggleFlyEngine)

local function toggleFlyPanel()
	flyPanelOpen = not flyPanelOpen
	flyPanel.Visible = flyPanelOpen
	if flyPanelOpen then
		setRowColor(flyButton, COLORS.rowHover)
	elseif flyEnabled then
		setToggleOn(flyButton, flyIndicator)
	else
		setToggleOff(flyButton, flyIndicator)
	end
end

flyButton.MouseButton1Click:Connect(toggleFlyPanel)
registerKeybind("Fly", flyButton, function() return flyEnabled end, toggleFlyEngine)

-- INFINITY JUMP
local infinityJumpButton, infinityJumpIndicator = createToggle("InfinityJump", "Infinity Jump")

local function toggleInfinityJump()
	infinityJump = not infinityJump
	if infinityJump then setToggleOn(infinityJumpButton, infinityJumpIndicator)
	else setToggleOff(infinityJumpButton, infinityJumpIndicator) end
end

infinityJumpButton.MouseButton1Click:Connect(toggleInfinityJump)
registerKeybind("Infinity Jump", infinityJumpButton, function() return infinityJump end, toggleInfinityJump)

-- FLY MOVEMENT
UserInputService.InputBegan:Connect(function(input, processed)
	if not scriptActive or processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	if bindCaptureName then return end

	if input.KeyCode == Enum.KeyCode.W then flyControls.f = 1
	elseif input.KeyCode == Enum.KeyCode.S then flyControls.b = -1
	elseif input.KeyCode == Enum.KeyCode.A then flyControls.l = -1
	elseif input.KeyCode == Enum.KeyCode.D then flyControls.r = 1
	elseif input.KeyCode == Enum.KeyCode.Space then flyControls.up = 1
	elseif input.KeyCode == Enum.KeyCode.LeftControl then flyControls.down = -1
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then flyControls.f = 0
	elseif input.KeyCode == Enum.KeyCode.S then flyControls.b = 0
	elseif input.KeyCode == Enum.KeyCode.A then flyControls.l = 0
	elseif input.KeyCode == Enum.KeyCode.D then flyControls.r = 0
	elseif input.KeyCode == Enum.KeyCode.Space then flyControls.up = 0
	elseif input.KeyCode == Enum.KeyCode.LeftControl then flyControls.down = 0
	end
end)

RunService.RenderStepped:Connect(function()
	if not scriptActive then return end
	if not flyEnabled or not flyBodyVelocity or not flyBodyGyro then return end

	local character = player.Character
	if not character then stopFly() return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not humanoid or not root or not camera then return end

	local mobileMove = humanoid.MoveDirection
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local up = Vector3.new(0, 1, 0)

	local keyboardForward = flyControls.f + flyControls.b
	local keyboardRight = flyControls.l + flyControls.r
	local keyboardVertical = flyControls.up + flyControls.down

	local horizontalLook = Vector3.new(look.X, 0, look.Z)
	local horizontalRight = Vector3.new(right.X, 0, right.Z)
	if horizontalLook.Magnitude > 0 then horizontalLook = horizontalLook.Unit end
	if horizontalRight.Magnitude > 0 then horizontalRight = horizontalRight.Unit end

	local mobileForward, mobileRight = 0, 0
	if mobileMove.Magnitude > 0 then
		mobileForward = mobileMove:Dot(horizontalLook)
		mobileRight = mobileMove:Dot(horizontalRight)
	end

	local forward = math.clamp(keyboardForward + mobileForward, -1, 1)
	local rightAmount = math.clamp(keyboardRight + mobileRight, -1, 1)
	local vertical = math.clamp(keyboardVertical, -1, 1)
	local moving = math.abs(forward) > 0.01 or math.abs(rightAmount) > 0.01 or math.abs(vertical) > 0.01

	local now = tick()
	local dt = flyLastUpdate > 0 and math.clamp(now - flyLastUpdate, 0, 0.1) or 0
	flyLastUpdate = now

	if moving then
		flyCurrentSpeed = math.min(flyCurrentSpeed + flyMaxSpeed * (dt / flyAccelTime), flyMaxSpeed)
	else
		flyCurrentSpeed = math.max(flyCurrentSpeed - flyMaxSpeed * (dt / flyDecelTime), 0)
	end

	local direction = look * forward + right * rightAmount + up * vertical
	if direction.Magnitude > 0 then
		direction = direction.Unit
		flyBodyVelocity.Velocity = direction * flyCurrentSpeed
		lastFlyControls.f = forward
		lastFlyControls.b = 0
		lastFlyControls.l = rightAmount
		lastFlyControls.r = 0
		lastFlyControls.up = vertical
		lastFlyControls.down = 0
	elseif flyCurrentSpeed > 0 then
		local lastDirection = look * (lastFlyControls.f + lastFlyControls.b)
			+ right * (lastFlyControls.l + lastFlyControls.r)
			+ up * (lastFlyControls.up + lastFlyControls.down)
		if lastDirection.Magnitude > 0 then
			flyBodyVelocity.Velocity = lastDirection.Unit * flyCurrentSpeed
		else
			flyBodyVelocity.Velocity = Vector3.zero
		end
	else
		flyBodyVelocity.Velocity = Vector3.zero
	end

	flyBodyGyro.CFrame = camera.CFrame * CFrame.Angles(
		-math.rad(forward * 50 * (flyCurrentSpeed / math.max(flyMaxSpeed, 1))), 0, 0
	)
	humanoid.PlatformStand = true
end)

flyUp.MouseButton1Down:Connect(function() flyControls.up = 1 end)
flyUp.MouseButton1Up:Connect(function() flyControls.up = 0 end)
flyDown.MouseButton1Down:Connect(function() flyControls.down = -1 end)
flyDown.MouseButton1Up:Connect(function() flyControls.down = 0 end)

-- FLING ON TOUCH
local flingOnTouchButton, flingOnTouchIndicator = createToggle("FlingOnTouch", "Fling On Touch")

local flingTouchThread = nil

local function flingOnTouchLoop()
	local movel = 0.1
	while flingTouchActive and scriptActive do
		RunService.Heartbeat:Wait()
		local hrp = getMyRoot()
		if hrp then
			local vel = hrp.AssemblyLinearVelocity
			hrp.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
			RunService.RenderStepped:Wait()
			hrp.AssemblyLinearVelocity = vel
			RunService.Stepped:Wait()
			hrp.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

local function setFlingVisual(button, indicator, enabled)
	if enabled then
		setRowColor(button, COLORS.rowFling)
		tweenColor(indicator, "BackgroundColor3", COLORS.orange, 0.1)
	else
		setToggleOff(button, indicator)
	end
end

local function toggleFlingOnTouch()
	flingOnTouch = not flingOnTouch
	setFlingVisual(flingOnTouchButton, flingOnTouchIndicator, flingOnTouch)
	if flingOnTouch then
		flingTouchActive = true
		flingTouchThread = coroutine.create(flingOnTouchLoop)
		coroutine.resume(flingTouchThread)
	else
		flingTouchActive = false
		flingTouchThread = nil
	end
end

flingOnTouchButton.MouseButton1Click:Connect(toggleFlingOnTouch)
registerKeybind("Fling On Touch", flingOnTouchButton, function() return flingOnTouch end, toggleFlingOnTouch)

-- FLING 3RD PARTY
local flingThirdPartyButton, flingThirdPartyIndicator = createToggle("FlingThirdParty", "Fling 3rd Party")

local function toggleFlingThirdParty()
	flingThirdParty = not flingThirdParty
	if flingThirdParty then
		setFlingVisual(flingThirdPartyButton, flingThirdPartyIndicator, true)
		task.spawn(function()
			local success, err = pcall(function()
				loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Ultimate-Fling-GUI-41909"))()
			end)
			if not success then
				flingThirdParty = false
				setFlingVisual(flingThirdPartyButton, flingThirdPartyIndicator, false)
				sendNotification("MM2 Menu", "Failed to load 3rd party fling script.\n" .. tostring(err))
			end
		end)
	else
		setFlingVisual(flingThirdPartyButton, flingThirdPartyIndicator, false)
	end
end

flingThirdPartyButton.MouseButton1Click:Connect(toggleFlingThirdParty)
registerKeybind("Fling 3rd Party", flingThirdPartyButton, function() return flingThirdParty end, toggleFlingThirdParty)

-- SPEEDHACK
local speedhackButton, speedhackIndicator = createToggle("Speedhack", "Speedhack")

local speedhackRow = createNumberRow("SpeedhackRow", SPEEDHACK_MIN, SPEEDHACK_MAX, 5, speedhackSpeed, function(value)
	speedhackSpeed = value
	if value > SPEEDHACK_SAFE then
		speedhackRow.Label.Text = "Kick risk above " .. SPEEDHACK_SAFE
		speedhackRow.Label.TextColor3 = COLORS.red
	else
		speedhackRow.Label.Text = "WalkSpeed: " .. tostring(value)
		speedhackRow.Label.TextColor3 = COLORS.textDim
	end
	if speedhackEnabled then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = speedhackSpeed end
		end
	end
end)
speedhackRow.Label.Text = "WalkSpeed: " .. tostring(speedhackSpeed)

local function applyWalkSpeed(value)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = value end
end

local function toggleSpeedhack()
	speedhackEnabled = not speedhackEnabled
	if speedhackEnabled then
		setToggleOn(speedhackButton, speedhackIndicator)
		applyWalkSpeed(speedhackSpeed)
		if speedhackSpeed > SPEEDHACK_SAFE then
			sendNotification("MM2 Menu", "WalkSpeed above " .. SPEEDHACK_SAFE .. " can trigger invalid position kicks.")
		end
	else
		setToggleOff(speedhackButton, speedhackIndicator)
		applyWalkSpeed(SPEEDHACK_DEFAULT)
	end
end

speedhackButton.MouseButton1Click:Connect(toggleSpeedhack)
registerKeybind("Speedhack", speedhackButton, function() return speedhackEnabled end, toggleSpeedhack)

createInfoLabel("WalkSpeed above " .. SPEEDHACK_SAFE .. " can trigger invalid position kicks. Capped at " .. SPEEDHACK_MAX .. ".")

RunService.RenderStepped:Connect(function()
	if not scriptActive then return end
	if not speedhackEnabled then return end
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.WalkSpeed ~= speedhackSpeed then
		humanoid.WalkSpeed = speedhackSpeed
	end
end)

-- NOCLIP LOOP
RunService.Stepped:Connect(function()
	if not scriptActive then return end
	if not noclip or not player.Character then return end
	for _, object in ipairs(player.Character:GetDescendants()) do
		if object:IsA("BasePart") then object.CanCollide = false end
	end
end)

--==================================================
-- TAB 2 — ESP
--==================================================

useTab("ESP")

createSectionLabel("ROLE ESP")

local espButtons = {}

local function createESPButton(role)
	local button, indicator = createToggle(role .. "ESP", role .. " ESP")
	espButtons[role] = { Button = button, Indicator = indicator }

	local function toggle()
		espEnabled[role] = not espEnabled[role]
		if espEnabled[role] then
			setRowColor(button, ROLE_COLORS[role]:Lerp(Color3.fromRGB(20, 20, 25), 0.65))
			tweenColor(indicator, "BackgroundColor3", ROLE_COLORS[role], 0.1)
		else
			setToggleOff(button, indicator)
		end
	end

	button.MouseButton1Click:Connect(toggle)
	registerKeybind(role .. " ESP", button, function() return espEnabled[role] end, toggle)
end

createESPButton("Innocent")
createESPButton("Murderer")
createESPButton("Sheriff")
createESPButton("Hero")

createSectionLabel("GUN ESP")

local gunESPButton, gunESPIndicator = createToggle("GunESP", "Gun ESP")

local function toggleGunESP()
	gunESPEnabled = not gunESPEnabled
	if gunESPEnabled then
		setToggleOn(gunESPButton, gunESPIndicator)
	else
		setToggleOff(gunESPButton, gunESPIndicator)
	end
end

gunESPButton.MouseButton1Click:Connect(toggleGunESP)
registerKeybind("Gun ESP", gunESPButton, function() return gunESPEnabled end, toggleGunESP)

createSectionLabel("DISTANCE")

local distanceButton, distanceIndicator = createToggle("Distance", "Player Distance (studs)")

local function toggleDistance()
	showDistance = not showDistance
	if showDistance then
		setToggleOn(distanceButton, distanceIndicator)
	else
		setToggleOff(distanceButton, distanceIndicator)
	end
end

distanceButton.MouseButton1Click:Connect(toggleDistance)
registerKeybind("Distance", distanceButton, function() return showDistance end, toggleDistance)

--==================================================
-- TAB 3 — NOTIFY / CHAT
--==================================================

useTab("Notify")

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "RoleStatus"
statusLabel.Size = UDim2.new(1, 0, 0, 62)
statusLabel.BackgroundColor3 = COLORS.header
statusLabel.BorderSizePixel = 0
statusLabel.TextColor3 = COLORS.text
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.LayoutOrder = getLayoutOrder()
statusLabel.Parent = currentPage

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local statusPadding = Instance.new("UIPadding")
statusPadding.PaddingLeft = UDim.new(0, 10)
statusPadding.Parent = statusLabel

updateRoleStatusLabel = function()
	statusLabel.Text = getFormattedRoleText("Murderer", MurdererName)
		.. "\n" .. getFormattedRoleText("Sheriff", SheriffName)
		.. "\n" .. getFormattedRoleText("Hero", HeroName)
end
updateRoleStatusLabel()

createSectionLabel("CHAT ACTIONS")

local sendMurdererChatButton = createActionButton("SendMurdererChat", "Send Murderer In Chat")
sendMurdererChatButton.MouseButton1Click:Connect(function()
	announceRoleChat("Murderer", MurdererName)
end)

local sendSheriffChatButton = createActionButton("SendSheriffChat", "Send Sheriff In Chat")
sendSheriffChatButton.MouseButton1Click:Connect(function()
	announceRoleChat("Sheriff", SheriffName)
end)

createSectionLabel("CHAT AUTOMATION")

local autoMurdererChatButton, autoMurdererChatIndicator = createToggle("AutoMurdererChat", "Auto Send Murderer In Chat")

local function toggleAutoMurdererChat()
	autoSendMurdererChat = not autoSendMurdererChat
	lastChatSentMurderer = nil
	if autoSendMurdererChat then setToggleOn(autoMurdererChatButton, autoMurdererChatIndicator)
	else setToggleOff(autoMurdererChatButton, autoMurdererChatIndicator) end
end

autoMurdererChatButton.MouseButton1Click:Connect(toggleAutoMurdererChat)
registerKeybind("Auto Murderer Chat", autoMurdererChatButton, function() return autoSendMurdererChat end, toggleAutoMurdererChat)

local autoSheriffChatButton, autoSheriffChatIndicator = createToggle("AutoSheriffChat", "Auto Send Sheriff In Chat")

local function toggleAutoSheriffChat()
	autoSendSheriffChat = not autoSendSheriffChat
	lastChatSentSheriff = nil
	if autoSendSheriffChat then setToggleOn(autoSheriffChatButton, autoSheriffChatIndicator)
	else setToggleOff(autoSheriffChatButton, autoSheriffChatIndicator) end
end

autoSheriffChatButton.MouseButton1Click:Connect(toggleAutoSheriffChat)
registerKeybind("Auto Sheriff Chat", autoSheriffChatButton, function() return autoSendSheriffChat end, toggleAutoSheriffChat)

createSectionLabel("NOTIFICATIONS")

local notifyRolesButton = createActionButton("NotifyRoles", "Notify Roles")
notifyRolesButton.MouseButton1Click:Connect(function()
	notifyAllRoles()
end)

local autoNotifyButton, autoNotifyIndicator = createToggle("AutoNotifyRound", "Auto Notify Round")

local function toggleAutoNotify()
	autoNotifyRoles = not autoNotifyRoles
	if autoNotifyRoles then
		setToggleOn(autoNotifyButton, autoNotifyIndicator)
		lastNotifiedMurderer = nil
		lastNotifiedSheriff = nil
		lastNotifiedHero = nil
	else
		setToggleOff(autoNotifyButton, autoNotifyIndicator)
	end
end

autoNotifyButton.MouseButton1Click:Connect(toggleAutoNotify)
registerKeybind("Auto Notify", autoNotifyButton, function() return autoNotifyRoles end, toggleAutoNotify)

--==================================================
-- TAB 4 — MURDERER / KILL
--==================================================

useTab("Murderer")

local function getKnife()
	local character = player.Character
	if not character then return nil end

	local knife = character:FindFirstChild("Knife")
	if not knife then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			knife = backpack:FindFirstChild("Knife")
			if knife then knife.Parent = character end
		end
	end
	return knife
end

local function attackTarget(target)
	if not target or target == player or not target.Character then return false end
	if not isPlayerAlive(target) then return false end
	if isPlayerInSpawn(target) then return false end

	local myRoot = getMyRoot()
	if not myRoot then return false end

	local knife = getKnife()
	if not knife then return false end

	for attempt = 1, 2 do
		local targetRoot = getPlayerRoot(target)
		if not targetRoot or not isPlayerAlive(target) then return true end

		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.6)
		if attempt == 1 then task.wait(0.06) end

		if knife.Parent ~= player.Character then knife.Parent = player.Character end
		pcall(function() knife:Activate() end)

		if attempt == 1 then task.wait(0.14) end
	end

	return not isPlayerAlive(target)
end

local function collectKillableTargets()
	local targets = {}
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and isPlayerAlive(target) and not isPlayerInSpawn(target) then
			table.insert(targets, target)
		end
	end
	return targets
end

local function killAllPlayers(silent)
	if killAllRunning then return end
	killAllRunning = true

	local startPosition = getMyRoot() and getMyRoot().CFrame

	for pass = 1, KILL_ALL_PASSES do
		local targets = collectKillableTargets()
		if #targets == 0 then break end

		for _, target in ipairs(targets) do
			if isPlayerAlive(target) then
				attackTarget(target)
			end
			task.wait(0.12)
		end
		task.wait(0.4)
	end

	local remaining = #collectKillableTargets()
	if remaining == 0 and startPosition then
		local myRoot = getMyRoot()
		if myRoot then myRoot.CFrame = startPosition end
	end

	killAllRunning = false

	if not silent then
		sendNotification("MM2 Menu", remaining == 0 and "Kill all complete." or ("Kill all finished, " .. remaining .. " still alive."))
	end
end

local autoKillButton, autoKillIndicator = createToggle("AutoKillAll", "Auto Kill All")

local function toggleAutoKill()
	autoKillAll = not autoKillAll
	if autoKillAll then setToggleOn(autoKillButton, autoKillIndicator)
	else setToggleOff(autoKillButton, autoKillIndicator) end
end

autoKillButton.MouseButton1Click:Connect(toggleAutoKill)
registerKeybind("Auto Kill All", autoKillButton, function() return autoKillAll end, toggleAutoKill)

createSectionLabel("ACTIONS")

local killAllButton = createActionButton("KillAllNow", "Kill All Now")
killAllButton.MouseButton1Click:Connect(function()
	task.spawn(function() killAllPlayers(false) end)
end)

local function killRoleNow(roleName, name)
	if not name then
		sendNotification("MM2 Menu", roleName .. " not found yet!")
		return
	end
	local target = Players:FindFirstChild(name)
	if not target or not target.Character then
		sendNotification("MM2 Menu", roleName .. " is not available.")
		return
	end
	if not isPlayerAlive(target) then
		sendNotification("MM2 Menu", roleName .. " is already dead.")
		return
	end
	if isPlayerInSpawn(target) then
		sendNotification("MM2 Menu", roleName .. " is in spawn/lobby.")
		return
	end
	attackTarget(target)
	sendNotification("MM2 Menu", isPlayerAlive(target) and (roleName .. " survived.") or (roleName .. " eliminated."))
end

local killSheriffButton = createActionButton("KillSheriffNow", "Kill Sheriff Now")
killSheriffButton.MouseButton1Click:Connect(function()
	killRoleNow("Sheriff", SheriffName)
end)

local killHeroButton = createActionButton("KillHeroNow", "Kill Hero Now")
killHeroButton.MouseButton1Click:Connect(function()
	killRoleNow("Hero", HeroName)
end)

createInfoLabel("Kill All runs up to " .. KILL_ALL_PASSES .. " passes so nobody is missed.")

--==================================================
-- TAB 5 — SHERIFF
--==================================================

useTab("Sheriff")

local function getGun()
	local character = player.Character
	if not character then return nil end

	local gun = character:FindFirstChild("Gun")
	if not gun then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			gun = backpack:FindFirstChild("Gun")
			if gun then gun.Parent = character end
		end
	end
	return gun
end

local function shootMurderer()
	if not MurdererName then
		sendNotification("MM2 Menu", "Murderer not found yet!")
		return
	end

	local target = Players:FindFirstChild(MurdererName)
	if not target or not target.Character then
		sendNotification("MM2 Menu", "Murderer not available.")
		return
	end
	if isPlayerInSpawn(target) then
		sendNotification("MM2 Menu", "Murderer is in spawn/lobby!")
		return
	end

	local gun = getGun()
	if not gun then
		sendNotification("MM2 Menu", "You do not have a Gun equipped!")
		return
	end

	local myRoot = getMyRoot()
	if not myRoot then return end

	-- stop the auto gun teleport from fighting the shot
	suspendGunTP = tick() + 3

	local startPosition = myRoot.CFrame

	for attempt = 1, 3 do
		if not isPlayerAlive(target) then break end

		local targetRoot = getPlayerRoot(target)
		if not targetRoot then break end

		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
		task.wait(0.06)

		suspendGunTP = tick() + 3

		local shootRemote = gun:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("Shoot", true)
		local aimRoot = getPlayerRoot(target)
		if aimRoot then
			if shootRemote and shootRemote:IsA("RemoteEvent") then
				pcall(function() shootRemote:FireServer(aimRoot.CFrame, aimRoot.Position) end)
			else
				pcall(function() gun:Activate() end)
			end
		end

		task.wait(0.35)
	end

	if isPlayerAlive(target) then
		myRoot.CFrame = startPosition
		sendNotification("MM2 Menu", "Murderer still alive, returned to position.")
	else
		sendNotification("MM2 Menu", "Murderer eliminated.")
	end
end

local killMurdererButton = createActionButton("KillMurdererNow", "Kill Murderer Now")
killMurdererButton.MouseButton1Click:Connect(function()
	task.spawn(shootMurderer)
end)

createInfoLabel("Auto Teleport To Gun is paused while shooting.")

--==================================================
-- TAB 6 — TELEPORT
--==================================================

useTab("Teleport")

local savedPositionBeforeGunTP = nil

local function isInsideAnyCharacter(instance)
	for _, target in ipairs(Players:GetPlayers()) do
		if target.Character and instance:IsDescendantOf(target.Character) then
			return true
		end
	end
	return false
end

local function partFromGunInstance(gunInstance)
	if not gunInstance or isInsideAnyCharacter(gunInstance) then return nil end
	if gunInstance:IsA("BasePart") then return gunInstance end
	if gunInstance:IsA("Model") then
		return gunInstance.PrimaryPart or gunInstance:FindFirstChildOfClass("BasePart")
	end
	return nil
end

local function getDroppedGunPart()
	for _, name in ipairs({ "GunDrop", "Gun" }) do
		local gunDrop = workspace:FindFirstChild(name, true)
		local part = partFromGunInstance(gunDrop)
		if part then return part end
	end
	return nil
end

local function murdererNearGun(gunPosition)
	if not MurdererName then return false end
	local target = Players:FindFirstChild(MurdererName)
	if not target then return false end
	local targetRoot = getPlayerRoot(target)
	if not targetRoot then return false end
	return (targetRoot.Position - gunPosition).Magnitude <= GUN_MURDERER_RADIUS
end

local function teleportToGun()
	local myRoot = getMyRoot()
	if not myRoot then return false end

	local gunPart = getDroppedGunPart()
	if not gunPart then return false end

	-- never chase the gun while the murderer is standing next to it
	if murdererNearGun(gunPart.Position) then
		if savedPositionBeforeGunTP then
			myRoot.CFrame = savedPositionBeforeGunTP
			myRoot.AssemblyLinearVelocity = Vector3.zero
			savedPositionBeforeGunTP = nil
		end
		return false
	end

	if not savedPositionBeforeGunTP then
		savedPositionBeforeGunTP = myRoot.CFrame
	end

	myRoot.CFrame = gunPart.CFrame + Vector3.new(0, 3, 0)
	return true
end

local autoGunButton, autoGunIndicator = createToggle("AutoGunTP", "Auto Teleport To Gun")

local function toggleAutoGun()
	autoGunTP = not autoGunTP
	if autoGunTP then
		setToggleOn(autoGunButton, autoGunIndicator)
	else
		setToggleOff(autoGunButton, autoGunIndicator)
		savedPositionBeforeGunTP = nil
	end
end

autoGunButton.MouseButton1Click:Connect(toggleAutoGun)
registerKeybind("Auto Gun TP", autoGunButton, function() return autoGunTP end, toggleAutoGun)

createSectionLabel("GUN / SPAWN")

local gunTeleportButton = createActionButton("GunTeleport", "Teleport To Gun")
gunTeleportButton.MouseButton1Click:Connect(function()
	suspendGunTP = tick() + 1.5
	if not teleportToGun() then
		sendNotification("MM2 Menu", "No dropped gun found on the map!")
	end
end)

local spawnTeleportButton = createActionButton("SpawnTeleport", "Teleport To Spawn")
spawnTeleportButton.MouseButton1Click:Connect(function()
	local myRoot = getMyRoot()
	if not myRoot then return end

	local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawnLocation then
		myRoot.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
		savedPositionBeforeGunTP = nil
		return
	end

	local spawnPoint = workspace:FindFirstChild("Spawn", true)
	if spawnPoint and spawnPoint:IsA("BasePart") then
		myRoot.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
		savedPositionBeforeGunTP = nil
	end
end)

createInfoLabel("If the murderer is within " .. GUN_MURDERER_RADIUS .. " studs of the gun you are not pulled to it.")

createSectionLabel("ROLE TARGETS")

local function teleportToPlayerByName(name)
	if not name then
		sendNotification("MM2 Menu", "Target not found yet!")
		return
	end
	local target = Players:FindFirstChild(name)
	local targetRoot = getPlayerRoot(target)
	local myRoot = getMyRoot()
	if targetRoot and myRoot then
		myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
		savedPositionBeforeGunTP = nil
	end
end

local murdererTeleport = createActionButton("TeleportMurderer", "Teleport To Murderer")
murdererTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(MurdererName) end)

local sheriffTeleport = createActionButton("TeleportSheriff", "Teleport To Sheriff")
sheriffTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(SheriffName) end)

local heroTeleport = createActionButton("TeleportHero", "Teleport To Hero")
heroTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(HeroName) end)

createSectionLabel("PLAYER LIST")

local playerDropdown = createActionButton("PlayerDropdown", "Select Player")

local dropdownOpen = false

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, 0, 0, 120)
playerList.BackgroundColor3 = COLORS.header
playerList.BorderSizePixel = 0
playerList.Visible = false
playerList.ClipsDescendants = true
playerList.CanvasSize = UDim2.fromOffset(0, 0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ScrollingDirection = Enum.ScrollingDirection.Y
playerList.ScrollBarThickness = 5
playerList.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
playerList.LayoutOrder = getLayoutOrder()
playerList.Parent = currentPage

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 8)
playerListCorner.Parent = playerList

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.SortOrder = Enum.SortOrder.Name
playerListLayout.Parent = playerList

local function refreshPlayerList()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local distance = getDistanceTo(target)

			local option = Instance.new("TextButton")
			option.Name = target.Name
			option.Size = UDim2.new(1, -10, 0, 30)
			option.BackgroundColor3 = COLORS.row
			option.BorderSizePixel = 0
			option.Text = target.DisplayName .. " (" .. formatDistance(distance) .. " studs)"
			option.TextColor3 = COLORS.text
			option.TextSize = 11
			option.Font = Enum.Font.GothamSemibold
			option.AutoButtonColor = false
			option.Parent = playerList

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = option

			option.MouseButton1Click:Connect(function()
				selectedPlayer = target
				playerDropdown.Text = "Selected: " .. target.Name
				dropdownOpen = false
				playerList.Visible = false
				playerList.CanvasPosition = Vector2.new(0, 0)
			end)
		end
	end

	task.defer(function()
		playerList.CanvasSize = UDim2.fromOffset(0, playerListLayout.AbsoluteContentSize.Y + 5)
		if currentTab == "Teleport" then updateCanvas() end
	end)
end

playerDropdown.MouseButton1Click:Connect(function()
	dropdownOpen = not dropdownOpen
	if dropdownOpen then
		refreshPlayerList()
		playerList.Visible = true
		task.defer(updateCanvas)
	else
		playerList.Visible = false
		playerList.CanvasPosition = Vector2.new(0, 0)
	end
end)

local playerTeleportButton = createActionButton("PlayerTeleport", "Teleport To Player")
playerTeleportButton.MouseButton1Click:Connect(function()
	local targetRoot = getPlayerRoot(selectedPlayer)
	local myRoot = getMyRoot()
	if not targetRoot or not myRoot then
		sendNotification("MM2 Menu", "Select a player first.")
		return
	end
	myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
	savedPositionBeforeGunTP = nil
end)

local killSelectedButton = createActionButton("KillSelectedPlayer", "Kill Selected Player")
killSelectedButton.MouseButton1Click:Connect(function()
	if selectedPlayer then attackTarget(selectedPlayer) end
end)

Players.PlayerAdded:Connect(function() if dropdownOpen then refreshPlayerList() end end)
Players.PlayerRemoving:Connect(function(target)
	if selectedPlayer == target then
		selectedPlayer = nil
		playerDropdown.Text = "Select Player"
	end
	if dropdownOpen then refreshPlayerList() end
end)

--==================================================
-- TAB 7 — UTILITY
--==================================================

useTab("Utility")

local antiVoidButton, antiVoidIndicator = createToggle("AntiVoid", "Anti Fall Down (Void)")
local antiFlingButton, antiFlingIndicator = createToggle("AntiFling", "Anti Fling")

local function toggleAntiVoid()
	antiVoidEnabled = not antiVoidEnabled
	if antiVoidEnabled then setToggleOn(antiVoidButton, antiVoidIndicator)
	else setToggleOff(antiVoidButton, antiVoidIndicator) end
end

antiVoidButton.MouseButton1Click:Connect(toggleAntiVoid)
registerKeybind("Anti Void", antiVoidButton, function() return antiVoidEnabled end, toggleAntiVoid)

local function toggleAntiFling()
	antiFlingEnabled = not antiFlingEnabled
	if antiFlingEnabled then setToggleOn(antiFlingButton, antiFlingIndicator)
	else setToggleOff(antiFlingButton, antiFlingIndicator) end
end

antiFlingButton.MouseButton1Click:Connect(toggleAntiFling)
registerKeybind("Anti Fling", antiFlingButton, function() return antiFlingEnabled end, toggleAntiFling)

createInfoLabel("Anti Fling steps aside while a fling feature is enabled.")

createSectionLabel("MAINTENANCE")

local function resetAllToggles()
	if noclip then
		noclip = false
		setCollisionDisabled(false)
		setToggleOff(noclipButton, noclipIndicator)
	end

	if flyEnabled then stopFly() end
	flyPanelOpen = false
	flyPanel.Visible = false
	setToggleOff(flyButton, flyIndicator)

	if infinityJump then
		infinityJump = false
		setToggleOff(infinityJumpButton, infinityJumpIndicator)
	end

	if flingThirdParty then
		flingThirdParty = false
		setFlingVisual(flingThirdPartyButton, flingThirdPartyIndicator, false)
	end

	if flingOnTouch then
		flingOnTouch = false
		flingTouchActive = false
		setFlingVisual(flingOnTouchButton, flingOnTouchIndicator, false)
	end

	if speedhackEnabled then
		speedhackEnabled = false
		setToggleOff(speedhackButton, speedhackIndicator)
		applyWalkSpeed(SPEEDHACK_DEFAULT)
	end

	for role, state in pairs(espEnabled) do
		if state then
			espEnabled[role] = false
			if espButtons[role] then setToggleOff(espButtons[role].Button, espButtons[role].Indicator) end
		end
	end

	if gunESPEnabled then
		gunESPEnabled = false
		setToggleOff(gunESPButton, gunESPIndicator)
	end

	if showDistance then
		showDistance = false
		setToggleOff(distanceButton, distanceIndicator)
	end

	if autoNotifyRoles then
		autoNotifyRoles = false
		setToggleOff(autoNotifyButton, autoNotifyIndicator)
	end

	if autoSendMurdererChat then
		autoSendMurdererChat = false
		lastChatSentMurderer = nil
		setToggleOff(autoMurdererChatButton, autoMurdererChatIndicator)
	end

	if autoSendSheriffChat then
		autoSendSheriffChat = false
		lastChatSentSheriff = nil
		setToggleOff(autoSheriffChatButton, autoSheriffChatIndicator)
	end

	if autoKillAll then
		autoKillAll = false
		setToggleOff(autoKillButton, autoKillIndicator)
	end

	if autoGunTP then
		autoGunTP = false
		savedPositionBeforeGunTP = nil
		setToggleOff(autoGunButton, autoGunIndicator)
	end

	if antiVoidEnabled then
		antiVoidEnabled = false
		setToggleOff(antiVoidButton, antiVoidIndicator)
	end

	if antiFlingEnabled then
		antiFlingEnabled = false
		setToggleOff(antiFlingButton, antiFlingIndicator)
	end

	sendNotification("MM2 Menu", "All features turned off")
end

local turnOffAllButton = Instance.new("TextButton")
turnOffAllButton.Name = "TurnOffAll"
turnOffAllButton.Size = UDim2.new(1, 0, 0, 34)
turnOffAllButton.Text = "TURN OFF ALL"
turnOffAllButton.TextColor3 = Color3.fromRGB(255, 200, 200)
turnOffAllButton.Font = Enum.Font.GothamBold
turnOffAllButton.LayoutOrder = getLayoutOrder()
turnOffAllButton.Parent = currentPage
styleRow(turnOffAllButton)
setRowColor(turnOffAllButton, COLORS.rowDanger)

turnOffAllButton.MouseButton1Click:Connect(resetAllToggles)

--==================================================
-- TAB 8 — KEYBINDS
--==================================================

useTab("Keys")

createInfoLabel("Click a bind, then press a key. Press again to unbind.")

local captureLabel = Instance.new("TextLabel")
captureLabel.Name = "CaptureStatus"
captureLabel.Size = UDim2.new(1, 0, 0, 20)
captureLabel.BackgroundTransparency = 1
captureLabel.Text = "Press a key for a feature..."
captureLabel.TextColor3 = COLORS.gold
captureLabel.TextSize = 10
captureLabel.Font = Enum.Font.GothamBold
captureLabel.TextXAlignment = Enum.TextXAlignment.Left
captureLabel.LayoutOrder = getLayoutOrder()
captureLabel.Parent = currentPage

local clearAllBindsButton = createActionButton("ClearKeybinds", "Clear All Binds")
clearAllBindsButton.MouseButton1Click:Connect(function()
	for name in pairs(keybindRegistry) do
		clearKeybind(name)
	end
	sendNotification("MM2 Menu", "All keybinds cleared.")
end)

local keybindSortOrder = {}
for name in pairs(keybindRegistry) do
	keybindSortOrder[name] = name
end
table.sort(keybindSortOrder)

for _, name in ipairs(keybindSortOrder) do
	local row = Instance.new("Frame")
	row.Name = "Bind_" .. name
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.LayoutOrder = getLayoutOrder()
	row.Parent = currentPage

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -96, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = COLORS.text
	label.TextSize = 11
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = row

	local bindButton = Instance.new("TextButton")
	bindButton.Size = UDim2.fromOffset(88, 26)
	bindButton.Position = UDim2.new(1, -88, 0.5, -13)
	bindButton.Text = "None"
	bindButton.Parent = row
	styleRow(bindButton)

	local stateDot = Instance.new("Frame")
	stateDot.Size = UDim2.fromOffset(5, 12)
	stateDot.Position = UDim2.new(0, 4, 0.5, -6)
	stateDot.BackgroundColor3 = COLORS.offIndicator
	stateDot.BorderSizePixel = 0
	stateDot.Parent = row

	local stateDotCorner = Instance.new("UICorner")
	stateDotCorner.CornerRadius = UDim.new(1, 0)
	stateDotCorner.Parent = stateDot

	local entry = keybindRegistry[name]
	local rowData = { Value = bindButton, Dot = stateDot }
	keybindRows[name] = rowData

	bindButton.MouseButton1Click:Connect(function()
		bindCaptureName = name
		captureLabel.Text = "Press a key for " .. name .. "..."
		selectTab("Keys")
	end)

	task.defer(function()
		local state = entry.GetState and entry.GetState()
		stateDot.BackgroundColor3 = state and COLORS.green or COLORS.offIndicator
	end)
end

--==================================================
-- DISTANCE HUD
--==================================================

local distanceHud = Instance.new("Frame")
distanceHud.Name = "DistanceHud"
distanceHud.AnchorPoint = Vector2.new(1, 1)
distanceHud.Position = UDim2.new(1, -15, 1, -15)
distanceHud.Size = UDim2.fromOffset(190, 96)
distanceHud.BackgroundColor3 = COLORS.bg
distanceHud.BackgroundTransparency = 0.12
distanceHud.BorderSizePixel = 0
distanceHud.Visible = false
distanceHud.ZIndex = 40
distanceHud.Parent = gui

local distanceHudCorner = Instance.new("UICorner")
distanceHudCorner.CornerRadius = UDim.new(0, 10)
distanceHudCorner.Parent = distanceHud

local distanceHudStroke = Instance.new("UIStroke")
distanceHudStroke.Color = COLORS.stroke
distanceHudStroke.Thickness = 1
distanceHudStroke.Transparency = 0.4
distanceHudStroke.Parent = distanceHud

local distanceRows = {}

local distanceHeader = Instance.new("TextLabel")
distanceHeader.Size = UDim2.new(1, -16, 0, 24)
distanceHeader.Position = UDim2.fromOffset(8, 4)
distanceHeader.BackgroundTransparency = 1
distanceHeader.Text = "DISTANCE (STUDS)"
distanceHeader.TextColor3 = COLORS.textBright
distanceHeader.TextSize = 11
distanceHeader.Font = Enum.Font.GothamBold
distanceHeader.TextXAlignment = Enum.TextXAlignment.Left
distanceHeader.ZIndex = 41
distanceHeader.Parent = distanceHud

for index, label in ipairs({ "Nearest", "Murderer", "Sheriff", "Hero" }) do
	local row = Instance.new("TextLabel")
	row.Size = UDim2.new(1, -16, 0, 17)
	row.Position = UDim2.fromOffset(8, 24 + (index - 1) * 17)
	row.BackgroundTransparency = 1
	row.Text = label .. ": --"
	row.TextColor3 = COLORS.text
	row.TextSize = 10
	row.Font = Enum.Font.GothamSemibold
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.ZIndex = 41
	row.Parent = distanceHud

	distanceRows[label] = row
end

local function updateDistanceHud()
	if not showDistance then
		if distanceHud.Visible then distanceHud.Visible = false end
		return
	end
	if not distanceHud.Visible then distanceHud.Visible = true end

	local nearestPlayer, nearestDistance = nil, math.huge
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local distance = getDistanceTo(target)
			if distance and distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = target
			end
		end
	end

	if nearestPlayer then
		distanceRows.Nearest.Text = "Nearest: " .. nearestPlayer.DisplayName .. " (" .. formatDistance(nearestDistance) .. ")"
	else
		distanceRows.Nearest.Text = "Nearest: --"
	end

	local function roleRow(label, name)
		local target = name and Players:FindFirstChild(name)
		local distance = getDistanceTo(target)
		if target and distance then
			distanceRows[label].Text = label .. ": " .. target.DisplayName .. " (" .. formatDistance(distance) .. ")"
		else
			distanceRows[label].Text = label .. ": --"
		end
	end

	roleRow("Murderer", MurdererName)
	roleRow("Sheriff", SheriffName)
	roleRow("Hero", HeroName)
end

--==================================================
-- ESP SYSTEM
--==================================================

local highlights = {}

local function CreateHighlight(target)
	if target == player or not target.Character then return end
	local highlight = target.Character:FindFirstChild("RoleESP")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "RoleESP"
		highlight.FillTransparency = 0.45
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = target.Character
	end
	highlights[target] = highlight
end

local function RemoveHighlight(target)
	if target and target.Character then
		local highlight = target.Character:FindFirstChild("RoleESP")
		if highlight then highlight:Destroy() end
	end
	highlights[target] = nil
end

local function destroyAllHighlights()
	for target in pairs(highlights) do
		RemoveHighlight(target)
	end
	highlights = {}

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then RemoveHighlight(target) end
	end
end

local gunESPHighlight = nil

local function destroyGunESP()
	if gunESPHighlight then
		gunESPHighlight:Destroy()
		gunESPHighlight = nil
	end
end

local function updateGunESP()
	if not gunESPEnabled then
		destroyGunESP()
		return
	end

	local gunPart = getDroppedGunPart()
	if not gunPart then
		destroyGunESP()
		return
	end

	if gunESPHighlight and gunESPHighlight.Parent == gunPart then
		gunESPHighlight.FillColor = COLORS.gun
		gunESPHighlight.OutlineColor = COLORS.gold
		return
	end

	destroyGunESP()
	gunESPHighlight = Instance.new("Highlight")
	gunESPHighlight.Name = "GunESP"
	gunESPHighlight.FillColor = COLORS.gun
	gunESPHighlight.OutlineColor = COLORS.gold
	gunESPHighlight.FillTransparency = 0.4
	gunESPHighlight.OutlineTransparency = 0
	gunESPHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	gunESPHighlight.Parent = gunPart
end

local function getRoleForPlayer(target)
	if MurdererName and target.Name == MurdererName then return "Murderer" end
	if SheriffName and target.Name == SheriffName then return "Sheriff" end
	if HeroName and target.Name == HeroName then return "Hero" end
	return "Innocent"
end

local function UpdateHighlights()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			CreateHighlight(target)
			local highlight = target.Character:FindFirstChild("RoleESP")
			if not highlight then continue end

			local role = getRoleForPlayer(target)
			local alive = isPlayerAlive(target)
			local color = ROLE_COLORS[role]

			if not alive then
				if espEnabled.Innocent or espEnabled[role] then
					highlight.FillColor = color
					highlight.OutlineColor = color
					highlight.FillTransparency = 0.7
					highlight.OutlineTransparency = 0.2
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Enabled = true
				else
					highlight.Enabled = false
				end
			elseif espEnabled[role] then
				highlight.FillColor = color
				highlight.OutlineColor = color
				highlight.FillTransparency = 0.45
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Enabled = true
			else
				highlight.Enabled = false
			end
		end
	end
end

local function resetRoundState()
	MurdererName = nil
	SheriffName = nil
	HeroName = nil
	lastNotifiedMurderer = nil
	lastNotifiedSheriff = nil
	lastNotifiedHero = nil
	lastChatSentMurderer = nil
	lastChatSentSheriff = nil
	roundLive = false
	killAllRunning = false
	savedPositionBeforeGunTP = nil

	destroyAllHighlights()
	destroyGunESP()
	updateRoleStatusLabel()
end

local function GetRoles()
	if not GetPlayerData then return end

	local success, result = pcall(function() return GetPlayerData:InvokeServer() end)
	if not success or type(result) ~= "table" then return end

	local newMurderer, newSheriff, newHero = nil, nil, nil

	for name, data in pairs(result) do
		if type(data) == "table" then
			local role = data.Role
			if role == "Murderer" then newMurderer = tostring(name)
			elseif role == "Sheriff" then newSheriff = tostring(name)
			elseif role == "Hero" then newHero = tostring(name) end
		elseif type(data) == "string" then
			if data == "Murderer" then newMurderer = tostring(name)
			elseif data == "Sheriff" then newSheriff = tostring(name)
			elseif data == "Hero" then newHero = tostring(name) end
		end
	end

	for key, data in pairs(result) do
		if typeof(key) == "Instance" and key:IsA("Player") then
			local role = type(data) == "table" and data.Role or (type(data) == "string" and data or nil)
			if role == "Murderer" then newMurderer = key.Name
			elseif role == "Sheriff" then newSheriff = key.Name
			elseif role == "Hero" then newHero = key.Name end
		end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		local role = target:GetAttribute("Role")
		if role == "Murderer" then newMurderer = target.Name
		elseif role == "Sheriff" then newSheriff = target.Name
		elseif role == "Hero" then newHero = target.Name end
	end

	if not newMurderer and not newSheriff and not newHero then
		-- no roles on the server: round ended (or we are in the lobby)
		if roundLive or MurdererName or SheriffName or HeroName then
			resetRoundState()
		end
		return
	end

	roundLive = true

	MurdererName = newMurderer or (MurdererName and Players:FindFirstChild(MurdererName) and MurdererName or nil)
	SheriffName = newSheriff or (SheriffName and Players:FindFirstChild(SheriffName) and SheriffName or nil)
	HeroName = newHero or (HeroName and Players:FindFirstChild(HeroName) and HeroName or nil)

	updateRoleStatusLabel()

	if autoNotifyRoles then
		if (MurdererName and MurdererName ~= lastNotifiedMurderer)
			or (SheriffName and SheriffName ~= lastNotifiedSheriff)
			or (HeroName and HeroName ~= lastNotifiedHero) then
			lastNotifiedMurderer = MurdererName
			lastNotifiedSheriff = SheriffName
			lastNotifiedHero = HeroName
			notifyAllRoles()
		end
	end
end

local function checkAutoChat()
	if autoSendMurdererChat and MurdererName and lastChatSentMurderer ~= MurdererName then
		if tick() - lastChatSentAt >= CHAT_COOLDOWN then
			if sendChatMessage("Murderer is: " .. roleDisplayName(MurdererName)) then
				lastChatSentMurderer = MurdererName
				lastChatSentAt = tick()
			end
		end
	end

	if autoSendSheriffChat and SheriffName and lastChatSentSheriff ~= SheriffName then
		if tick() - lastChatSentAt >= CHAT_COOLDOWN then
			if sendChatMessage("Sheriff is: " .. roleDisplayName(SheriffName)) then
				lastChatSentSheriff = SheriffName
				lastChatSentAt = tick()
			end
		end
	end
end

--==================================================
-- ANTI VOID / ANTI FLING
--==================================================

local surfaceRayParams = nil

local function getSurfaceRayParams()
	if not surfaceRayParams then
		surfaceRayParams = RaycastParams.new()
		surfaceRayParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	local ignore = {}
	if player.Character then table.insert(ignore, player.Character) end
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then table.insert(ignore, target.Character) end
	end
	surfaceRayParams.FilterDescendantsInstances = ignore
	return surfaceRayParams
end

local function findSurfaceAbove(x, z)
	local result = workspace:Raycast(
		Vector3.new(x, 1000, z),
		Vector3.new(0, -2000, 0),
		getSurfaceRayParams()
	)
	if result then
		return result.Position + Vector3.new(0, 3, 0)
	end
	return nil
end

RunService.Heartbeat:Connect(function()
	if not scriptActive then return end
	if not antiVoidEnabled then return end
	if flyEnabled then return end

	local now = tick()
	if now < antiVoidCooldownUntil then return end

	local root = getMyRoot()
	if not root then return end
	if root.Position.Y >= VOID_Y_THRESHOLD then return end

	antiVoidCooldownUntil = now + 0.6

	-- primary: the next surface directly above this column
	local safePosition = findSurfaceAbove(root.Position.X, root.Position.Z)

	-- fallbacks
	if not safePosition and lastSafePosition and (now - lastSafeUpdate) < 10 then
		safePosition = lastSafePosition.Position + Vector3.new(0, 3, 0)
	end
	if not safePosition then
		local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
		if spawnLocation then
			safePosition = spawnLocation.Position + Vector3.new(0, 5, 0)
		end
	end

	if safePosition then
		root.CFrame = CFrame.new(safePosition)
	else
		root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
	end
	root.AssemblyLinearVelocity = Vector3.zero
end)

RunService.Heartbeat:Connect(function()
	if not scriptActive then return end
	if not antiFlingEnabled then return end
	if flyEnabled then return end

	local root = getMyRoot()
	if not root then return end

	local now = tick()
	local velocity = root.AssemblyLinearVelocity
	local speed = velocity.Magnitude

	if speed < 100 and root.Position.Y > VOID_Y_THRESHOLD then
		lastSafePosition = root.CFrame
		lastSafeUpdate = now
	end

	-- a fling feature owns the velocity while it is enabled
	if flingOnTouch or flingThirdParty then return end

	if speed > ANTI_FLING_MAX_SPEED then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero

		if lastSafePosition and (now - lastSafeUpdate) < 5 then
			root.CFrame = lastSafePosition
		end
	end

	if root.AssemblyAngularVelocity.Magnitude > ANTI_FLING_MAX_ANGULAR then
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero
	end
end)

--==================================================
-- RESPAWN HANDLERS
--==================================================

local function onCharacterAdded(character)
	stopFly()
	for key in pairs(flyControls) do flyControls[key] = 0 end
	for key in pairs(lastFlyControls) do lastFlyControls[key] = 0 end

	originalCollision = {}
	lastSafePosition = nil
	antiVoidCooldownUntil = 0

	if noclip then
		task.wait(0.1)
		setCollisionDisabled(true)
	end

	task.wait(0.2)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		if speedhackEnabled then humanoid.WalkSpeed = speedhackSpeed end
	end
	UpdateHighlights()
end

player.CharacterAdded:Connect(onCharacterAdded)

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then
		target.CharacterAdded:Connect(function()
			task.wait(0.2)
			if not scriptActive then return end
			CreateHighlight(target)
			UpdateHighlights()
		end)
		if target.Character then CreateHighlight(target) end
	end
end

Players.PlayerAdded:Connect(function(target)
	target.CharacterAdded:Connect(function()
		task.wait(0.2)
		if not scriptActive then return end
		CreateHighlight(target)
		UpdateHighlights()
	end)
end)

Players.PlayerRemoving:Connect(function(target) RemoveHighlight(target) end)

--==================================================
-- INFINITY JUMP
--==================================================

UserInputService.JumpRequest:Connect(function()
	if not scriptActive then return end
	if not infinityJump then return end
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

--==================================================
-- WINDOW CONTROLS
--==================================================

local dragging = false
local dragStart = nil
local dragStartPosition = nil

header.InputBegan:Connect(function(input)
	if guiLocked then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		dragStartPosition = frame.Position
	end
end)

local function showMenu()
	menuVisible = true
	frame.Visible = true
	reopenButton.Visible = false
end

local function hideMenu()
	menuVisible = false
	frame.Visible = false
	flyPanel.Visible = false
	flyPanelOpen = false
	reopenButton.Visible = true
end

local function closeScriptHub()
	scriptActive = false
	flingTouchActive = false

	stopFly()

	if noclip then
		noclip = false
		setCollisionDisabled(false)
	end
	if speedhackEnabled then
		speedhackEnabled = false
		applyWalkSpeed(SPEEDHACK_DEFAULT)
	end

	gui:Destroy()
	sendNotification("MM2 Menu", "Script hub closed.")
end

UserInputService.InputChanged:Connect(function(input)
	if not scriptActive then return end

	if resizing then
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - resizeStart
			local newWidth = math.max(MIN_WIDTH, resizeStartSize.X + delta.X)
			local newHeight = math.max(MIN_HEIGHT, resizeStartSize.Y + delta.Y)
			frame.Size = UDim2.fromOffset(newWidth, newHeight)
			task.defer(updateCanvas)
		end
		return
	end

	if dragging and not guiLocked then
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				dragStartPosition.X.Scale, dragStartPosition.X.Offset + delta.X,
				dragStartPosition.Y.Scale, dragStartPosition.Y.Offset + delta.Y
			)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = false
		dragging = false
	end
end)

lockButton.MouseButton1Click:Connect(function()
	guiLocked = not guiLocked
	if guiLocked then
		lockButton.Text = "LOCKED"
		lockButton.BackgroundColor3 = COLORS.rowDanger
		sendNotification("MM2 Menu", "Menu locked.")
	else
		lockButton.Text = "UNLOCK"
		lockButton.BackgroundColor3 = COLORS.row
	end
end)

-- MINIMIZE behaves exactly like the old close button: hide to the reopen bubble
minimizeButton.MouseButton1Click:Connect(function()
	hideMenu()
end)

-- X closes the whole script hub
closeButton.MouseButton1Click:Connect(function()
	closeScriptHub()
end)

closeButton.MouseEnter:Connect(function()
	tweenColor(closeButton, "BackgroundColor3", Color3.fromRGB(180, 55, 55), 0.1)
end)
closeButton.MouseLeave:Connect(function()
	tweenColor(closeButton, "BackgroundColor3", COLORS.row, 0.1)
end)

reopenButton.MouseButton1Click:Connect(function()
	showMenu()
end)

local reopenDragging = false
local reopenDragStart = nil
local reopenDragStartPosition = nil

reopenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		reopenDragging = true
		reopenDragStart = input.Position
		reopenDragStartPosition = reopenButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not reopenDragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - reopenDragStart
		reopenButton.Position = UDim2.new(
			reopenDragStartPosition.X.Scale, reopenDragStartPosition.X.Offset + delta.X,
			reopenDragStartPosition.Y.Scale, reopenDragStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		reopenDragging = false
	end
end)

--==================================================
-- KEYBIND INPUT
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if not scriptActive then return end

	if bindCaptureName then
		local capturedName = bindCaptureName
		bindCaptureName = nil
		captureLabel.Text = "Press a key for a feature..."

		local entry = keybindRegistry[capturedName]
		if entry then
			if input.KeyCode == Enum.KeyCode.Unknown then
				entry.Key = nil
				entry.KeyLabel = nil
				updateKeybindLabel(entry)
			else
				setKeybind(capturedName, input.KeyCode)
			end
		end
		return
	end

	if processed then return end

	for name, entry in pairs(keybindRegistry) do
		if entry.Key and input.KeyCode == entry.Key then
			entry.Toggle()
			return
		end
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		if menuVisible then hideMenu() else showMenu() end
	end
end)

--==================================================
-- INIT & MAIN LOOP
--==================================================

selectTab("Movement")

GetRoles()
UpdateHighlights()
updateRoleStatusLabel()

task.spawn(function()
	while scriptActive and gui.Parent do
		pcall(function()
			GetRoles()
			UpdateHighlights()
			updateGunESP()
			updateDistanceHud()

			if autoKillAll and MurdererName == player.Name then
				killAllPlayers(true)
			end

			if autoGunTP and tick() >= suspendGunTP then
				teleportToGun()
			end

			checkAutoChat()

			if currentTab == "Keys" then
				for name, entry in pairs(keybindRegistry) do
					local row = keybindRows[name]
					if row and entry.GetState then
						local state = entry.GetState()
						local color = state and COLORS.green or COLORS.offIndicator
						if row.Dot.BackgroundColor3 ~= color then
							row.Dot.BackgroundColor3 = color
						end
					end
				end
			end
		end)

		task.wait(0.25)
	end
end)