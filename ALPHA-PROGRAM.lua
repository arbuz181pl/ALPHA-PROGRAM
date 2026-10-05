local P=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local SG=game:GetService("StarterGui")
local pl=P.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local function N(c,p,par)
local i=Instance.new(c)
if p then for k,v in pairs(p) do i[k]=v end end
if par then i.Parent=par end
return i
end
local RC={Innocent=Color3.fromRGB(50,210,90),Murderer=Color3.fromRGB(230,55,55),Sheriff=Color3.fromRGB(55,140,255),Hero=Color3.fromRGB(255,205,50)}
local GC=Color3.fromRGB(170,90,230)
local noclip=false
local infj=false
local fling3p=false
local flingInt=false
local flyOn=false
local notifyA=false
local autoKill=false
local autoGunTP=false
local autoChat=false
local antiVoid=false
local antiFling=false
local flySpeed=50
local shOn=false
local shSpeed=45
local guiLocked=false
local minimized=false
local menuVisible=true
local espOn={Innocent=false,Murderer=false,Sheriff=false,Hero=false}
local gunOn=false
local gunHLs={}
local origCol={}
local lastChat=nil
local roundActive=false
local chatCd=0
local flyBV=nil
local flyBG=nil
local flyCharacter=nil
local flingActive=false
local flingThread=nil
local VOID_Y=-50
local ANTIF_SPEED=200
local ANTIF_ANG=500
local lastSafe=nil
local lastSafeT=0
local GPD=nil
pcall(function() GPD=RS:FindFirstChild("GetPlayerData",true) end)
local M=nil
local S=nil
local H=nil
local lastM=nil
local lastS=nil
local lastH=nil
local cachedSpawns={}
local function note(t,x) pcall(function() SG:SetCore("SendNotification",{Title=t,Text=x,Duration=5}) end) end
local old=pg:FindFirstChild("MM2MenuByArbuz")
if old then old:Destroy() end
local gui=N("ScreenGui",{Name="MM2MenuByArbuz",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100},pg)
local frame=N("Frame",{Name="Main",Size=UDim2.fromOffset(280,330),Position=UDim2.new(0.5,-140,0.5,-165),BackgroundColor3=Color3.fromRGB(22,23,28),BorderSizePixel=0,Active=true},gui)
N("UICorner",{CornerRadius=UDim.new(0,12)},frame)
N("UIStroke",{Color=Color3.fromRGB(55,57,65),Thickness=1},frame)
local header=N("Frame",{Name="Header",Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(29,30,37),BorderSizePixel=0,Active=true},frame)
N("UICorner",{CornerRadius=UDim.new(0,12)},header)
N("TextLabel",{Name="Title",Size=UDim2.new(1,-120,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text="MM2 MENU BY ARBUZ v0.9BETA",TextColor3=Color3.fromRGB(245,245,250),TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=2},header)
local closeBtn=N("TextButton",{Name="Close",Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-105,0.5,-15),BackgroundColor3=Color3.fromRGB(42,44,52),Text="X",TextSize=16,TextColor3=Color3.fromRGB(255,200,200),Font=Enum.Font.GothamBold,BorderSizePixel=0,AutoButtonColor=false,Active=true,ZIndex=5},header)
N("UICorner",{CornerRadius=UDim.new(0,7)},closeBtn)
local lockBtn=N("TextButton",{Name="Lock",Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-70,0.5,-15),BackgroundColor3=Color3.fromRGB(42,44,52),Text="L",TextSize=14,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,BorderSizePixel=0,AutoButtonColor=false,Active=true,ZIndex=5},header)
N("UICorner",{CornerRadius=UDim.new(0,7)},lockBtn)
local minBtn=N("TextButton",{Name="Minimize",Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-35,0.5,-15),BackgroundColor3=Color3.fromRGB(42,44,52),Text="-",TextColor3=Color3.new(1,1,1),TextSize=17,Font=Enum.Font.GothamBold,BorderSizePixel=0,AutoButtonColor=false,Active=true,ZIndex=5},header)
N("UICorner",{CornerRadius=UDim.new(0,7)},minBtn)
local resizeH=N("TextButton",{Name="ResizeHandle",Size=UDim2.fromOffset(16,16),Position=UDim2.new(1,-16,1,-16),BackgroundColor3=Color3.fromRGB(55,57,65),BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,ZIndex=30},frame)
N("UICorner",{CornerRadius=UDim.new(0,4)},resizeH)
local reopening=false
resizeH.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
reopening=true
local rStart=input.Position
local rSize=frame.AbsoluteSize
local c1
c1=U.InputChanged:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
local d=i.Position-rStart
frame.Size=UDim2.fromOffset(math.max(240,rSize.X+d.X),math.max(200,rSize.Y+d.Y))
end
end)
local c2
c2=U.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
c1:Disconnect()
c2:Disconnect()
end
end)
end
end)
local reopen=N("TextButton",{Name="Reopen",Size=UDim2.fromOffset(50,50),Position=UDim2.new(0,15,0.5,-25),BackgroundColor3=Color3.fromRGB(29,30,37),BorderSizePixel=0,Text="MM2",TextColor3=Color3.fromRGB(245,245,250),TextSize=13,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Visible=false,ZIndex=50},gui)
N("UICorner",{CornerRadius=UDim.new(1,0)},reopen)
N("UIStroke",{Color=Color3.fromRGB(80,82,90),Thickness=2},reopen)
local content=N("ScrollingFrame",{Name="Content",Size=UDim2.new(1,-20,1,-58),Position=UDim2.fromOffset(10,53),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=Color3.fromRGB(75,77,85),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y},frame)
N("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},content)
local LO=0
local function nLO() LO=LO+1 return LO end
local function sec(t)
N("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=t,TextColor3=Color3.fromRGB(150,153,165),TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=nLO()},content)
end
local function tog(t)
local b=N("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text=t,TextColor3=Color3.fromRGB(230,230,235),TextSize=13,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,LayoutOrder=nLO()},content)
N("UICorner",{CornerRadius=UDim.new(0,8)},b)
local i=N("Frame",{Name="Indicator",Size=UDim2.fromOffset(5,20),Position=UDim2.fromOffset(8,8),BackgroundColor3=Color3.fromRGB(80,82,90),BorderSizePixel=0},b)
N("UICorner",{CornerRadius=UDim.new(1,0)},i)
return b,i
end
local function btn(t)
local b=N("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text=t,TextColor3=Color3.fromRGB(230,230,235),TextSize=13,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,LayoutOrder=nLO()},content)
N("UICorner",{CornerRadius=UDim.new(0,8)},b)
return b
end
local function on_(b,i) b.BackgroundColor3=Color3.fromRGB(35,70,45) i.BackgroundColor3=Color3.fromRGB(50,210,90) end
local function off_(b,i) b.BackgroundColor3=Color3.fromRGB(34,36,43) i.BackgroundColor3=Color3.fromRGB(80,82,90) end
local function rc()
local n={}
for _,x in ipairs(workspace:GetDescendants()) do
if x:IsA("SpawnLocation") or (x:IsA("BasePart") and x.Name=="SpawnPoint") then table.insert(n,x) end
end
cachedSpawns=n
end
local function inSp(t)
if not t or not t.Character then return true end
local lb=workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyMap")
if lb and t.Character:IsDescendantOf(lb) then return true end
local tr=t.Character:FindFirstChild("HumanoidRootPart")
if not tr then return true end
for _,s in ipairs(cachedSpawns) do
if s and s.Parent and (tr.Position-s.Position).Magnitude<35 then return true end
end
return false
end
rc()
task.spawn(function() while gui.Parent do pcall(rc) task.wait(10) end end)
sec("MOVEMENT SETTINGS")
local ncb,nci=tog("Noclip")
ncb.MouseButton1Click:Connect(function()
noclip=not noclip
if noclip then
on_(ncb,nci)
origCol={}
if pl.Character then
for _,o in ipairs(pl.Character:GetDescendants()) do
if o:IsA("BasePart") then origCol[o]=o.CanCollide o.CanCollide=false end
end
end
else
off_(ncb,nci)
for o,v in pairs(origCol) do if o and o.Parent then o.CanCollide=v end end
origCol={}
end
end)
R.Stepped:Connect(function()
if not noclip or not pl.Character then return end
for _,o in ipairs(pl.Character:GetDescendants()) do
if o:IsA("BasePart") then o.CanCollide=false end
end
end)
local flyBtn,flyInd=tog("Fly")
local flyPanel=N("Frame",{Name="FlyPanel",Size=UDim2.fromOffset(210,220),Position=UDim2.new(0.5,150,0.5,-110),BackgroundColor3=Color3.fromRGB(22,23,28),BorderSizePixel=0,Visible=false,ZIndex=20},gui)
N("UICorner",{CornerRadius=UDim.new(0,12)},flyPanel)
N("UIStroke",{Color=Color3.fromRGB(55,57,65),Thickness=1},flyPanel)
local flyHd=N("Frame",{Name="Header",Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(29,30,37),BorderSizePixel=0,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,12)},flyHd)
N("TextLabel",{Name="Title",Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text="FLY",TextColor3=Color3.fromRGB(245,245,250),TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=22},flyHd)
local flyEnable=N("TextButton",{Name="Enable",Size=UDim2.new(1,-20,0,36),Position=UDim2.fromOffset(10,52),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="Enable Fly",TextColor3=Color3.fromRGB(230,230,235),TextSize=13,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,8)},flyEnable)
local flyEnInd=N("Frame",{Name="Indicator",Size=UDim2.fromOffset(5,20),Position=UDim2.fromOffset(8,8),BackgroundColor3=Color3.fromRGB(80,82,90),BorderSizePixel=0,ZIndex=22},flyEnable)
N("UICorner",{CornerRadius=UDim.new(1,0)},flyEnInd)
local flySpdLbl=N("TextLabel",{Name="SpeedLabel",Size=UDim2.new(1,-20,0,20),Position=UDim2.fromOffset(10,98),BackgroundTransparency=1,Text="Speed: 50",TextColor3=Color3.fromRGB(150,153,165),TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21},flyPanel)
local flyMin=N("TextButton",{Name="Minus",Size=UDim2.fromOffset(36,32),Position=UDim2.fromOffset(10,123),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="-",TextColor3=Color3.fromRGB(235,235,240),TextSize=18,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,7)},flyMin)
local flyBox=N("TextBox",{Name="Speed",Size=UDim2.new(1,-96,0,32),Position=UDim2.fromOffset(52,123),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="50",TextColor3=Color3.fromRGB(235,235,240),TextSize=12,Font=Enum.Font.GothamSemibold,ClearTextOnFocus=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,7)},flyBox)
local flyPls=N("TextButton",{Name="Plus",Size=UDim2.fromOffset(36,32),Position=UDim2.new(1,-46,0,123),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="+",TextColor3=Color3.fromRGB(235,235,240),TextSize=18,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,7)},flyPls)
local flyUp=N("TextButton",{Name="Up",Size=UDim2.fromOffset(85,32),Position=UDim2.fromOffset(10,168),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="UP",TextColor3=Color3.fromRGB(230,230,235),TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,7)},flyUp)
local flyDown=N("TextButton",{Name="Down",Size=UDim2.fromOffset(85,32),Position=UDim2.new(1,-95,0,168),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="DOWN",TextColor3=Color3.fromRGB(230,230,235),TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21},flyPanel)
N("UICorner",{CornerRadius=UDim.new(0,7)},flyDown)
local function setFlySpd(v)
v=tonumber(v) or flySpeed
v=math.clamp(math.floor(v),1,500)
flySpeed=v
flySpdLbl.Text="Speed: "..tostring(v)
flyBox.Text=tostring(v)
end
flyMin.MouseButton1Click:Connect(function() setFlySpd(flySpeed-1) end)
flyPls.MouseButton1Click:Connect(function() setFlySpd(flySpeed+1) end)
flyBox.FocusLost:Connect(function() setFlySpd(flyBox.Text) end)
local function stopFly()
flyOn=false
if flyBV then flyBV:Destroy() flyBV=nil end
if flyBG then flyBG:Destroy() flyBG=nil end
flyCharacter=nil
local c=pl.Character
if c then
local h=c:FindFirstChildOfClass("Humanoid")
if h then h.PlatformStand=false end
local a=c:FindFirstChild("Animate")
if a then a.Disabled=false end
end
flyEnable.Text="Enable Fly"
off_(flyEnable,flyEnInd)
off_(flyBtn,flyInd)
end
local function startFly()
local c=pl.Character
if not c then return end
local h=c:FindFirstChildOfClass("Humanoid")
local r=c:FindFirstChild("HumanoidRootPart")
if not h or not r then return end
flyOn=true
flyCharacter=c
h.PlatformStand=true
local a=c:FindFirstChild("Animate")
if a then a.Disabled=true end
flyBG=N("BodyGyro",{P=90000,MaxTorque=Vector3.new(9e9,9e9,9e9),CFrame=r.CFrame},r)
flyBV=N("BodyVelocity",{MaxForce=Vector3.new(9e9,9e9,9e9),Velocity=Vector3.zero},r)
flyEnable.Text="Disable Fly"
on_(flyEnable,flyEnInd)
on_(flyBtn,flyInd)
end
flyEnable.MouseButton1Click:Connect(function() if flyOn then stopFly() else startFly() end end)
flyBtn.MouseButton1Click:Connect(function()
flyPanel.Visible=not flyPanel.Visible
if flyPanel.Visible then flyBtn.BackgroundColor3=Color3.fromRGB(45,47,56)
elseif flyOn then on_(flyBtn,flyInd)
else off_(flyBtn,flyInd) end
end)
R.RenderStepped:Connect(function()
if not flyOn or not flyBV or not flyBG then return end
local c=pl.Character
if not c then stopFly() return end
local r=c:FindFirstChild("HumanoidRootPart")
local cam=workspace.CurrentCamera
if not r or not cam then return end
local d=Vector3.zero
if U:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
if U:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
if U:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
if U:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
if U:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
if U:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
if d.Magnitude>0 then flyBV.Velocity=d.Unit*flySpeed else flyBV.Velocity=Vector3.zero end
flyBG.CFrame=cam.CFrame
end)
local ijb,iji=tog("Infinity Jump")
ijb.MouseButton1Click:Connect(function()
infj=not infj
if infj then on_(ijb,iji) else off_(ijb,iji) end
end)
U.JumpRequest:Connect(function()
if not infj then return end
local c=pl.Character
if not c then return end
local h=c:FindFirstChildOfClass("Humanoid")
if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
local shb,shi=tog("Speedhack")
local shRow=N("Frame",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=nLO()},content)
local shMin=N("TextButton",{Size=UDim2.fromOffset(36,32),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="-",TextColor3=Color3.fromRGB(235,235,240),TextSize=18,Font=Enum.Font.GothamBold,AutoButtonColor=false},shRow)
N("UICorner",{CornerRadius=UDim.new(0,7)},shMin)
local shBox=N("TextBox",{Size=UDim2.fromOffset(50,32),Position=UDim2.fromOffset(42,0),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="45",TextColor3=Color3.fromRGB(235,235,240),TextSize=12,Font=Enum.Font.GothamSemibold,ClearTextOnFocus=false},shRow)
N("UICorner",{CornerRadius=UDim.new(0,7)},shBox)
local shPls=N("TextButton",{Size=UDim2.fromOffset(36,32),Position=UDim2.fromOffset(100,0),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="+",TextColor3=Color3.fromRGB(235,235,240),TextSize=18,Font=Enum.Font.GothamBold,AutoButtonColor=false},shRow)
N("UICorner",{CornerRadius=UDim.new(0,7)},shPls)
N("TextLabel",{Size=UDim2.new(1,-145,0,32),Position=UDim2.fromOffset(145,0),BackgroundTransparency=1,Text="WalkSpeed",TextColor3=Color3.fromRGB(150,153,165),TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},shRow)
local function setSh(v)
v=tonumber(v) or shSpeed
v=math.clamp(math.floor(v),1,500)
shSpeed=v
shBox.Text=tostring(v)
end
shMin.MouseButton1Click:Connect(function() setSh(shSpeed-5) end)
shPls.MouseButton1Click:Connect(function() setSh(shSpeed+5) end)
shBox.FocusLost:Connect(function() setSh(shBox.Text) end)
shb.MouseButton1Click:Connect(function()
shOn=not shOn
if shOn then
on_(shb,shi)
local c=pl.Character
if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=shSpeed end end
else
off_(shb,shi)
local c=pl.Character
if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end
end
end)
R.RenderStepped:Connect(function()
if not shOn then return end
local c=pl.Character
if not c then return end
local h=c:FindFirstChildOfClass("Humanoid")
if h then h.WalkSpeed=shSpeed end
end)
sec("FLING SETTINGS")
local f3b,f3i=tog("Fling 3rd party")
f3b.MouseButton1Click:Connect(function()
fling3p=not fling3p
if fling3p then
f3b.BackgroundColor3=Color3.fromRGB(70,45,35)
f3i.BackgroundColor3=Color3.fromRGB(230,100,55)
local ok=pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Ultimate-Fling-GUI-41909"))() end)
if not ok then note("MM2 Menu","Failed to load 3rd party fling script.") end
else off_(f3b,f3i) end
end)
local function flingLoop()
local lp=pl
local c,hrp,vel,movel=nil,nil,nil,0.1
while flingActive do
R.Heartbeat:Wait()
c=lp.Character
hrp=c and c:FindFirstChild("HumanoidRootPart")
if hrp then
vel=hrp.Velocity
hrp.Velocity=vel*10000+Vector3.new(0,10000,0)
R.RenderStepped:Wait()
hrp.Velocity=vel
R.Stepped:Wait()
hrp.Velocity=vel+Vector3.new(0,movel,0)
movel=-movel
end
end
end
local fib,fii=tog("Fling On Touch")
fib.MouseButton1Click:Connect(function()
flingInt=not flingInt
if flingInt then
fib.BackgroundColor3=Color3.fromRGB(70,45,35)
fii.BackgroundColor3=Color3.fromRGB(230,100,55)
flingActive=true
flingThread=coroutine.create(flingLoop)
coroutine.resume(flingThread)
else
off_(fib,fii)
flingActive=false
end
end)
sec("ROLE ESP SETTINGS")
local espB={}
local function mkEsp(r)
local b,i=tog(r.." ESP")
espB[r]={b=b,i=i}
b.MouseButton1Click:Connect(function()
espOn[r]=not espOn[r]
if espOn[r] then
b.BackgroundColor3=RC[r]:Lerp(Color3.fromRGB(20,20,25),0.65)
i.BackgroundColor3=RC[r]
else off_(b,i) end
end)
end
mkEsp("Innocent")
mkEsp("Murderer")
mkEsp("Sheriff")
mkEsp("Hero")
sec("ITEM ESP SETTINGS")
local gunBtn,gunInd=tog("Gun ESP")
gunBtn.MouseButton1Click:Connect(function()
gunOn=not gunOn
if gunOn then
gunBtn.BackgroundColor3=GC:Lerp(Color3.fromRGB(20,20,25),0.65)
gunInd.BackgroundColor3=GC
else
off_(gunBtn,gunInd)
for g,h in pairs(gunHLs) do if h then pcall(function() h:Destroy() end) end end
gunHLs={}
end
end)
sec("NOTIFIER SETTINGS")
local function fmt(r,n)
if not n then return r..": None" end
local t=P:FindFirstChild(n)
if t then return r..": "..t.DisplayName.." (@"..t.Name..")" end
return r..": "..n
end
local function notifyAll()
note("MM2 Roles",fmt("Murderer",M).."\n"..fmt("Sheriff",S).."\n"..fmt("Hero",H))
end
btn("Notify Roles").MouseButton1Click:Connect(notifyAll)
local anb,ani=tog("Auto Notify Round")
anb.MouseButton1Click:Connect(function()
notifyA=not notifyA
if notifyA then on_(anb,ani) else off_(anb,ani) end
end)
local acb,aci=tog("Auto Send Murderer In Chat")
acb.MouseButton1Click:Connect(function()
autoChat=not autoChat
if autoChat then on_(acb,aci) lastChat=nil roundActive=false
else off_(acb,aci) lastChat=nil roundActive=false end
end)
sec("MURDERER SETTINGS")
local function getKnife()
local c=pl.Character
if not c then return nil end
local k=c:FindFirstChild("Knife")
if not k then
local bp=pl:FindFirstChild("Backpack")
if bp then k=bp:FindFirstChild("Knife") if k then k.Parent=c end end
end
return k
end
local function attack(t)
if not t or t==pl or not t.Character then return end
if inSp(t) then return end
local tr=t.Character:FindFirstChild("HumanoidRootPart")
local mr=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
if tr and mr then
local k=getKnife()
if k then
mr.CFrame=tr.CFrame*CFrame.new(0,0,1.5)
task.wait(0.05)
pcall(function() k:Activate() end)
end
end
end
local function killAll()
for _,t in ipairs(P:GetPlayers()) do
if t~=pl and t.Character then
local h=t.Character:FindFirstChildOfClass("Humanoid")
if h and h.Health>0 and not inSp(t) then attack(t) task.wait(0.2) end
end
end
end
local function killN(n)
if not n then return end
local t=P:FindFirstChild(n)
if t then attack(t) end
end
local akb,aki=tog("Auto Kill All")
akb.MouseButton1Click:Connect(function()
autoKill=not autoKill
if autoKill then on_(akb,aki) else off_(akb,aki) end
end)
btn("Kill All Now").MouseButton1Click:Connect(killAll)
btn("Kill Sheriff Now").MouseButton1Click:Connect(function() killN(S) end)
btn("Kill Hero Now").MouseButton1Click:Connect(function() killN(H) end)
sec("SHERIFF SETTINGS")
local function getGun()
local c=pl.Character
if not c then return nil end
local g=c:FindFirstChild("Gun")
if not g then
local bp=pl:FindFirstChild("Backpack")
if bp then g=bp:FindFirstChild("Gun") if g then g.Parent=c end end
end
return g
end
btn("Kill Murderer Now").MouseButton1Click:Connect(function()
if not M then note("MM2 Menu","Murderer not found yet!") return end
local t=P:FindFirstChild(M)
if not t or not t.Character then return end
if inSp(t) then note("MM2 Menu","Murderer is in spawn/lobby!") return end
local tr=t.Character:FindFirstChild("HumanoidRootPart")
local mr=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
if tr and mr then
local g=getGun()
if g then
mr.CFrame=tr.CFrame*CFrame.new(0,0,5)
task.wait(0.08)
local sr=g:FindFirstChild("Shoot") or RS:FindFirstChild("Shoot",true)
if sr and sr:IsA("RemoteEvent") then pcall(function() sr:FireServer(tr.CFrame,tr.Position) end)
else pcall(function() g:Activate() end) end
else note("MM2 Menu","You do not have a Gun equipped!") end
end
end)
sec("TELEPORT SETTINGS")
local function tpGun()
local c=pl.Character
if not c then return false end
local mr=c:FindFirstChild("HumanoidRootPart")
if not mr then return false end
local gd=workspace:FindFirstChild("GunDrop",true) or workspace:FindFirstChild("Gun",true)
if not gd then return false end
local tp=nil
if gd:IsA("BasePart") then tp=gd
elseif gd:IsA("Model") then tp=gd.PrimaryPart or gd:FindFirstChildOfClass("BasePart")
elseif gd:IsA("Tool") then tp=gd:FindFirstChild("Handle") or gd:FindFirstChildOfClass("BasePart")
end
if not tp then return false end
if (mr.Position-tp.Position).Magnitude<8 then return true end
mr.CFrame=tp.CFrame+Vector3.new(0,3,0)
return true
end
local agb,agi=tog("Auto Teleport To Gun")
agb.MouseButton1Click:Connect(function()
autoGunTP=not autoGunTP
if autoGunTP then on_(agb,agi) else off_(agb,agi) end
end)
btn("Teleport To Spawn").MouseButton1Click:Connect(function()
local c=pl.Character
if not c then return end
local mr=c:FindFirstChild("HumanoidRootPart")
if not mr then return end
local sl=workspace:FindFirstChildOfClass("SpawnLocation")
if sl then mr.CFrame=sl.CFrame+Vector3.new(0,3,0) return end
local sp=workspace:FindFirstChild("Spawn",true)
if sp and sp:IsA("BasePart") then mr.CFrame=sp.CFrame+Vector3.new(0,3,0) end
end)
btn("Teleport To Gun").MouseButton1Click:Connect(function()
if not tpGun() then note("MM2 Menu","No dropped gun found on the map!") end
end)
local sel=nil
local ddBtn=N("TextButton",{Name="PlayerDropdown",Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text="Select Player",TextColor3=Color3.fromRGB(230,230,235),TextSize=12,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,LayoutOrder=nLO()},content)
N("UICorner",{CornerRadius=UDim.new(0,8)},ddBtn)
local ddOpen=false
local plist=N("ScrollingFrame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=Color3.fromRGB(29,30,37),BorderSizePixel=0,Visible=false,ClipsDescendants=true,AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,LayoutOrder=nLO()},content)
N("UICorner",{CornerRadius=UDim.new(0,8)},plist)
N("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.Name},plist)
local function refreshList()
for _,ch in ipairs(plist:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
for _,t in ipairs(P:GetPlayers()) do
if t~=pl then
local o=N("TextButton",{Name=t.Name,Size=UDim2.new(1,-10,0,30),BackgroundColor3=Color3.fromRGB(34,36,43),BorderSizePixel=0,Text=t.DisplayName.." (@"..t.Name..")",TextColor3=Color3.fromRGB(230,230,235),TextSize=12,Font=Enum.Font.GothamSemibold,AutoButtonColor=false},plist)
N("UICorner",{CornerRadius=UDim.new(0,6)},o)
o.MouseButton1Click:Connect(function()
sel=t
ddBtn.Text="Selected: "..t.Name
ddOpen=false
plist.Visible=false
plist.Size=UDim2.new(1,0,0,0)
end)
end
end
end
ddBtn.MouseButton1Click:Connect(function()
ddOpen=not ddOpen
if ddOpen then
refreshList()
plist.Visible=true
plist.Size=UDim2.new(1,0,0,120)
else
plist.Visible=false
plist.Size=UDim2.new(1,0,0,0)
end
end)
btn("Teleport To Player").MouseButton1Click:Connect(function()
if not sel or not sel.Character then return end
local tr=sel.Character:FindFirstChild("HumanoidRootPart")
local c=pl.Character
if c and tr then
local mr=c:FindFirstChild("HumanoidRootPart")
if mr then mr.CFrame=tr.CFrame+Vector3.new(0,3,0) end
end
end)
btn("Kill Selected Player").MouseButton1Click:Connect(function()
if sel then attack(sel) end
end)
P.PlayerAdded:Connect(function() if ddOpen then refreshList() end end)
P.PlayerRemoving:Connect(function(t)
if sel==t then sel=nil ddBtn.Text="Select Player" end
if ddOpen then refreshList() end
end)
local function tpN(n)
if not n then return end
local t=P:FindFirstChild(n)
if not t or not t.Character then return end
local tr=t.Character:FindFirstChild("HumanoidRootPart")
local c=pl.Character
if c and tr then
local mr=c:FindFirstChild("HumanoidRootPart")
if mr then mr.CFrame=tr.CFrame+Vector3.new(0,3,0) end
end
end
btn("Teleport To Murderer").MouseButton1Click:Connect(function() tpN(M) end)
btn("Teleport To Sheriff").MouseButton1Click:Connect(function() tpN(S) end)
btn("Teleport To Hero").MouseButton1Click:Connect(function() tpN(H) end)
sec("UTILITY SETTINGS")
local avb,avi=tog("Anti Fall Down (Void)")
local afb,afi=tog("Anti Fling")
avb.MouseButton1Click:Connect(function()
antiVoid=not antiVoid
if antiVoid then on_(avb,avi) else off_(avb,avi) end
end)
afb.MouseButton1Click:Connect(function()
antiFling=not antiFling
if antiFling then on_(afb,afi) else off_(afb,afi) end
end)
local function offAll()
if noclip then noclip=false off_(ncb,nci) for o,v in pairs(origCol) do if o and o.Parent then o.CanCollide=v end end origCol={} end
if flyOn then stopFly() end
flyPanel.Visible=false
if infj then infj=false off_(ijb,iji) end
if shOn then shOn=false off_(shb,shi) local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end end
if fling3p then fling3p=false off_(f3b,f3i) end
if flingInt then flingInt=false flingActive=false off_(fib,fii) end
for r,s in pairs(espOn) do if s then espOn[r]=false if espB[r] then off_(espB[r].b,espB[r].i) end end end
if gunOn then gunOn=false off_(gunBtn,gunInd) for g,h in pairs(gunHLs) do if h then pcall(function() h:Destroy() end) end end gunHLs={} end
if notifyA then notifyA=false off_(anb,ani) end
if autoChat then autoChat=false off_(acb,aci) lastChat=nil roundActive=false end
if autoKill then autoKill=false off_(akb,aki) end
if autoGunTP then autoGunTP=false off_(agb,agi) end
if antiVoid then antiVoid=false off_(avb,avi) end
if antiFling then antiFling=false off_(afb,afi) end
note("MM2 Menu","All features turned off")
end
local toBtn=N("TextButton",{Name="TurnOffAll",Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(70,40,40),BorderSizePixel=0,Text="TURN OFF ALL",TextColor3=Color3.fromRGB(255,200,200),TextSize=13,Font=Enum.Font.GothamBold,AutoButtonColor=false,LayoutOrder=nLO()},content)
N("UICorner",{CornerRadius=UDim.new(0,8)},toBtn)
toBtn.MouseButton1Click:Connect(offAll)
local HLs={}
local function mkHL(t)
if t==pl or not t.Character then return end
local h=t.Character:FindFirstChild("RoleESP")
if not h then
h=N("Highlight",{Name="RoleESP",FillTransparency=0.45,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},t.Character)
end
HLs[t]=h
end
local function isAlive(t)
if not t or not t.Character then return false end
local h=t.Character:FindFirstChildOfClass("Humanoid")
return h and h.Health>0
end
local function validRoleHolder(t)
if not t then return false end
if not t.Character then return false end
local h=t.Character:FindFirstChildOfClass("Humanoid")
if not h or h.Health<=0 then return false end
if inSp(t) then return false end
return true
end
local function cachedValid(n)
if not n then return false end
local t=P:FindFirstChild(n)
if not t then return false end
return validRoleHolder(t)
end
local function resolveRole(n)
if not n then return nil end
local t=P:FindFirstChild(n)
if not t then return nil end
if not validRoleHolder(t) then return nil end
return n
end
local function getRoles()
if not GPD then return end
local ok,res=pcall(function() return GPD:InvokeServer() end)
if not ok or type(res)~="table" then return end
local nm,ns,nh=nil,nil,nil
for k,v in pairs(res) do
if type(v)=="table" then
if v.Role=="Murderer" then nm=tostring(k)
elseif v.Role=="Sheriff" then ns=tostring(k)
elseif v.Role=="Hero" then nh=tostring(k) end
elseif type(v)=="string" then
if v=="Murderer" then nm=tostring(k)
elseif v=="Sheriff" then ns=tostring(k)
elseif v=="Hero" then nh=tostring(k) end
end
end
for k,v in pairs(res) do
if typeof(k)=="Instance" and k:IsA("Player") then
local r=type(v)=="table" and v.Role or (type(v)=="string" and v or nil)
if r=="Murderer" then nm=k.Name
elseif r=="Sheriff" then ns=k.Name
elseif r=="Hero" then nh=k.Name end
end
end
for _,t in ipairs(P:GetPlayers()) do
local r=t:GetAttribute("Role")
if r=="Murderer" then nm=t.Name
elseif r=="Sheriff" then ns=t.Name
elseif r=="Hero" then nh=t.Name end
end
nm=resolveRole(nm)
ns=resolveRole(ns)
nh=resolveRole(nh)
if nm then M=nm elseif M and not cachedValid(M) then M=nil lastM=nil lastChat=nil roundActive=false end
if ns then S=ns elseif S and not cachedValid(S) then S=nil lastS=nil end
if nh then H=nh elseif H and not cachedValid(H) then H=nil lastH=nil end
if notifyA then
if (M and M~=lastM) or (S and S~=lastS) or (H and H~=lastH) then
lastM=M lastS=S lastH=H
notifyAll()
end
end
end
local function upHL()
for _,t in ipairs(P:GetPlayers()) do
if t~=pl and t.Character then
mkHL(t)
local h=t.Character:FindFirstChild("RoleESP")
if h then
local role
if M and t.Name==M then role="Murderer"
elseif S and t.Name==S then role="Sheriff"
elseif H and t.Name==H then role="Hero"
else role="Innocent" end
local showRole=isAlive(t) and not inSp(t)
if not showRole then
if espOn.Innocent then
h.FillColor=RC.Innocent
h.OutlineColor=RC.Innocent
h.FillTransparency=0.7
h.OutlineTransparency=0.2
h.Enabled=true
else h.Enabled=false end
else
if espOn[role] then
h.FillColor=RC[role]
h.OutlineColor=RC[role]
h.FillTransparency=0.45
h.OutlineTransparency=0
h.Enabled=true
else h.Enabled=false end
end
end
end
end
end
local function rmHL(t)
if t.Character then
local h=t.Character:FindFirstChild("RoleESP")
if h then h:Destroy() end
end
HLs[t]=nil
end
for _,t in ipairs(P:GetPlayers()) do
if t~=pl then
t.CharacterAdded:Connect(function() task.wait(0.2) mkHL(t) upHL() end)
if t.Character then mkHL(t) end
end
end
P.PlayerAdded:Connect(function(t)
t.CharacterAdded:Connect(function() task.wait(0.2) mkHL(t) upHL() end)
end)
P.PlayerRemoving:Connect(function(t)
rmHL(t)
if M==t.Name then M=nil end
if S==t.Name then S=nil end
if H==t.Name then H=nil end
end)
local lastGunScan=0
local function heldBy(g)
for _,p in ipairs(P:GetPlayers()) do
local c=p.Character
if c and g:IsDescendantOf(c) then return true end
end
return false
end
local function isDGun(i)
if not i or not i.Parent then return false end
if i.Name~="Gun" and i.Name~="GunDrop" then return false end
if not (i:IsA("BasePart") or i:IsA("Model") or i:IsA("Tool")) then return false end
if heldBy(i) then return false end
return true
end
local function upGun()
for g,_ in pairs(gunHLs) do
if not g or not g.Parent or not isDGun(g) then
local h=gunHLs[g]
if h then pcall(function() h:Destroy() end) end
gunHLs[g]=nil
end
end
if not gunOn then return end
local n=tick()
if n-lastGunScan<0.5 then return end
lastGunScan=n
for _,i in ipairs(workspace:GetDescendants()) do
if isDGun(i) and not gunHLs[i] then
local h=N("Highlight",{Name="GunESP",FillColor=GC,OutlineColor=GC,FillTransparency=0.4,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},i)
gunHLs[i]=h
end
end
end
local function sendChat(msg)
local sent=false
pcall(function()
local TCS=game:GetService("TextChatService")
if TCS.ChatVersion==Enum.ChatVersion.TextChatService then
local ch=TCS:FindFirstChild("TextChannels")
if ch then
local gen=ch:FindFirstChild("RBXGeneral")
if gen then gen:SendAsync(msg) sent=true end
end
end
end)
if sent then return true end
pcall(function() SG:SetCore("ChatSendMessage",msg) sent=true end)
return sent
end
local function checkChat()
if not autoChat then return end
if not M then
if roundActive then roundActive=false lastChat=nil end
return
end
if not roundActive then roundActive=true lastChat=nil end
if lastChat==M then return end
local n=tick()
if n-chatCd<1 then return end
local tp=P:FindFirstChild(M)
local dt=M
if tp then dt=tp.DisplayName.." (@"..tp.Name..")" end
if sendChat("Murderer is: "..dt) then
lastChat=M
chatCd=n
end
end
R.Heartbeat:Connect(function()
if not antiVoid then return end
if flyOn then return end
local c=pl.Character
if not c then return end
local r=c:FindFirstChild("HumanoidRootPart")
if not r then return end
if r.Position.Y<VOID_Y then
local sl=workspace:FindFirstChildOfClass("SpawnLocation")
if sl then r.CFrame=CFrame.new(sl.Position+Vector3.new(0,5,0))
else r.CFrame=CFrame.new(r.Position.X,100,r.Position.Z) end
r.Velocity=Vector3.zero
end
end)
R.Heartbeat:Connect(function()
if not antiFling then return end
if flyOn then return end
local c=pl.Character
if not c then return end
local r=c:FindFirstChild("HumanoidRootPart")
if not r then return end
local now=tick()
local v=r.AssemblyLinearVelocity
if v.Magnitude<100 and r.Position.Y>-50 then
lastSafe=r.CFrame
lastSafeT=now
end
if v.Magnitude>ANTIF_SPEED then
r.AssemblyLinearVelocity=Vector3.zero
r.AssemblyAngularVelocity=Vector3.zero
r.RotVelocity=Vector3.zero
if lastSafe and (now-lastSafeT)<5 then r.CFrame=lastSafe end
end
if r.AssemblyAngularVelocity.Magnitude>ANTIF_ANG then
r.AssemblyAngularVelocity=Vector3.zero
r.RotVelocity=Vector3.zero
end
end)
pl.CharacterAdded:Connect(function(c)
stopFly()
origCol={}
lastSafe=nil
if noclip then
task.wait(0.1)
for _,o in ipairs(c:GetDescendants()) do
if o:IsA("BasePart") then origCol[o]=o.CanCollide o.CanCollide=false end
end
end
task.wait(0.2)
local h=c:FindFirstChildOfClass("Humanoid")
if h then
h.PlatformStand=false
if shOn then h.WalkSpeed=shSpeed end
end
upHL()
end)
local dragging=false
local dragS=nil
local dragP=nil
header.InputBegan:Connect(function(i)
if guiLocked then return end
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragS=i.Position
dragP=frame.Position
end
end)
U.InputChanged:Connect(function(i)
if not dragging or guiLocked then return end
if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
local d=i.Position-dragS
frame.Position=UDim2.new(dragP.X.Scale,dragP.X.Offset+d.X,dragP.Y.Scale,dragP.Y.Offset+d.Y)
end
end)
U.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
local function showMenu()
menuVisible=true
frame.Visible=true
reopen.Visible=false
end
local function hideMenu()
menuVisible=false
frame.Visible=false
flyPanel.Visible=false
reopen.Visible=true
end
lockBtn.MouseButton1Click:Connect(function()
guiLocked=not guiLocked
if guiLocked then
lockBtn.Text="LOCK"
lockBtn.BackgroundColor3=Color3.fromRGB(70,45,45)
else
lockBtn.Text="L"
lockBtn.BackgroundColor3=Color3.fromRGB(42,44,52)
end
end)
minBtn.MouseButton1Click:Connect(function()
minimized=not minimized
if minimized then
content.Visible=false
frame.Size=UDim2.fromOffset(280,48)
minBtn.Text="+"
else
content.Visible=true
frame.Size=UDim2.fromOffset(280,330)
minBtn.Text="-"
end
end)
closeBtn.MouseButton1Click:Connect(function()
hideMenu()
note("MM2 Menu","Menu closed. Click 'MM2' or press Right Shift to reopen.")
end)
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3=Color3.fromRGB(180,55,55) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3=Color3.fromRGB(42,44,52) end)
reopen.MouseButton1Click:Connect(showMenu)
U.InputBegan:Connect(function(i,p)
if p then return end
if i.KeyCode==Enum.KeyCode.RightShift then
if menuVisible then hideMenu() else showMenu() end
end
end)
local rdrag=false
local rdS=nil
local rdP=nil
reopen.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
rdrag=true
rdS=i.Position
rdP=reopen.Position
end
end)
U.InputChanged:Connect(function(i)
if not rdrag then return end
if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
local d=i.Position-rdS
reopen.Position=UDim2.new(rdP.X.Scale,rdP.X.Offset+d.X,rdP.Y.Scale,rdP.Y.Offset+d.Y)
end
end)
U.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rdrag=false end
end)
getRoles()
upHL()
upGun()
task.spawn(function()
while gui.Parent do
pcall(function()
getRoles()
upHL()
upGun()
if autoKill and M==pl.Name then killAll() end
if autoGunTP then tpGun() end
checkChat()
end)
task.wait(0.25)
end
end)