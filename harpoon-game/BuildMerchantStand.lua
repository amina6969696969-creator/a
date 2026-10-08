--[[
	Merchant Stand builder (harpoon game)

	How to use in Roblox Studio:
	  1. Point your camera at the spot where the stand should go.
	     It is placed on the ground under the camera's focus point,
	     with the counter facing the camera.
	  2. Open View > Command Bar, paste this whole file, press Enter.
	  3. A model named "MerchantStand" appears in Workspace and is selected.
	     Ctrl+Z removes it again.

	Style: STUD_STYLE = true (default) gives the classic stud look:
	plastic parts with studs on top and inlets underneath.

	What you get (all parts anchored, ~20 x 14 studs, ~14 studs tall):
	  - Plank platform, counter, posts, back wall with two shelves
	  - Red/cream striped awning with a scalloped edge and gold tassels
	  - Two hanging lanterns with warm lights
	  - Sign board on top (text = SHOP_TITLE)
	  - Treasure props on the shelves and counter, barrels and crates
	  - "WantedBoard" model next to the stall with a SurfaceGui:
	      WantedGui.Posters.Poster1..3 each have Icon (ImageLabel),
	      ItemName and Multiplier (TextLabels), plus WantedGui.NewIn.
	    Fill these from your WANTED code.
	  - Counter.Countertop.SellPoint.SellPrompt (ProximityPrompt).
	    Hook it up on the server, or delete it if your merchant NPC
	    already handles selling.
	  - Structure.MerchantNPCSpot (Attachment): where your merchant
	    NPC should stand behind the counter.
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local SHOP_TITLE = "MERCHANT"

-- true = classic Roblox look: plastic with studs on top and inlets underneath.
-- false = wood/fabric/metal materials with smooth surfaces.
local STUD_STYLE = true

-- Palette
local WOOD = Color3.fromRGB(164, 112, 66)
local WOOD_LIGHT = Color3.fromRGB(184, 132, 84)
local WOOD_DARK = Color3.fromRGB(107, 68, 35)
local RED = Color3.fromRGB(232, 67, 42)
local CREAM = Color3.fromRGB(243, 227, 195)
local GOLD = Color3.fromRGB(255, 201, 60)
local NAVY = Color3.fromRGB(14, 42, 63)
local IRON = Color3.fromRGB(70, 74, 80)

local recording = nil
pcall(function()
	recording = ChangeHistoryService:TryBeginRecording("Build MerchantStand")
end)

local model = Instance.new("Model")
model.Name = "MerchantStand"

local function folder(name, parent)
	local f = Instance.new("Model")
	f.Name = name
	f.Parent = parent or model
	return f
end

local structure = folder("Structure")
local counterModel = folder("Counter")
local awning = folder("Awning")
local lights = folder("Lanterns")
local props = folder("Props")
local signModel = folder("Sign")

-- Creates an anchored part. cf is relative to the stand's ground centre
-- (front of the stall faces -Z). Small decorative parts pass deco = true.
local function part(name, size, cf, color, material, parent, deco, className)
	local p = Instance.new(className or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if STUD_STYLE and p.Material ~= Enum.Material.Neon and p.Material ~= Enum.Material.Glass then
		-- Classic look: studs only show on Plastic, so every other material becomes Plastic.
		p.Material = Enum.Material.Plastic
		p.TopSurface = Enum.SurfaceType.Studs
		p.BottomSurface = Enum.SurfaceType.Inlet
	end
	if deco then
		p.CanCollide = false
		p.CanTouch = false
		p.CastShadow = false
	end
	p.Parent = parent
	return p
end

-- Upright cylinder (Roblox cylinders run along X, so tip it 90 degrees).
local function cylinder(name, height, diameter, pos, color, material, parent, deco)
	local p = part(name, Vector3.new(height, diameter, diameter),
		CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)), color, material, parent, deco)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function ball(name, diameter, pos, color, material, parent)
	local p = part(name, Vector3.new(diameter, diameter, diameter), CFrame.new(pos), color, material, parent, true)
	p.Shape = Enum.PartType.Ball
	return p
end

-------------------------------------------------------------------------
-- Platform (top surface at y = 0.5)
-------------------------------------------------------------------------
local base = part("Base", Vector3.new(20, 0.5, 14), CFrame.new(0, 0.25, 0), WOOD, Enum.Material.Wood, structure, true)
base.Transparency = 1
base.CanQuery = false
base.PivotOffset = CFrame.new(0, -0.25, 0) -- pivot sits on the ground

for i = 0, 9 do
	local x = -9 + i * 2
	part("Plank", Vector3.new(1.9, 0.5, 14), CFrame.new(x, 0.25, 0),
		if i % 2 == 0 then WOOD else WOOD_LIGHT, Enum.Material.Wood, structure)
end
part("FrontEdge", Vector3.new(20.2, 0.6, 0.6), CFrame.new(0, 0.3, -7), WOOD_DARK, Enum.Material.Wood, structure)
part("BackEdge", Vector3.new(20.2, 0.6, 0.6), CFrame.new(0, 0.3, 7), WOOD_DARK, Enum.Material.Wood, structure)

-------------------------------------------------------------------------
-- Posts, back wall, shelves, side rails
-------------------------------------------------------------------------
for _, x in { -7.5, 7.5 } do
	part("FrontPost", Vector3.new(1, 9.5, 1), CFrame.new(x, 5.25, -4), WOOD_DARK, Enum.Material.Wood, structure)
	part("BackPost", Vector3.new(1, 11, 1), CFrame.new(x, 6, 4.5), WOOD_DARK, Enum.Material.Wood, structure)
	part("SideRail", Vector3.new(0.4, 0.4, 8.5), CFrame.new(x, 3.5, 0.25), WOOD_DARK, Enum.Material.Wood, structure)
	part("SideRailLow", Vector3.new(0.4, 0.4, 8.5), CFrame.new(x, 1.8, 0.25), WOOD_DARK, Enum.Material.Wood, structure)
end
part("FrontBeam", Vector3.new(16, 0.6, 0.6), CFrame.new(0, 9.7, -4), WOOD_DARK, Enum.Material.Wood, structure)
part("BackWall", Vector3.new(14, 10, 0.5), CFrame.new(0, 5.5, 4.75), WOOD, Enum.Material.WoodPlanks, structure)
part("ShelfLow", Vector3.new(13, 0.35, 1.6), CFrame.new(0, 4.0, 3.7), WOOD_DARK, Enum.Material.Wood, structure)
part("ShelfHigh", Vector3.new(13, 0.35, 1.6), CFrame.new(0, 7.0, 3.7), WOOD_DARK, Enum.Material.Wood, structure)

local npcSpot = Instance.new("Attachment")
npcSpot.Name = "MerchantNPCSpot"
npcSpot.Position = Vector3.new(0, 0.25, 1.2) -- relative to Base centre: on the floor behind the counter
npcSpot.Parent = base

-------------------------------------------------------------------------
-- Counter (top surface at y = 4.4)
-------------------------------------------------------------------------
part("CounterBody", Vector3.new(14, 3.5, 2), CFrame.new(0, 2.25, -3.5), WOOD, Enum.Material.WoodPlanks, counterModel)
local countertop = part("Countertop", Vector3.new(15.2, 0.4, 2.8), CFrame.new(0, 4.2, -3.6), WOOD_DARK, Enum.Material.Wood, counterModel)
part("GoldTrim", Vector3.new(14, 0.35, 0.15), CFrame.new(0, 3.3, -4.55), GOLD, Enum.Material.Metal, counterModel, true)
part("NavyKick", Vector3.new(14, 0.5, 0.15), CFrame.new(0, 0.75, -4.55), NAVY, Enum.Material.SmoothPlastic, counterModel, true)

local sellPoint = Instance.new("Attachment")
sellPoint.Name = "SellPoint"
sellPoint.Position = Vector3.new(0, 0.6, -0.6)
sellPoint.Parent = countertop

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "SellPrompt"
prompt.ActionText = "Sell"
prompt.ObjectText = SHOP_TITLE
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 10
prompt.RequiresLineOfSight = false
prompt.Parent = sellPoint

-------------------------------------------------------------------------
-- Awning: slopes from the back (y 11.8) down to the front (y 9.6)
-------------------------------------------------------------------------
local backZ, backY, frontZ, frontY = 5.2, 11.8, -6.2, 9.6
local dz, dy = backZ - frontZ, backY - frontY
local awningLength = math.sqrt(dz * dz + dy * dy)
local tilt = math.atan2(dy, dz)
local awningCenter = Vector3.new(0, (backY + frontY) / 2, (backZ + frontZ) / 2)

for i = 0, 7 do
	local x = -7 + i * 2
	part("Stripe", Vector3.new(2, 0.25, awningLength),
		CFrame.new(x, awningCenter.Y, awningCenter.Z) * CFrame.Angles(-tilt, 0, 0),
		if i % 2 == 0 then RED else CREAM, Enum.Material.Fabric, awning)
	-- Scalloped edge hangs under the front of each stripe, opposite colour
	part("Valance", Vector3.new(2, 0.9, 0.2), CFrame.new(x, frontY - 0.45, frontZ - 0.05),
		if i % 2 == 0 then CREAM else RED, Enum.Material.Fabric, awning, true)
	ball("Tassel", 0.5, Vector3.new(x, frontY - 1.05, frontZ - 0.05), GOLD, Enum.Material.Metal, awning)
end
part("Ridge", Vector3.new(17, 0.5, 0.5), CFrame.new(0, backY + 0.15, backZ), WOOD_DARK, Enum.Material.Wood, awning)

-------------------------------------------------------------------------
-- Lanterns hanging from the front corners
-------------------------------------------------------------------------
local function awningY(z)
	return frontY + (z - frontZ) * (dy / dz)
end

for _, x in { -6.5, 6.5 } do
	local z = -5
	local top = awningY(z) - 0.1
	local lantern = folder("Lantern", lights)
	part("Chain", Vector3.new(0.15, 1.2, 0.15), CFrame.new(x, top - 0.6, z), IRON, Enum.Material.Metal, lantern, true)
	part("Cap", Vector3.new(0.9, 0.25, 0.9), CFrame.new(x, top - 1.3, z), IRON, Enum.Material.Metal, lantern, true)
	local glow = part("Glow", Vector3.new(0.65, 1, 0.65), CFrame.new(x, top - 1.95, z), Color3.fromRGB(255, 200, 110), Enum.Material.Neon, lantern, true)
	part("Bottom", Vector3.new(0.9, 0.2, 0.9), CFrame.new(x, top - 2.55, z), IRON, Enum.Material.Metal, lantern, true)
	local light = Instance.new("PointLight")
	light.Range = 14
	light.Brightness = 1.4
	light.Color = Color3.fromRGB(255, 190, 120)
	light.Shadows = false
	light.Parent = glow
end

-------------------------------------------------------------------------
-- Sign above the awning
-------------------------------------------------------------------------
for _, x in { -3.5, 3.5 } do
	part("SignPole", Vector3.new(0.4, 1.6, 0.4), CFrame.new(x, backY + 0.9, backZ - 0.4), WOOD_DARK, Enum.Material.Wood, signModel)
end
local signBoard = part("SignBoard", Vector3.new(10, 2.4, 0.35), CFrame.new(0, backY + 2.6, backZ - 0.4), WOOD_DARK, Enum.Material.Wood, signModel)

local signGui = Instance.new("SurfaceGui")
signGui.Name = "SignGui"
signGui.Face = Enum.NormalId.Front
signGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
signGui.PixelsPerStud = 50
signGui.LightInfluence = 0
signGui.Parent = signBoard

local signLabel = Instance.new("TextLabel")
signLabel.Name = "Title"
signLabel.BackgroundTransparency = 1
signLabel.Size = UDim2.fromScale(0.9, 0.8)
signLabel.Position = UDim2.fromScale(0.05, 0.1)
signLabel.Font = Enum.Font.FredokaOne
signLabel.Text = SHOP_TITLE
signLabel.TextScaled = true
signLabel.TextColor3 = GOLD
signLabel.Parent = signGui
local signStroke = Instance.new("UIStroke")
signStroke.Thickness = 4
signStroke.Color = Color3.fromRGB(6, 21, 33)
signStroke.Parent = signLabel

-------------------------------------------------------------------------
-- Treasure props
-------------------------------------------------------------------------
local function chest(pos)
	local m = folder("Chest", props)
	part("Body", Vector3.new(1.6, 0.9, 1), CFrame.new(pos + Vector3.new(0, 0.45, 0)), WOOD_DARK, Enum.Material.Wood, m, true)
	part("Lid", Vector3.new(1.6, 0.4, 1), CFrame.new(pos + Vector3.new(0, 1.1, 0)), WOOD, Enum.Material.Wood, m, true)
	part("Band", Vector3.new(1.65, 0.15, 1.05), CFrame.new(pos + Vector3.new(0, 0.9, 0)), GOLD, Enum.Material.Metal, m, true)
	part("Lock", Vector3.new(0.3, 0.35, 0.1), CFrame.new(pos + Vector3.new(0, 0.75, -0.55)), GOLD, Enum.Material.Metal, m, true)
end

local function bottle(pos, color)
	local m = folder("Bottle", props)
	local glass = cylinder("Glass", 1, 0.5, pos + Vector3.new(0, 0.5, 0), color, Enum.Material.Glass, m, true)
	glass.Transparency = 0.25
	cylinder("Neck", 0.4, 0.22, pos + Vector3.new(0, 1.2, 0), color, Enum.Material.Glass, m, true).Transparency = 0.25
	cylinder("Cork", 0.2, 0.24, pos + Vector3.new(0, 1.5, 0), WOOD_LIGHT, Enum.Material.Wood, m, true)
end

local function chalice(pos)
	local m = folder("Chalice", props)
	cylinder("Foot", 0.12, 0.7, pos + Vector3.new(0, 0.06, 0), GOLD, Enum.Material.Metal, m, true)
	cylinder("Stem", 0.6, 0.18, pos + Vector3.new(0, 0.4, 0), GOLD, Enum.Material.Metal, m, true)
	cylinder("Cup", 0.6, 0.8, pos + Vector3.new(0, 1.0, 0), GOLD, Enum.Material.Metal, m, true)
end

local function coinStack(pos, layers)
	local m = folder("Coins", props)
	for i = 1, layers do
		cylinder("Coin", 0.15, 0.7, pos + Vector3.new((i % 2) * 0.05, 0.075 + (i - 1) * 0.15, 0), GOLD, Enum.Material.Metal, m, true)
	end
end

-- Low shelf (top at y 4.175)
local lowY = 4.175
chest(Vector3.new(-5, lowY, 3.7))
bottle(Vector3.new(-2.6, lowY, 3.7), Color3.fromRGB(95, 214, 200))
bottle(Vector3.new(-1.8, lowY, 3.7), Color3.fromRGB(69, 178, 255))
coinStack(Vector3.new(0.4, lowY, 3.7), 5)
coinStack(Vector3.new(1.2, lowY, 3.5), 3)
chest(Vector3.new(4.4, lowY, 3.7))

-- High shelf (top at y 7.175)
local highY = 7.175
chalice(Vector3.new(-4.5, highY, 3.7))
ball("Pearl", 0.6, Vector3.new(-2.2, highY + 0.3, 3.7), Color3.fromRGB(245, 240, 255), Enum.Material.SmoothPlastic, props)
ball("Pearl", 0.45, Vector3.new(-1.5, highY + 0.225, 3.8), Color3.fromRGB(255, 225, 240), Enum.Material.SmoothPlastic, props)
chalice(Vector3.new(0.8, highY, 3.7))
bottle(Vector3.new(3, highY, 3.7), Color3.fromRGB(193, 123, 255))
coinStack(Vector3.new(4.8, highY, 3.7), 7)

-- Counter (top at y 4.4)
local counterY = 4.4
coinStack(Vector3.new(-5, counterY, -3.6), 6)
coinStack(Vector3.new(-4.3, counterY, -3.4), 3)
do -- balance scale
	local m = folder("Scale", props)
	local x = 4.5
	part("Post", Vector3.new(0.2, 1.6, 0.2), CFrame.new(x, counterY + 0.8, -3.5), GOLD, Enum.Material.Metal, m, true)
	part("Beam", Vector3.new(2.2, 0.15, 0.15), CFrame.new(x, counterY + 1.6, -3.5), GOLD, Enum.Material.Metal, m, true)
	cylinder("PanL", 0.1, 0.9, Vector3.new(x - 1, counterY + 0.9, -3.5), GOLD, Enum.Material.Metal, m, true)
	cylinder("PanR", 0.1, 0.9, Vector3.new(x + 1, counterY + 0.9, -3.5), GOLD, Enum.Material.Metal, m, true)
	part("StringL", Vector3.new(0.05, 0.7, 0.05), CFrame.new(x - 1, counterY + 1.25, -3.5), IRON, Enum.Material.Metal, m, true)
	part("StringR", Vector3.new(0.05, 0.7, 0.05), CFrame.new(x + 1, counterY + 1.25, -3.5), IRON, Enum.Material.Metal, m, true)
end

-- Barrels (back left) and crates (back right)
local function barrel(pos)
	local m = folder("Barrel", props)
	local body = cylinder("Body", 3, 2.4, pos + Vector3.new(0, 1.5, 0), WOOD, Enum.Material.Wood, m)
	body.CastShadow = true
	cylinder("BandTop", 0.25, 2.5, pos + Vector3.new(0, 2.4, 0), IRON, Enum.Material.Metal, m, true)
	cylinder("BandBottom", 0.25, 2.5, pos + Vector3.new(0, 0.6, 0), IRON, Enum.Material.Metal, m, true)
end
barrel(Vector3.new(-8.8, 0.5, 2.2))
barrel(Vector3.new(-8.8, 0.5, 5.2))

part("Crate", Vector3.new(2.2, 2.2, 2.2), CFrame.new(8.8, 1.6, 4.8), WOOD_LIGHT, Enum.Material.WoodPlanks, props)
part("CrateSmall", Vector3.new(1.5, 1.5, 1.5), CFrame.new(8.8, 3.45, 4.8) * CFrame.Angles(0, math.rad(20), 0), WOOD, Enum.Material.WoodPlanks, props)
part("Crate", Vector3.new(2, 2, 2), CFrame.new(8.8, 1.5, 2.2), WOOD, Enum.Material.WoodPlanks, props)

-------------------------------------------------------------------------
-- WANTED board (left of the stall, facing the front)
-------------------------------------------------------------------------
local wanted = folder("WantedBoard")
local boardX, boardZ = -12.5, -4.5
for _, dx in { -2.75, 2.75 } do
	part("Leg", Vector3.new(0.5, 8, 0.5), CFrame.new(boardX + dx, 4, boardZ + 0.3), WOOD_DARK, Enum.Material.Wood, wanted)
end
local board = part("Board", Vector3.new(6, 5, 0.3), CFrame.new(boardX, 5.2, boardZ), WOOD_DARK, Enum.Material.Wood, wanted)
part("Roof", Vector3.new(6.8, 0.3, 1.4), CFrame.new(boardX, 8.1, boardZ + 0.2), RED, Enum.Material.Fabric, wanted)

local wantedGui = Instance.new("SurfaceGui")
wantedGui.Name = "WantedGui"
wantedGui.Face = Enum.NormalId.Front
wantedGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
wantedGui.PixelsPerStud = 60 -- 360 x 300 pixels
wantedGui.LightInfluence = 0
wantedGui.Parent = board

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(1, 0.2)
title.Position = UDim2.fromScale(0, 0.02)
title.Font = Enum.Font.FredokaOne
title.Text = "WANTED"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 231, 163)
title.Parent = wantedGui

