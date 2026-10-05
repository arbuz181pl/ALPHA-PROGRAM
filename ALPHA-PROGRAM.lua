--==================================================
-- SPAWN & LOBBY PROTECTION
--==================================================

local cachedSpawns = {}
local lastSpawnCacheUpdate = 0

local function refreshSpawnCache()
	local newCache = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("SpawnLocation") then
			table.insert(newCache, obj)
		elseif obj:IsA("BasePart") and obj.Name == "SpawnPoint" then
			table.insert(newCache, obj)
		end
	end
	cachedSpawns = newCache
	lastSpawnCacheUpdate = tick()
end

local function isPlayerInSpawn(target)
	if not target or not target.Character then return true end
	local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyMap")
	if lobby and target.Character:IsDescendantOf(lobby) then return true end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return true end
	for _, spawnObject in ipairs(cachedSpawns) do
		if spawnObject and spawnObject.Parent then
			if (targetRoot.Position - spawnObject.Position).Magnitude < 35 then return true end
		end
	end
	return false
end

--==================================================
-- MURDERER
--==================================================

createSectionTitle("MURDERER SETTINGS")

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
	if not target or target == player or not target.Character then return end
	if isPlayerInSpawn(target) then return end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot and myRoot then
		local knife = getKnife()
		if knife then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
			task.wait(0.05)
			pcall(function() knife:Activate() end)
		end
	end
end

local function killAllPlayers()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and not isPlayerInSpawn(target) then
				attackTarget(target)
				task.wait(0.2)
			end
		end
	end
end

local function killTargetByName(name)
	if not name then return end
	local target = Players:FindFirstChild(name)
	if target then attackTarget(target) end
end

local autoKillButton, autoKillIndicator = createToggle("AutoKillAll", "Auto Kill All")

autoKillButton.MouseButton1Click:Connect(function()
	autoKillAll = not autoKillAll
	if autoKillAll then setToggleOn(autoKillButton, autoKillIndicator) else setToggleOff(autoKillButton, autoKillIndicator) end
end)

local killAllButton = createActionButton("KillAllNow", "Kill All Now")
killAllButton.MouseButton1Click:Connect(function() killAllPlayers() end)

local killSheriffButton = createActionButton("KillSheriffNow", "Kill Sheriff Now")
killSheriffButton.MouseButton1Click:Connect(function() killTargetByName(SheriffName) end)

local killHeroButton = createActionButton("KillHeroNow", "Kill Hero Now")
killHeroButton.MouseButton1Click:Connect(function() killTargetByName(HeroName) end)

--==================================================
-- SHERIFF
--==================================================

createSectionTitle("SHERIFF SETTINGS")

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
	if not target or not target.Character then return end
	if isPlayerInSpawn(target) then
		sendNotification("MM2 Menu", "Murderer is in spawn/lobby!")
		return
	end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot and myRoot then
		local gun = getGun()
		if gun then
			myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
			task.wait(0.08)
			local shootRemote = gun:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("Shoot", true)
			if shootRemote and shootRemote:IsA("RemoteEvent") then
				pcall(function() shootRemote:FireServer(targetRoot.CFrame, targetRoot.Position) end)
			else
				pcall(function() gun:Activate() end)
			end
		else
			sendNotification("MM2 Menu", "You do not have a Gun equipped!")
		end
	end
end

local killMurdererButton = createActionButton("KillMurdererNow", "Kill Murderer Now")
killMurdererButton.MouseButton1Click:Connect(function() shootMurderer() end)

--==================================================
-- TELEPORT
--==================================================

createSectionTitle("TELEPORT SETTINGS")

local lastGunTP = 0

local function teleportToGun()
	local character = player.Character
	if not character then return false end
	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end
	local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("Gun", true)
	if gunDrop then
		local targetPart = nil
		if gunDrop:IsA("BasePart") then targetPart = gunDrop
		elseif gunDrop:IsA("Model") then targetPart = gunDrop.PrimaryPart or gunDrop:FindFirstChildOfClass("BasePart")
		elseif gunDrop:IsA("Tool") then targetPart = gunDrop:FindFirstChild("Handle") or gunDrop:FindFirstChildOfClass("BasePart")
		end
		if targetPart then
			if (myRoot.Position - targetPart.Position).Magnitude < 8 then return true end
			myRoot.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
			return true
		end
	end
	return false
end

local autoGunButton, autoGunIndicator = createToggle("AutoGunTP", "Auto Teleport To Gun")

