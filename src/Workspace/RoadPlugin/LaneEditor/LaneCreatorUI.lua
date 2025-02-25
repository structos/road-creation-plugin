local Updates = require(script.Parent.Parent.LaneUpdates)

local DIST = 20

local function sortLanes(t, r, nxt)
	local function _k(a, b)
		if a.CFrame:ToObjectSpace(b.CFrame).p.X > 0 then
			return true
		end
		
		return false
	end
	
	local function _k2(a, b)
		return _k(a.Value, b.Value)
	end
	
	local use = _k
	if nxt then
		use = _k2
	end
	
	if r then
		local function k(a, b)
			return not use(a, b)
		end
		table.sort(t, k)
	else
		table.sort(t, use)
	end
	
	
end

local function getValues(node, dir, nx)
	local nodes = {}
	for _, n in ipairs(node:GetChildren()) do
		if n.Name == "Next" and n.Value ~= nil then
			table.insert(nodes, n)
		end
	end
	
	print(#nodes)
	
	if #nodes == 0 then
		return {}
	end
	
	sortLanes(nodes, false, true)
	
	local vals = {}
	
	local left, right = nodes[1], nodes[#nodes]
	
	print(left, right)

	local hct = false
	
	for _, c in ipairs(left:GetChildren()) do
		if string.find(c.Name, "Left", 1, true) then
			table.insert(vals, c)
		end

		if (not hct) and c.Name == "RoadType" then
			table.insert(vals, c)
			hct = true
		end
	end
	for _, c in ipairs(right:GetChildren()) do
		if string.find(c.Name, "Right", 1, true) then
			table.insert(vals, c)
		end

		if (not hct) and c.Name == "RoadType" then
			table.insert(vals, c)
			hct = true
		end
	end
	
	return vals
end

local function sameOrient(a, b)
	local ra = math.floor(a.Orientation.Y*10)/10
	local rb = math.floor(b.Orientation.Y*10)/10
	
	return ra == rb
end

local UI = {}
UI.__index = UI
function UI.new(group, slf)
	local self = setmetatable({}, UI)
	
	self.right = {}
	self.left = {}
	
	self._slf = slf
	
	local nodes = group:GetChildren()
	
	local flv = group:FindFirstChild("Node")
	self.ry = flv.Orientation.Y
	flv:GetPropertyChangedSignal("Orientation"):Connect(function()
		self.ry = flv.Orientation.Y
		self:Rotate()
	end)
	
	for _, n in ipairs(nodes) do
		if n.Name == "Node" then
			if sameOrient(n, flv) then
				table.insert(self.right, n)
			else
				table.insert(self.left, n)
			end
		end
	end
	
	sortLanes(self.left, true)
	sortLanes(self.right)
	
	self.gui = script.LaneCreator:Clone()
	
	self:MakeSingleButtons()
	self:MakeSameDirButtons()
	self:MakeFullRoadButtons()
	self:AutoRotate()
	
	self.gui.Frame.UIScale.Scale = math.min(1, 3.5 / (#self.left + #self.right))
	
	self.gui.Frame.Lane:Destroy()

	-- nxt reference table
	self.nxt_table = {}
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ObjectValue") and v.Name == "Next" and v.Value ~= nil then
			if not self.nxt_table[v.Value] then
				self.nxt_table[v.Value] = {}
			end

			table.insert(self.nxt_table[v.Value], v)
		end
	end
	
	self:Rotate()
	return self
end

function UI:Rotate()
	local _, ry, _ = workspace.CurrentCamera.CFrame:ToOrientation()

	if self.gui:FindFirstChild("Frame") then
		self.gui.Frame.Rotation = (math.deg(ry) - self.ry)
	end
end

function UI:AutoRotate()
	local conn = workspace.CurrentCamera.Changed:Connect(function()
		self:Rotate()
	end)
		
	self:Rotate()
end

function UI:append(node, dir, prnt)
	local new = node:Clone()
	new.Parent = prnt or Instance.new("Model", node.Parent.Parent)
	new.Parent.Name = "Lane"
	
	new.CFrame = node.CFrame + node.CFrame.LookVector*dir*DIST
	
	for _, c in ipairs(new:GetChildren()) do
		if c.Name == "Next" then
			c:Destroy()
		end
	end
	
	local n1
	
	if dir == 1 then
		n1 = Instance.new("ObjectValue", node)
		n1.Name = "Next"; n1.Value = new
		
		local n2 = Instance.new("ObjectValue", new)
		n2.Name = "Next"; n2.Value = nil
		--self._slf(n1)

		local hcl, hcr = false, false
		local hct = false
		if self.nxt_table[node] then
			for _, ref in ipairs(self.nxt_table[node]) do
				if (not hct) and ref:FindFirstChild("RoadType") then
					ref.RoadType:Clone().Parent = n1
					hct = true
				end
				if (not hcl) and ref:FindFirstChild("CustomLeft") then
					ref.CustomLeft:Clone().Parent = n1
					hcl = true
				end
				if (not hcr) and ref:FindFirstChild("CustomRight") then
					ref.CustomRight:Clone().Parent = n1
					hcr = true
				end
			end
		end
		
		Updates.watch(n1)
		
	else
		n1 = Instance.new("ObjectValue", new)
		n1.Name = "Next"; n1.Value = node

		for _, v in ipairs(getValues(node)) do
			local nv = v:Clone()
			nv.Parent = n1
		end
		
		Updates.watch(n1)
	end
	
	
	return new
end

local function cloneNode(n, side)
	local newnode = n:Clone()
	newnode.Parent = n.Parent
	newnode.CFrame = n.CFrame + n.CFrame.RightVector * side*n.Size.X
	for _, c in ipairs(newnode:GetChildren()) do
		if c.Name == "Next" then c:Destroy() end
	end
	Instance.new("ObjectValue", newnode).Name = "Next"

	game.Selection:Set({})
	game.Selection:Set({newnode.Parent})
end

function UI:MakeSingleButtons()
	local width = (#self.right + #self.left)
	local pxwidth = width*50
	
	local tmp = self.gui.Frame.Lane:Clone()
	tmp.Parent = self.gui.Frame
	tmp.Name = "btn"
	
	local li = 0
	for i=1, #self.left do
		local l = tmp:Clone()
		l.Parent = tmp.Parent
		l.Position = UDim2.new(0.5, -pxwidth/2 + (i-.5)*50, .5, 0)
		l.Rotation = 180
		l.Name = "L" .. tostring(i)
		
		l.Before.MouseButton1Click:Connect(function()
			self:append(self.left[i], -1)
		end)
		l.After.MouseButton1Click:Connect(function()
			self:append(self.left[i], 1)
		end)

		-- side button checks
		if i == 1 then
			l.Right.MouseButton1Click:Connect(function()
				cloneNode(self.left[i], 1)
			end)
		else
			l.Right:Destroy()
		end

		if i == #self.left and #self.right == 0 then
			l.Left.MouseButton1Click:Connect(function()
				cloneNode(self.left[i], -1)
			end)
		else
			l.Left:Destroy()
		end
		
		li = i
	end
	
	for i=1, #self.right do
		local l = tmp:Clone()
		l.Parent = tmp.Parent
		l.Position = UDim2.new(0.5, -pxwidth/2 + (i+li-.5)*50, .5, 0)
		l.Name = "R" .. tostring(i)
		
		l.Before.MouseButton1Click:Connect(function()
			self:append(self.right[i], -1)
		end)
		l.After.MouseButton1Click:Connect(function()
			self:append(self.right[i], 1)
		end)

		-- side button checks
		if i == #self.right then
			l.Right.MouseButton1Click:Connect(function()
				cloneNode(self.right[i], 1)
			end)
		else
			l.Right:Destroy()
		end

		if i == 1 and #self.left == 0 then
			l.Left.MouseButton1Click:Connect(function()
				cloneNode(self.right[i], -1)
			end)
		else
			l.Left:Destroy()
		end
	end
	
	tmp:Destroy()
end

function UI:MakeSameDirButtons()
	local function mkBtn(group, dir, selectnew)
		local btn = Instance.new("TextButton")
		
		btn.Size = UDim2.new(0, #group*50-6, 0, 15)
		btn.Text = "+"
		btn.BorderSizePixel = 0
		btn.BackgroundColor3 = dir == 1 and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
		btn.AnchorPoint = dir == 1 and Vector2.new(0, 1) or Vector2.new(0, 0)
		btn.Position = dir == 1 and UDim2.new(0, 3, -1, -5) or UDim2.new(0, 3, 2, 5)
		
		btn.MouseButton1Click:Connect(function()
			local nprnt = Instance.new("Model", group[1].Parent.Parent)
			nprnt.Name = "Lane"
			
			for _, n in ipairs(group) do
				self:append(n, dir, nprnt)
			end

			if selectnew then
				game.Selection:Set({nprnt})
			end
		end)
		
		return btn
	end
	
	if #self.left > 0 then
		mkBtn(self.left, 1, #self.right == 0).Parent = self.gui.Frame["L" .. tostring(#self.left)]
		mkBtn(self.left, -1, #self.right == 0).Parent = self.gui.Frame["L" .. tostring(#self.left)]
	end
	if #self.right > 0 then
		mkBtn(self.right, 1, #self.left == 0).Parent = self.gui.Frame["R1"]
		mkBtn(self.right, -1, #self.left == 0).Parent = self.gui.Frame["R1"]
	end
end

function UI:MakeFullRoadButtons()
	local function mkBtn(dir, width)
		local btn = Instance.new("TextButton")
		
		btn.Size = UDim2.new(0, width*50, 0, 15)
		btn.Text = "+"
		btn.BorderSizePixel = 0
		btn.BackgroundColor3 = Color3.new(.8, .8, 1)
		btn.AnchorPoint = Vector2.new(1, 1)
		btn.Position = UDim2.new(1, 0, -2, -10)
		
		btn.MouseButton1Click:Connect(function()
			local nprnt = Instance.new("Model", self.left[1].Parent.Parent or self.right[1].Parent.Parent)
			nprnt.Name = "Lane"
			
			for _, n in ipairs(self.right) do
				self:append(n, dir, nprnt)
			end
			
			for _, n in ipairs(self.left) do
				self:append(n, -dir, nprnt)
			end

			game.Selection:Set({nprnt})
		end)
		
		return btn
	end
	
	if #self.left > 0 and #self.right > 0 then
		local w = #self.left + #self.right
		mkBtn(1, w).Parent = self.gui.Frame["R" .. tostring(#self.right)]
		mkBtn(-1, w).Parent = self.gui.Frame["L" .. tostring(1)]
	end
end

return UI