local posters = Instance.new("Frame")
posters.Name = "Posters"
posters.BackgroundTransparency = 1
posters.Size = UDim2.fromScale(0.94, 0.62)
posters.Position = UDim2.fromScale(0.03, 0.24)
posters.Parent = wantedGui

local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Padding = UDim.new(0.03, 0)
list.SortOrder = Enum.SortOrder.Name
list.Parent = posters

for i = 1, 3 do
	local poster = Instance.new("Frame")
	poster.Name = "Poster" .. i
	poster.Size = UDim2.fromScale(0.3, 1)
	poster.BackgroundColor3 = CREAM
	poster.Rotation = ({ -3, 2, -1.5 })[i]
	poster.Parent = posters
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.06, 0)
	corner.Parent = poster

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundColor3 = NAVY
	icon.Size = UDim2.fromScale(0.8, 0.45)
	icon.Position = UDim2.fromScale(0.1, 0.06)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = ""
	icon.Parent = poster
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0.12, 0)
	iconCorner.Parent = icon

	local itemName = Instance.new("TextLabel")
	itemName.Name = "ItemName"
	itemName.BackgroundTransparency = 1
	itemName.Size = UDim2.fromScale(0.9, 0.2)
	itemName.Position = UDim2.fromScale(0.05, 0.53)
	itemName.Font = Enum.Font.FredokaOne
	itemName.Text = "???"
	itemName.TextScaled = true
	itemName.TextColor3 = Color3.fromRGB(62, 38, 20)
	itemName.Parent = poster

	local mult = Instance.new("TextLabel")
	mult.Name = "Multiplier"
	mult.BackgroundTransparency = 1
	mult.Size = UDim2.fromScale(0.9, 0.24)
	mult.Position = UDim2.fromScale(0.05, 0.74)
	mult.Font = Enum.Font.FredokaOne
	mult.Text = "×3"
	mult.TextScaled = true
	mult.TextColor3 = Color3.fromRGB(181, 48, 27)
	mult.Parent = poster