autoGunButton.MouseButton1Click:Connect(function()
	autoGunTP = not autoGunTP
	if autoGunTP then setToggleOn(autoGunButton, autoGunIndicator) else setToggleOff(autoGunButton, autoGunIndicator) end
end)

local spawnTeleportButton = createActionButton("SpawnTeleport", "Teleport To Spawn")
spawnTeleportButton.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then return end
	local myRoot = character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawnLocation then myRoot.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0) return end
	local spawnPoint = workspace:FindFirstChild("Spawn", true)
	if spawnPoint and spawnPoint:IsA("BasePart") then myRoot.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0) end
end)

local gunTeleportButton = createActionButton("GunTeleport", "Teleport To Gun")
gunTeleportButton.MouseButton1Click:Connect(function()
	if not teleportToGun() then sendNotification("MM2 Menu", "No dropped gun found on the map!") end
end)

local playerTeleportButton = createActionButton("PlayerTeleport", "Teleport To Player")
local killSelectedButton = createActionButton("KillSelectedPlayer", "Kill Selected Player")

local selectedPlayer = nil

local playerDropdown = Instance.new("TextButton")
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Size = UDim2.new(1, 0, 0, 36)
playerDropdown.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
playerDropdown.BorderSizePixel = 0
playerDropdown.Text = "Select Player"
playerDropdown.TextColor3 = Color3.fromRGB(230, 230, 235)
playerDropdown.TextSize = 12
playerDropdown.Font = Enum.Font.GothamSemibold
playerDropdown.AutoButtonColor = false
playerDropdown.LayoutOrder = getLayoutOrder()
playerDropdown.Parent = content

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = playerDropdown

local dropdownOpen = false

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, 0, 0, 0)
playerList.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
playerList.BorderSizePixel = 0
playerList.Visible = false
playerList.ClipsDescendants = true
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ScrollingDirection = Enum.ScrollingDirection.Y
playerList.ScrollBarThickness = 5
playerList.ScrollBarImageColor3 = Color3.fromRGB(75, 77, 85)
playerList.LayoutOrder = getLayoutOrder()
playerList.Parent = content

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
			local option = Instance.new("TextButton")
			option.Name = target.Name
			option.Size = UDim2.new(1, -10, 0, 30)
			option.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
			option.BorderSizePixel = 0
			option.Text = target.DisplayName .. " (@" .. target.Name .. ")"
			option.TextColor3 = Color3.fromRGB(230, 230, 235)
			option.TextSize = 12
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
				playerList.Size = UDim2.new(1, 0, 0, 0)
				playerList.CanvasPosition = Vector2.new(0, 0)
			end)
		end
	end
end

playerDropdown.MouseButton1Click:Connect(function()
	dropdownOpen = not dropdownOpen
	if dropdownOpen then
		refreshPlayerList()
		playerList.Visible = true
		playerList.Size = UDim2.new(1, 0, 0, 120)
	else
		playerList.Visible = false
		playerList.Size = UDim2.new(1, 0, 0, 0)
		playerList.CanvasPosition = Vector2.new(0, 0)
	end
end)

playerTeleportButton.MouseButton1Click:Connect(function()
	if not selectedPlayer or not selectedPlayer.Character then return end
	local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
	local character = player.Character
	if character and targetRoot then
		local myRoot = character:FindFirstChild("HumanoidRootPart")
		if myRoot then myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0) end
	end
end)

killSelectedButton.MouseButton1Click:Connect(function()
	if selectedPlayer then attackTarget(selectedPlayer) end
end)

Players.PlayerAdded:Connect(function() if dropdownOpen then refreshPlayerList() end end)
Players.PlayerRemoving:Connect(function(target)
	if selectedPlayer == target then selectedPlayer = nil playerDropdown.Text = "Select Player" end
	if dropdownOpen then refreshPlayerList() end
end)

local murdererTeleport = createActionButton("TeleportMurderer", "Teleport To Murderer")
local sheriffTeleport = createActionButton("TeleportSheriff", "Teleport To Sheriff")
local heroTeleport = createActionButton("TeleportHero", "Teleport To Hero")

local function teleportToPlayerByName(name)
	if not name then return end
	local target = Players:FindFirstChild(name)
	if not target or not target.Character then return end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local character = player.Character
	if character and targetRoot then
		local myRoot = character:FindFirstChild("HumanoidRootPart")
		if myRoot then myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0) end
	end
end

murdererTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(MurdererName) end)
sheriffTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(SheriffName) end)
heroTeleport.MouseButton1Click:Connect(function() teleportToPlayerByName(HeroName) end)

