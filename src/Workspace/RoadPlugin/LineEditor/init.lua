local RoadPatterns = require(script.Parent.RoadNetwork.Lane.RoadPatterns)
local Updates = require(script.Parent.LaneUpdates)

local Presets = require(script.Presets)

local PseudoInstance = require(script.PseudoInstance)
local Enumeration = require(script.Enumeration)
local Color = require(script.Color)

------

local function scopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

local function sortLanes(line)
	local function k(a, b)
		if a.lane[2].CFrame:ToObjectSpace(b.lane[2].CFrame).p.X > 0 then
			return true
		end
		
		return false
	end
	
	table.sort(line, k)
end

------

local DEFAULTS = {
	Yellow = ".5A;1Y",
	White = "(.5W)",
	Edge = "1.5A;1W"
}


local LE = {}
LE.__index = LE
function LE.new(line, parent, cpresets)
	local self = setmetatable({}, LE)
	
	self.gui = script.LineEditor:Clone()
	self.gui.Parent = parent
	self.gui.Visible = true
	
	self.cpresets = cpresets
	
	self.line = line
	if line.samedir then
		sortLanes(self.line)
	end
	
	self.custom = false
	self.vals = {}
	
	if #self.line == 1 then
		local k = ((self.line[1].side == 1) and "CustomRight") or "CustomLeft"
		self.custom = (self.line[1].lane.nxt:FindFirstChild(k) and true) or false
		
		local val = (self.custom and self.line[1].lane.nxt[k].Value) or nil
		if not val then
			val = (k == "CustomLeft" and DEFAULTS.Yellow) or DEFAULTS.Edge
		end
		
		table.insert(self.vals, val)
	else
		for _, lane in ipairs(self.line) do
			local k = ((lane.side == 1) and "CustomRight") or "CustomLeft"
			local thiscustom = (lane.lane.nxt:FindFirstChild(k) and true) or false
			
			local default = (line.samedir and DEFAULTS.White) or DEFAULTS.Yellow
			
			local val = (thiscustom and lane.lane.nxt[k].Value) or default
			table.insert(self.vals, val)
			
			if thiscustom then
				self.custom = true
			end
		end
	end
	
	self.ry = self.line[#self.line].lane.orient
	
	self:init()
	
	if #self.line > 1 then
		self:AutoRotate()
	else
		self.gui.input.labels["1"].Text = "Line"
		self.gui.input.inputs.inp2.Visible = false
		self.gui.input.labels["2"].Visible = false
	end
	
	return self
end

function LE:MakePresetBtns()
	local loadpreset = self.gui.LoadPreset
	local scroll = loadpreset.scroll
	local presets = scopy(Presets[#self.line])
	
	for _, btn in ipairs(scroll:GetChildren()) do
		if btn.Name ~= "Template" and btn.Name ~= "UIListLayout" then
			btn:Destroy()
		end
	end
	
	local custom = self.cpresets:Get(#self.line)
	for _, v in ipairs(custom) do
		local nv = v
		nv.L = " " .. nv.L
		if nv.R then
			nv.R = " " .. nv.R
		end
		table.insert(presets, nv)
	end
	
	for idx, v in pairs(presets) do
		local btn = scroll.Template:Clone()
		btn.Parent = scroll
		btn.Name = "btn"
		btn.Text = v.Name
		btn.Visible = true
		
		btn.MouseButton1Click:Connect(function()
			self.gui.input.inputs.inp1.Text = v.L
			if #self.line > 1 then
				self.gui.input.inputs.inp2.Text = v.R
			end
			
			self:UpdateVals()
			self:Update()
			
			loadpreset.Visible = false
			self.gui.PresetBtns.Visible = true
		end)
			
		btn.LayoutOrder = idx
	end
	
	scroll.CanvasSize = UDim2.new(1, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y)
end

function LE:init()
	local CL = PseudoInstance.new("Checkbox")
	CL.Parent = self.gui.CustomLines
	CL.Checked = self.custom
	CL.OnChecked:Connect(function()
		self.custom = CL.Checked
		self:Update()
	end)
	CL.Theme = Enumeration.MaterialTheme.Dark
	CL.PrimaryColor3 = Color.Yellow[600]
	self.CL = CL
	
	for i, val in ipairs(self.vals) do
		local k = "inp" .. tostring(i)
		local textbox = self.gui.input.inputs[k]
		
		textbox.Text = " " .. val
		textbox.FocusLost:Connect(function(enter)
			self.vals[i] = textbox.Text:gsub(" ", "")
			if not self.custom then
				self.custom = true
				self.CL.Checked = true
			end
			self:Update()
		end)
	end
	
	if #self.line > 1 then
		self.gui.input.swap.btn.MouseButton1Click:Connect(function()
			local old1 = self.gui.input.inputs.inp1.Text
			
			self.gui.input.inputs.inp1.Text = self.gui.input.inputs.inp2.Text 
			self.gui.input.inputs.inp2.Text = old1
			self:UpdateVals()			
			
			self:Update()
		end)
	else
		self.gui.input.swap.Visible = false
	end
	
	local loadpreset = self.gui.LoadPreset
	local scroll = loadpreset.scroll
	local savepreset = self.gui.SavePreset
	
	self:MakePresetBtns()
		
	loadpreset.cancel.MouseButton1Click:Connect(function()
		loadpreset.Visible = false
		self.gui.PresetBtns.Visible = true
	end)
	savepreset.cancel.MouseButton1Click:Connect(function()
		savepreset.Visible = false
		self.gui.PresetBtns.Visible = true
	end)
		
	self.gui.PresetBtns.load.MouseButton1Click:Connect(function()
		loadpreset.Visible = true
		self.gui.PresetBtns.Visible = false
	end)
	
	self.gui.PresetBtns.save.MouseButton1Click:Connect(function()
		savepreset.Visible = true
		self.gui.PresetBtns.Visible = false
	end)
		
	savepreset.submit.MouseButton1Click:Connect(function()
		if #savepreset.name.Text > 0 then
			local name = savepreset.name.Text
			
			if #self.line == 1 then
				self.cpresets:Save(1, name, self.vals[1])
			else
				self.cpresets:Save(2, name, self.vals[1], self.vals[2])
			end
			
			savepreset.Visible = false
			self.gui.PresetBtns.Visible = true
			
			self:MakePresetBtns()
			savepreset.name.Text = ""
		end
	end)
		
	loadpreset.Visible = false
	savepreset.Visible = false
	
	self.gui.Parent.Changed:Connect(function()
		self:UpdateSize()
	end)
	
	self:Update()
	self:UpdateSize()
end

function LE:UpdateSize()
	self.gui.Size = UDim2.new(1, 0, 1, -160)
end

function LE:UpdateVals()
	self.vals[1] = self.gui.input.inputs.inp1.Text:gsub(" ", "")
	
	if #self.line > 1 then
		self.vals[2] = self.gui.input.inputs.inp2.Text:gsub(" ", "")
	end
	
	if not self.custom then
		self.custom = true
		self.CL.Checked = true
	end
end

function LE:Update()
	if self.custom then
		for i, lane in ipairs(self.line) do
			local k = ((lane.side == 1) and "CustomRight") or "CustomLeft"
			local StringVal = lane.lane.nxt:FindFirstChild(k)
			if not StringVal then
				StringVal = Instance.new("StringValue", lane.lane.nxt)
				StringVal.Name = k
			end
			
			StringVal.Value = self.vals[i]
		end
	else
		for i, lane in ipairs(self.line) do
			local k = ((lane.side == 1) and "CustomRight") or "CustomLeft"
			local StringVal = lane.lane.nxt:FindFirstChild(k)
			if StringVal then
				StringVal:Destroy()
			end
		end
	end
	
	for _, l in ipairs(self.line) do
		Updates.tag(l.lane.nxt)
	end
	
	self:GeneratePreview()
end

function LE:Close()
	self.gui:Destroy()
	if self.conn then
		self.conn:Disconnect()
	end
end

function LE:Rotate()
	local _, ry, _ = workspace.CurrentCamera.CFrame:ToOrientation()
	

	self.gui.Preview.cont.Rotation = (math.deg(ry) - self.ry)
	--print(math.deg(ry) - self.ry)
	
	pcall(function()
		local l, r = 1, 2
		
		if self.gui.Preview.cont.Label2.AbsolutePosition.X < self.gui.Preview.cont.Label1.AbsolutePosition.X then
			l, r = 2, 1
		end
		
		-- update text labels
		self.gui.Preview.cont["Label"..tostring(l)].Text = "LEFT"
		self.gui.Preview.cont["Label"..tostring(r)].Text = "RIGHT"
		self.gui.input.inputs.inp1.LayoutOrder = l
		self.gui.input.inputs.inp2.LayoutOrder = r
	
	end)
end

function LE:AutoRotate()
	self.conn = workspace.CurrentCamera.Changed:Connect(function()
		self:Rotate()
	end)
		
	self:Rotate()
end

function LE:GeneratePreview()
	local templates = self.gui.temp
	local lw_px = 4  -- line width unit in pixels
	local Preview = self.gui.Preview.cont
	
	Preview:ClearAllChildren()
	if #self.line > 1 then
		templates.Label1:Clone().Parent = Preview
		templates.Label2:Clone().Parent = Preview
	end
	
	local road = templates.Road:Clone()
	road.Parent = Preview
	for i, val in ipairs(self.vals) do
		local mod = (i-1.5)*2
		
		local normal, dashed = RoadPatterns.Lines(val, true)
		
		for j, line in ipairs(normal) do
			local col, width = line[1], line[2]
			
			local obj = templates[col]:Clone()
			obj.Parent = road.normal[tostring(i)]
			obj.LayoutOrder = j*mod
			obj.Size = UDim2.new(0, width*lw_px, 1, 0)
		end
		
		for j, line in ipairs(dashed) do
			local col, width = line[1], line[2]
			
			local obj = templates[col]:Clone()
			obj.Parent = road.dashed[tostring(i)]
			obj.LayoutOrder = j*mod
			obj.Size = UDim2.new(0, width*lw_px, 1, 0)
		end
	end
	
	if #self.vals == 1 then
		road.normal["2"].Visible = false
		road.dashed["2"].Visible = false
		road.normal["1"].Position = UDim2.new(.25, 0, 0, 0)
		road.dashed["1"].Position = UDim2.new(.25, 0, 0, 0)
	end
	
	for i=1, 2 do
		local nroad = road:Clone()
		nroad.Parent = road.Parent
		
		nroad.Position = UDim2.new(0.5, 0, 0, i*road.Size.Y.Offset)
		
		if i == 2 then
			nroad.dashed:Destroy()
		end
	end
end

return LE