end

local newIn = Instance.new("TextLabel")
newIn.Name = "NewIn"
newIn.BackgroundTransparency = 1
newIn.Size = UDim2.fromScale(1, 0.1)
newIn.Position = UDim2.fromScale(0, 0.88)
newIn.Font = Enum.Font.GothamBold
newIn.Text = "New list at 02:00"
newIn.TextScaled = true
newIn.TextColor3 = CREAM
newIn.Parent = wantedGui

-------------------------------------------------------------------------
-- Place it on the ground under the camera focus, facing the camera
-------------------------------------------------------------------------
model.PrimaryPart = base

local camera = workspace.CurrentCamera
local focus = camera.Focus.Position
local hit = workspace:Raycast(focus + Vector3.new(0, 50, 0), Vector3.new(0, -500, 0))
local groundPos = if hit then hit.Position else Vector3.new(focus.X, 0, focus.Z)
local camPos = camera.CFrame.Position
local lookTarget = Vector3.new(camPos.X, groundPos.Y, camPos.Z)
-- The stall's front faces -Z, which is the CFrame's LookVector, so look at the camera.
local target = if (lookTarget - groundPos).Magnitude > 0.1
	then CFrame.lookAt(groundPos, lookTarget)
	else CFrame.new(groundPos)

model:PivotTo(target)
model.Parent = workspace
Selection:Set({ model })

if recording then
	ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

print(("MerchantStand built with %d parts."):format(#model:GetDescendants()))