--==================================================
-- UTILITY
--==================================================

createSectionTitle("UTILITY SETTINGS")

local antiVoidButton, antiVoidIndicator = createToggle("AntiVoid", "Anti Fall Down (Void)")
local antiFlingButton, antiFlingIndicator = createToggle("AntiFling", "Anti Fling")

antiVoidButton.MouseButton1Click:Connect(function()
	antiVoidEnabled = not antiVoidEnabled
	if antiVoidEnabled then setToggleOn(antiVoidButton, antiVoidIndicator) else setToggleOff(antiVoidButton, antiVoidIndicator) end
end)

antiFlingButton.MouseButton1Click:Connect(function()
	antiFlingEnabled = not antiFlingEnabled
	if antiFlingEnabled then setToggleOn(antiFlingButton, antiFlingIndicator) else setToggleOff(antiFlingButton, antiFlingIndicator) end
end)

local function resetAllToggles(silent)
	if noclip then
		noclip = false
		setToggleOff(noclipButton, noclipIndicator)
		for object, oldValue in pairs(originalCollision) do
			if object and object.Parent then object.CanCollide = oldValue end
		end
		originalCollision = {}
	end
	if flyEnabled then stopFly() end
	flyPanelOpen = false
	flyPanel.Visible = false
	if infinityJump then infinityJump = false setToggleOff(infinityJumpButton, infinityJumpIndicator) end
	if flingThirdParty then
		flingThirdParty = false
		setToggleOff(flingThirdPartyButton, flingThirdPartyIndicator)
		if not silent then sendNotification("MM2 Menu", "3rd-party fling script cannot be unloaded. Rejoin to clear.") end
	end
	if flingOnTouch then flingOnTouch = false flingTouchActive = false setToggleOff(flingOnTouchButton, flingOnTouchIndicator) end
	if speedhackEnabled then
		speedhackEnabled = false
		setToggleOff(speedhackButton, speedhackIndicator)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = 16 end
		end
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
		for gun, hl in pairs(gunHighlights) do
			if hl then pcall(function() hl:Destroy() end) end
		end
		gunHighlights = {}
	end
	if autoNotifyRoles then autoNotifyRoles = false setToggleOff(autoNotifyButton, autoNotifyIndicator) end
	if autoSendMurdererChat then
		autoSendMurdererChat = false
		setToggleOff(autoMurdererChatButton, autoMurdererChatIndicator)
		lastChatSentMurderer = nil
		roundActive = false
	end
	if autoKillAll then autoKillAll = false setToggleOff(autoKillButton, autoKillIndicator) end
	if autoGunTP then autoGunTP = false setToggleOff(autoGunButton, autoGunIndicator) end
	if antiVoidEnabled then antiVoidEnabled = false setToggleOff(antiVoidButton, antiVoidIndicator) end
	if antiFlingEnabled then antiFlingEnabled = false setToggleOff(antiFlingButton, antiFlingIndicator) end
	if not silent then sendNotification("MM2 Menu", "All features turned off") end
end

local turnOffAllButton = Instance.new("TextButton")
turnOffAllButton.Name = "TurnOffAll"
turnOffAllButton.Size = UDim2.new(1, 0, 0, 36)
turnOffAllButton.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
turnOffAllButton.BorderSizePixel = 0
turnOffAllButton.Text = "TURN OFF ALL"
turnOffAllButton.TextColor3 = Color3.fromRGB(255, 200, 200)
turnOffAllButton.TextSize = 13
turnOffAllButton.Font = Enum.Font.GothamBold
turnOffAllButton.AutoButtonColor = false
turnOffAllButton.LayoutOrder = getLayoutOrder()
turnOffAllButton.Parent = content

local turnOffCorner = Instance.new("UICorner")
turnOffCorner.CornerRadius = UDim.new(0, 8)
turnOffCorner.Parent = turnOffAllButton

turnOffAllButton.MouseButton1Click:Connect(function() resetAllToggles(false) end)

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

local function IsAlive(target)
	if not target or not target.Character then return false end
	local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
end

local function isRoleHolderValid(target)
	if not target then return false end
	if not target.Character then return false end
	local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if isPlayerInSpawn(target) then return false end
	return true
end

local function isCachedRoleHolderValid(cachedName)
	if not cachedName then return false end
	local target = Players:FindFirstChild(cachedName)
	if not target then return false end
	return isRoleHolderValid(target)
end

