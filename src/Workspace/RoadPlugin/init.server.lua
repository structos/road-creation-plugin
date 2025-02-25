local CoreGui = game:GetService("CoreGui")
local CHS = game:GetService("ChangeHistoryService")

local Parts = require(script.RoadNetwork.Lane.Parts)
local RoadTypes = require(script.RoadNetwork.RoadTypes)

require(script.migrate)()
-- hi

local r, RoadFolder

-- update 0.3 decals
require(script.newdecals)()

-- one-time discord invite

local INVITED_KEY = "invitedToDiscordWave2"
if not plugin:GetSetting(INVITED_KEY) then
	local inviteGui = script.Discord:Clone()
	inviteGui.Parent = CoreGui

	inviteGui.Frame.close.MouseButton1Click:Connect(function()
		inviteGui:Destroy()
		plugin:SetSetting(INVITED_KEY, true)
	end)
end



--/--

local ImageButtonWithText = require(script.StudioWidgets.ImageButtonWithText)

local toolbar = plugin:CreateToolbar("Roads")

local Updates = require(script.LaneUpdates)
local firstRender = true

-- watch all existing nodes

for _, n in ipairs(workspace:GetDescendants()) do
	if n:IsA("ObjectValue") and n.Name == "Next" and n.Value then
		Updates.watch(n)
		print(n)
	end
end


-- widget

local WidgetBtn = toolbar:CreateButton("Road Editor", "Opens road editor plugin.", "rbxassetid://4867783285")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, --This can be changed--
	false,
	false,
	240,
	760,
	240,
	360
)
local widget = plugin:CreateDockWidgetPluginGui("Beautiful Roads", widgetInfo)
widget.Title = "Beautiful Roads"

WidgetBtn.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	WidgetBtn:SetActive(widget.Enabled)

	makeRoadFolder()
end)

WidgetBtn:SetActive(widget.Enabled)

local Main = script.Main
Main.Parent = widget
-- Main.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)

local function resize()
	Main.CanvasSize = UDim2.new(0, 0, 0, 855)
end

resize()
-- buttons

local function mkbutton(order, txt, tooltip, img)
	local button = ImageButtonWithText.new(
		"btn",
		order,
		img,
		txt,
		UDim2.new(0, 48, 0, 64),
		UDim2.new(0, 32, 0, 32),
		UDim2.new(0, 8, 0, 0),
		UDim2.new(0, 48, 0, 32),
		UDim2.new(0, 0, 0, 32)
	)
	
	return button, button:getButton()
end

local SKB, StarterKitBtn = mkbutton(1, "Create Node", "Creates nodes for a two lane road.", "rbxassetid://4850309662")
local NCB, NCBtn = mkbutton(2, "New Lane", "Create new connections between nodes.", "rbxassetid://4917028029")

local PL, PrintLinesBtn = mkbutton(3, "Edit Lines", "Change how lines are rendered.", "rbxassetid://4850309383")
RoTy, RoTyBtn = mkbutton(4, "Edit Road Textures", "Edit road types based on presets.", "rbxassetid://4917009000")

local DLB, DLBtn = mkbutton(5, "Delete Lanes", "Select a lane's red line delete it.", "rbxassetid://4883812654")


local RB, RBtn = mkbutton(6, "Render Changed", "Renders roads.", "rbxassetid://4850309183")
local RAB, RABtn = mkbutton(7, "Render All", "Renders all roads.", "rbxassetid://4850309183")
local RO, RenderOptionsBtn = mkbutton(8, "Render Options", "Render options.", "rbxassetid://4871687134")

-- local MT, MTBTN = mkbutton(9, "material picker test", "Render options.", "rbxassetid://4871687134")

StarterKitBtn.Parent = Main.Buttons
DLBtn.Parent = Main.Buttons
NCBtn.Parent = Main.Buttons
RBtn.Parent = Main.Buttons
RABtn.Parent = Main.Buttons
RenderOptionsBtn.Parent = Main.Buttons
PrintLinesBtn.Parent = Main.Buttons
RoTyBtn.Parent = Main.Buttons

-- util

local function selectTool()
	-- active roblox select tool
	if plugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.Select then
		plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new(0, 100, 0, 100))
	end
end