local function resetRoleState()
	MurdererName = nil
	SheriffName = nil
	HeroName = nil
	lastNotifiedMurderer = nil
	lastNotifiedSheriff = nil
	lastNotifiedHero = nil
	lastChatSentMurderer = nil
	roundActive = false
	noMurdererSince = nil
end

local function resolveRole(reportedName)
	if not reportedName then return nil end
	local targetPlayer = Players:FindFirstChild(reportedName)
	if not targetPlayer then return nil end
	if not isRoleHolderValid(targetPlayer) then return nil end
	return reportedName
end

local function GetRoles()
	if not GetPlayerData then
		if not warnedNoRemote then
			warnedNoRemote = true
			sendNotification("MM2 Menu", "GetPlayerData remote not found - role features disabled")
		end
		return
	end
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

	newMurderer = resolveRole(newMurderer)
	newSheriff = resolveRole(newSheriff)
	newHero = resolveRole(newHero)

	if newMurderer and MurdererName and newMurderer ~= MurdererName then
		SheriffName = nil
		HeroName = nil
		lastNotifiedSheriff = nil
		lastNotifiedHero = nil
		lastChatSentMurderer = nil
		roundActive = false
		noMurdererSince = nil
	end

	if newMurderer then
		noMurdererSince = nil
	elseif MurdererName then
		if not noMurdererSince then
			noMurdererSince = tick()
		elseif tick() - noMurdererSince >= ROUND_END_DEBOUNCE then
			resetRoleState()
		end
	end

	if newMurderer then
		MurdererName = newMurderer
	elseif MurdererName and not isCachedRoleHolderValid(MurdererName) then
		MurdererName = nil
		lastNotifiedMurderer = nil
		lastChatSentMurderer = nil
		roundActive = false
	end

	if newSheriff then
		SheriffName = newSheriff
	elseif SheriffName and not isCachedRoleHolderValid(SheriffName) then
		SheriffName = nil
		lastNotifiedSheriff = nil
	end

	if newHero then
		HeroName = newHero
	elseif HeroName and not isCachedRoleHolderValid(HeroName) then
		HeroName = nil
		lastNotifiedHero = nil
	end

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

local function UpdateHighlights()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			CreateHighlight(target)
			local highlight = target.Character:FindFirstChild("RoleESP")
			if highlight then
				local role
				if MurdererName and target.Name == MurdererName then role = "Murderer"
				elseif SheriffName and target.Name == SheriffName then role = "Sheriff"
				elseif HeroName and target.Name == HeroName then role = "Hero"
				else role = "Innocent" end

				local showRoleColor = IsAlive(target) and not isPlayerInSpawn(target)

				if not showRoleColor then
					if espEnabled.Innocent then
						local deadColor = ROLE_COLORS.Innocent
						highlight.FillColor = deadColor
						highlight.OutlineColor = deadColor
						highlight.FillTransparency = 0.7
						highlight.OutlineTransparency = 0.2
						highlight.Enabled = true
					else
						highlight.Enabled = false
					end
				else
					if espEnabled[role] then
						local color = ROLE_COLORS[role]
						highlight.FillColor = color
						highlight.OutlineColor = color
						highlight.FillTransparency = 0.45
						highlight.OutlineTransparency = 0
						highlight.Enabled = true
					else
						highlight.Enabled = false
					end
				end
			end
		end
	end
end

local function RemoveHighlight(target)
	if target.Character then
		local highlight = target.Character:FindFirstChild("RoleESP")
		if highlight then highlight:Destroy() end
	end
	highlights[target] = nil
end

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then
		target.CharacterAdded:Connect(function()
			task.wait(0.2)
			CreateHighlight(target)
			UpdateHighlights()
		end)
		if target.Character then CreateHighlight(target) end
	end
end

Players.PlayerAdded:Connect(function(target)
	target.CharacterAdded:Connect(function()
		task.wait(0.2)
		CreateHighlight(target)
		UpdateHighlights()
	end)
end)

Players.PlayerRemoving:Connect(function(target)
	RemoveHighlight(target)
	if MurdererName == target.Name then MurdererName = nil end
	if SheriffName == target.Name then SheriffName = nil end
	if HeroName == target.Name then HeroName = nil end
end)

--==================================================
-- GUN ESP
--==================================================

local lastGunScan = 0
local GUN_SCAN_INTERVAL = 0.5

local function isGunHeldByPlayer(gun)
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		if char and gun:IsDescendantOf(char) then return true end
	end
	return false
end

local function isDroppedGun(inst)
	if not inst or not inst.Parent then return false end
	if inst.Name ~= "Gun" and inst.Name ~= "GunDrop" then return false end
	if not (inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("Tool")) then return false end
	if isGunHeldByPlayer(inst) then return false end
	return true
end

local function attachGunHighlight(gun)
	if gunHighlights[gun] then return end
	local hl = Instance.new("Highlight")
	hl.Name = "GunESP"
	hl.FillColor = GUN_COLOR
	hl.OutlineColor = GUN_COLOR
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = gun
	gunHighlights[gun] = hl
end

local function removeGunHighlight(gun)
	local hl = gunHighlights[gun]
	if hl then pcall(function() hl:Destroy() end) end
	gunHighlights[gun] = nil
end

local function clearAllGunHighlights()
	local snapshot = {}
	for gun, _ in pairs(gunHighlights) do table.insert(snapshot, gun) end
	for _, gun in ipairs(snapshot) do removeGunHighlight(gun) end
end

local function updateGunESP()
	local stale = {}
	for gun, _ in pairs(gunHighlights) do
		if not gun or not gun.Parent or not isDroppedGun(gun) then table.insert(stale, gun) end
	end
	for _, gun in ipairs(stale) do removeGunHighlight(gun) end

	if not gunESPEnabled then
		if next(gunHighlights) ~= nil then clearAllGunHighlights() end
		return
	end

	local now = tick()
	if now - lastGunScan < GUN_SCAN_INTERVAL then return end
	lastGunScan = now

	for _, inst in ipairs(workspace:GetDescendants()) do
		if isDroppedGun(inst) and not gunHighlights[inst] then
			attachGunHighlight(inst)
		end
	end
end

--==================================================
-- ROUND SIGNAL (best-effort)
--==================================================

local function tryHookRoundSignal()
	local containerNames = { "Game", "Round", "GameState", "GameInfo", "RoundState" }
	local flagNames = { "RoundActive", "InRound", "Round", "IsRound" }
	for _, cName in ipairs(containerNames) do
		local container = workspace:FindFirstChild(cName)
		if container then
			for _, fName in ipairs(flagNames) do
				local flag = container:FindFirstChild(fName)
				if flag and (flag:IsA("BoolValue") or flag:IsA("IntValue")) then
					flag.Changed:Connect(function(value)
						local active = (value == true) or (value == 1)
						if not active then resetRoleState() end
					end)
					return true
				end
			end
		end
	end
	return false
end

task.spawn(function()
	if not tryHookRoundSignal() then
		local tries = 0
		while gui.Parent and tries < 60 do
			task.wait(2)
			tries = tries + 1
			if tryHookRoundSignal() then break end
		end
	end
end)

--==================================================
-- AUTO CHAT MURDERER
--==================================================

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

local function checkAutoSendMurderer()
	if not autoSendMurdererChat then return end
	local murdererDetected = MurdererName ~= nil
	if not murdererDetected then
		if roundActive then
			roundActive = false
			lastChatSentMurderer = nil
		end
		return
	end
	if not roundActive then
		roundActive = true
		lastChatSentMurderer = nil
	end
	if lastChatSentMurderer == MurdererName then return end
	local now = tick()
	if now - chatSendCooldown < 1 then return end
	local targetPlayer = Players:FindFirstChild(MurdererName)
	local displayText = MurdererName
	if targetPlayer then displayText = targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")" end
	local message = "Murderer is: " .. displayText
	if sendChatMessage(message) then
		lastChatSentMurderer = MurdererName
		chatSendCooldown = now
	end
end

--==================================================
-- LOOPS
--==================================================

RunService.Stepped:Connect(function()
	if not noclip or not player.Character then return end
	for _, object in ipairs(player.Character:GetDescendants()) do
		if object:IsA("BasePart") then object.CanCollide = false end
	end
end)

RunService.Heartbeat:Connect(function()
	if not antiVoidEnabled or antiVoidCooldown then return end
	if flyEnabled then return end
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if root.Position.Y < VOID_Y_THRESHOLD then
		antiVoidCooldown = true
		local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
		local safePosition = nil
		if spawnLocation then
			safePosition = spawnLocation.Position + Vector3.new(0, 5, 0)
		else
			for _, target in ipairs(Players:GetPlayers()) do
				if target ~= player and target.Character then
					local tr = target.Character:FindFirstChild("HumanoidRootPart")
					if tr and tr.Position.Y > VOID_Y_THRESHOLD then
						safePosition = tr.Position + Vector3.new(0, 5, 0)
						break
					end
				end
			end
		end
		if safePosition then
			root.CFrame = CFrame.new(safePosition)
			root.Velocity = Vector3.zero
		else
			root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
			root.Velocity = Vector3.zero
		end
		task.delay(0.5, function() antiVoidCooldown = false end)
	end
end)