-- MTBTN.Parent = Main.Buttons
-- local uip = game:GetService("UserInputService")
-- MTBTN.MouseButton1Click:Connect(function()
-- 	local pos = uip:GetMouseLocation()
-- 	pos = UDim2.new(0, pos.x, 0, pos.y)

-- 	plugin:SelectRibbonTool(Enum.RibbonTool.MaterialPicker, pos)
-- end)

-- Delete Lanes --

local LE = require(script.LaneEditor).new(plugin:GetMouse(), Main)

DLBtn.MouseButton1Click:Connect(function()
	LE.Enabled = not LE.Enabled
	DLB:setSelected(LE.Enabled)
	
	if LE.Enabled then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p.Name == "Next" and p.Parent.Name == "Node" then
				LE:ShowLane(p)
			end
		end

		selectTool()
	else
		LE:HideLanes()
	end
end)

game.Selection.SelectionChanged:Connect(function()
	local sel = game.Selection:Get()
	if #sel == 1 and sel[1].Name == "__LaneDisplayLine__" then
		sel[1]:Destroy()
	end
end)

---------

NCBtn.MouseButton1Click:Connect(function()
	LE.MouseEnabled = not LE.MouseEnabled
	plugin:Activate(LE.MouseEnabled)
	NCB:setSelected(LE.MouseEnabled)
	
	LE:UME()
end)

SS = game:GetService("ServerScriptService")

StarterKitBtn.MouseButton1Click:Connect(function()
	local node = script.Lane:Clone()
	node.Parent = workspace
	node:SetPrimaryPartCFrame(CFrame.new(workspace.Camera.CFrame.p + workspace.Camera.CFrame.LookVector*10))
	
	game.Selection:Set({node})
	
	if not SS:FindFirstChild("RemoveNodes") then
		local s = script.RemoveNodes:Clone()
		s.Parent = SS
		s.Disabled = false	
	end
end)

-- road line editor

local custom_presets = {}
custom_presets.__index = custom_presets
function custom_presets:Get(nlanes)
	return plugin:GetSetting("presets" .. tostring(nlanes)) or {}
end

function custom_presets:Save(nlanes, name, left, right)
	local preset = {
		Name = name,
		L = left
	}
	if right then
		preset.R = right
	end
	
	local cur = custom_presets:Get(nlanes)
	for i, v in ipairs(cur) do
		if v.Name == name then
			table.remove(cur, i)
			break
		end
	end
	
	table.insert(cur, preset)
	
	plugin:SetSetting("presets" .. tostring(nlanes), cur)
end

local RPLN = "__RoadPluginLine"

local line_editor_active = false

local lines = {}
local render_lines = {}

local LineEditor = require(script.LineEditor)
PrintLinesBtn.MouseButton1Click:Connect(function()
	line_editor_active = not line_editor_active
	PL:setSelected(line_editor_active)

	if not r then
		makeRoadFolder()
	end
	
	if line_editor_active then
		r.lanes = {}
		r:FindLanes()
		
		lines = r:FindFullLines()
		
		render_lines = {}
		for k, v in pairs(lines) do
			local disp = Parts.CurvedRail(v.curve, 5, 1, { Color = Color3.new(1, 1, 1), Transparency=.7 })
			disp.Parent = workspace
			disp.Name = RPLN
			
			local ref = Instance.new("StringValue", disp)
			ref.Name = "ref"
			ref.Value = k
			
			table.insert(render_lines, disp)
		end

		selectTool()
		
	else
		for _, disp in ipairs(render_lines) do
			disp:Destroy()
		end
		
		render_lines = {}
	end
end)