RunService.Heartbeat:Connect(function()
	if not antiFlingEnabled then return end
	if flyEnabled then return end
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local now = tick()
	local velocity = root.AssemblyLinearVelocity
	local speed = velocity.Magnitude
	if speed < 100 and root.Position.Y > -50 then
		lastSafePosition = root.CFrame
		lastSafeUpdate = now
	end
	if speed > ANTI_FLING_MAX_SPEED then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero
		if lastSafePosition and (now - lastSafeUpdate) < 5 then
			root.CFrame = lastSafePosition
		end
	end
	local angular = root.AssemblyAngularVelocity.Magnitude
	if angular > ANTI_FLING_MAX_ANGULAR then
		root.AssemblyAngularVelocity = Vector3.zero
		root.RotVelocity = Vector3.zero
	end
end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function(character)
	stopFly()
	flyControls.f = 0
	flyControls.b = 0
	flyControls.l = 0
	flyControls.r = 0
	flyControls.up = 0
	flyControls.down = 0
	lastFlyControls.f = 0
	lastFlyControls.b = 0
	lastFlyControls.l = 0
	lastFlyControls.r = 0
	lastFlyControls.up = 0
	lastFlyControls.down = 0
	originalCollision = {}
	lastSafePosition = nil
	antiVoidCooldown = false
	if noclip then
		task.wait(0.1)
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				originalCollision[object] = object.CanCollide
				object.CanCollide = false
			end
		end
	end
	task.wait(0.2)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		if speedhackEnabled then humanoid.WalkSpeed = speedhackSpeed end
	end
	UpdateHighlights()
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local dragStartPosition

header.InputBegan:Connect(function(input)
	if guiLocked then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		dragStartPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging or guiLocked then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			dragStartPosition.X.Scale, dragStartPosition.X.Offset + delta.X,
			dragStartPosition.Y.Scale, dragStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--==================================================
-- SHOW / MINIMIZE / CLOSE
--==================================================

local function showMenu()
	menuVisible = true
	frame.Visible = true
	reopenButton.Visible = false
end

local function minimizeMenu()
	menuVisible = false
	frame.Visible = false
	flyPanel.Visible = false
	flyPanelOpen = false
	reopenButton.Visible = true
end

local function closeScript()
	pcall(function() resetAllToggles(true) end)
	pcall(clearAllGunHighlights)
	sendNotification("MM2 Menu", "Script closed.")
	pcall(function() gui:Destroy() end)
end

lockButton.MouseButton1Click:Connect(function()
	guiLocked = not guiLocked
	if guiLocked then
		lockButton.Text = "LOCK"
		lockButton.BackgroundColor3 = Color3.fromRGB(70, 45, 45)
	else
		lockButton.Text = "L"
		lockButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
	end
end)

minimizeButton.MouseButton1Click:Connect(function()
	minimizeMenu()
	sendNotification("MM2 Menu", "Menu minimized. Click 'MM2' or press Right Shift to reopen.")
end)

closeButton.MouseButton1Click:Connect(function()
	closeScript()
end)

closeButton.MouseEnter:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
end)

closeButton.MouseLeave:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
end)

reopenButton.MouseButton1Click:Connect(function()
	showMenu()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if menuVisible then
			minimizeMenu()
		else
			showMenu()
		end
	end
end)

local reopenDragging = false
local reopenDragStart
local reopenDragStartPosition

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
-- INITIAL SETUP
--==================================================

refreshSpawnCache()
task.spawn(function()
	while gui.Parent do
		pcall(refreshSpawnCache)
		task.wait(10)
	end
end)

GetRoles()
UpdateHighlights()
updateGunESP()

task.spawn(function()
	while gui.Parent do
		pcall(function()
			GetRoles()
			UpdateHighlights()
			updateGunESP()

			if autoKillAll and MurdererName == player.Name then
				killAllPlayers()
			end

			if autoGunTP then
				local now = tick()
				if now - lastGunTP >= 1.5 then
					lastGunTP = now
					teleportToGun()
				end
			end

			checkAutoSendMurderer()
		end)

		task.wait(0.25)
	end
end)