local c_editor
game.Selection.SelectionChanged:Connect(function()
	local sel = game.Selection:Get()
	
	if c_editor then
		c_editor:Close()
		c_editor = nil
	end
	
	--print(#sel == 1, sel[1].Name, sel[1].Name == RPLN)
	if not (#sel == 1 and sel[1].Name == RPLN) then return end
	
	local line = lines[sel[1].ref.Value]
	
	
	c_editor = LineEditor.new(line, Main, custom_presets) 
end)

-- road types --

-- saving
local road_types = {}
road_types.__index = road_types
function road_types:Get()
	local custom = road_types:Custom()

	local rtypes = custom
	for k, v in pairs(RoadTypes.All) do
		rtypes[k] = v
	end

	return rtypes
end

function road_types:Custom()
	local vals = plugin:GetSetting("customRoadTypes") or {}
	for k, _ in pairs(vals) do
		vals[k] = RoadTypes.Load(vals[k])
	end

	return vals
end

local repr = require(script.repr)

function road_types:Save(name, val)
	local custom = plugin:GetSetting("customRoadTypes") or {}

	custom[name] = RoadTypes.Saveable(val)
	--print(repr(custom, {pretty=true}))
	plugin:SetSetting("customRoadTypes", custom)
end

local RTDN = "__RoadPluginTypeEditDisp"

local rt_disp = {}
local road_editor_active = false

RoTyBtn.MouseButton1Click:Connect(function()
	if not r then
		makeRoadFolder()
	end

	road_editor_active = not road_editor_active
	RoTy:setSelected(road_editor_active)

	r.lanes = {}
	r.lanegroups = {}

	r:FindLanes()
	r:MakeGroups()

	if road_editor_active then
		local props = {Color = Color3.new(.2, 1, .2), Transparency = .8}
		for _, group in ipairs(r.lanegroups) do
			local sa = 2.5 / group[1]:length()

			local disp = Parts.CurvedPath(group.curve, 5, group.width-5, 1, props, sa, 1-sa)
			disp.Name = RTDN
			disp.Parent = workspace

			local ref = Instance.new("StringValue", disp)
			ref.Name = "ref"
			ref.Value = group.id

			local val = {}
			val.group = group
			val.disp = disp

			rt_disp[group.id] = val
		end

		selectTool()
		
	else
		for _, v in pairs(rt_disp) do
			v.disp:Destroy()
		end


		rt_disp = {}

		if Main:FindFirstChild("RoadEditor") then
			Main.RoadEditor:Destroy()
		end
	end
end)


local RTypePicker = require(script.RTypePicker)

local c_picker
game.Selection.SelectionChanged:Connect(function()
	local sel = game.Selection:Get()
	
	if c_picker then
		c_picker:close()
		c_picker = nil
	end
	

	if not (#sel == 1 and sel[1].Name == RTDN) then return end
	
	local group = rt_disp[sel[1].ref.Value].group
	
	
	c_picker = RTypePicker.new(group, Main, road_types) 
end)


---------------------

-- render config persistence 


local rendercfg = {
	SegmentLength = 10, MaxSegments=math.huge, BGRes = 1,
	RoadThickness = 0.3, LineWidth = 0.4
}
rendercfg.__index = rendercfg
function rendercfg:Get()
	for k, v in pairs((plugin:GetSetting(tostring(game.PlaceId)) or {})) do
		self[k] = v
	end

	self.MaxSegments = math.huge
	
	return self
end

local function updateTemplates()
	for _, p in ipairs(script.Lane:GetChildren()) do
		p.Size = Vector3.new(p.Size.x, rendercfg.RoadThickness, p.Size.z)
	end
end

function rendercfg:Save()
	local new = {}
	new.SegmentLength = self.SegmentLength
	new.RoadThickness = self.RoadThickness
	new.LineWidth = self.LineWidth
	new.BGRes = self.BGRes

	updateTemplates()
	
	plugin:SetSetting(tostring(game.PlaceId), new)
	
	firstRender = true
end


-- render config menu

local LabeledSlider = require(script.StudioWidgets.LabeledSlider)

local ROpts = Main.RenderOpts; ROpts.Visible = false
RenderOptionsBtn.MouseButton1Click:Connect(function()
	ROpts.Visible = not ROpts.Visible
	RO:setSelected(ROpts.Visible)
end)

rendercfg:Get()
updateTemplates()
ROpts.SegLen.input.Text = tostring(rendercfg.SegmentLength)
ROpts.Thickness.input.Text = tostring(rendercfg.RoadThickness)
ROpts.LineWidth.input.Text = tostring(rendercfg.LineWidth)

-- local slider = LabeledSlider.new(
-- 	"bgres",
-- 	"Asphalt Resolution",
-- 	100,
-- 	math.floor(rendercfg.BGRes*100)
-- )
-- local sf = slider:GetFrame()
-- sf.Parent = ROpts
-- sf.Size = UDim2.new(1, 0, 0, 30)
-- sf.LayoutOrder = 2
-- sf.Label.TextSize = 15
-- sf.Label.Size = UDim2.new(0.5, -4, 1, 0)
-- sf.Label.Position = UDim2.new(0, 0, 0.5, 0)
-- sf.Label.TextXAlignment = Enum.TextXAlignment.Center

-- sf.SliderGui.Size = UDim2.new(0.5, 0, 1, 0)
-- sf.SliderGui.Position = UDim2.new(0.5, 0, 0.5, 0)

-- slider:GetFrame():Clone().Parent = game.StarterGui

-- slider:SetValueChangedFunction(function(nv)
-- 	rendercfg.BGRes = nv/100
-- 	rendercfg:Save()
-- end)

ROpts.SegLen.input.FocusLost:Connect(function(enter)
	if enter then
		local nv = tonumber(ROpts.SegLen.input.Text)
		
		if not nv then
			ROpts.SegLen.input.Text = tostring(rendercfg.SegmentLength) return
		end
		
		rendercfg.SegmentLength = math.min(20, nv)
		ROpts.SegLen.input.Text = tostring(rendercfg.SegmentLength)
		rendercfg:Save()
	else
		ROpts.SegLen.input.Text = tostring(rendercfg.SegmentLength) return
	end
end)
ROpts.Thickness.input.FocusLost:Connect(function(enter)
	if enter then
		local nv = tonumber(ROpts.Thickness.input.Text)
		
		if not nv then
			ROpts.Thickness.input.Text = tostring(rendercfg.RoadThickness) return
		end
		
		rendercfg.RoadThickness = nv
		rendercfg:Save()
	else
		ROpts.Thickness.input.Text = tostring(rendercfg.RoadThickness) return
	end
end)
ROpts.LineWidth.input.FocusLost:Connect(function(enter)
	if enter then
		local nv = tonumber(ROpts.LineWidth.input.Text)
		
		if not nv then
			ROpts.LineWidth.input.Text = tostring(rendercfg.LineWidth) return
		end
		
		rendercfg.LineWidth = nv
		rendercfg:Save()
	else
		ROpts.LineWidth.input.Text = tostring(rendercfg.LineWidth) return
	end
end)


-- Render --

function makeRoadFolder()
	RoadFolder = workspace:FindFirstChild("Roads") or Instance.new("Folder", workspace)
	RoadFolder.Name = "Roads"

	local RN = require(script.RoadNetwork)
	r = RN.new(RoadFolder, rendercfg)
end


Main.RenderProgress.Visible = false

local function render()
	makeRoadFolder()

	CHS:SetWaypoint("Render")
	
	if firstRender then
		RoadFolder:ClearAllChildren()
	end
	
	r.lanes = {}
	r.lanegroups = {}
	
	r:CleanGarbage()
	local ungrouped = r:FindLanes()
	print(#r.lanes, "lanes found.")
	r:MakeGroups()
	print(#r.lanegroups, "lane groups made.")

	if #ungrouped > 0 then
		warn("Ungrouped nodes found and not rendered.")
		game.Selection:Set(ungrouped)
	end
	
	r:FindFullLines()
	
	r:ClearOldGroups()
	-- before rendering, remove any garbage
	-- if group IDs changed, then they are guaranteed to be in the change list and be rerendered
	
	if not firstRender then
		r:FilterChanged()
		print(#r.lanegroups, "lane groups remaining.")
	end
	
	Main.RenderProgress.Visible = true
	
	rendercfg:Get()	
	r:RenderGroups(road_types, function(prog)
		Main.RenderProgress.bar.Size = UDim2.new(prog, 0, 1, 0)
		
		local perc = tostring(math.ceil(prog*100)) .. "%"
		Main.RenderProgress.TextLabel.Text = ("%s Rendered"):format(perc)
	end)
		
	Updates.clearChanged()
	
	firstRender = false

	CHS:SetWaypoint("Render")
	
	wait(0.5)
	Main.RenderProgress.Visible = false
end

RBtn.MouseButton1Click:Connect(render)
RABtn.MouseButton1Click:Connect(function()
	firstRender = true
	render()
end)

