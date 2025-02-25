local LaneCreatorUI = require(script.LaneCreatorUI)
local Updates = require(script.Parent.LaneUpdates)
local cui = nil
local CoreGui = game:GetService("CoreGui")


local LE = {}
LE.__index = LE

local NewLaneUI = script.NewLanes

function LE.new(mouse, GUIP)
	local self = setmetatable({}, LE)
	
	self.Enabled = false
	self.MouseEnabled = false
	self.LaneLines = {}
	
	self.GUIP = GUIP
	
	local CoreGui = game:GetService("CoreGui")

	local hbox = Instance.new("SelectionBox", CoreGui)
	hbox.Color3 = Color3.fromRGB(38, 255, 23)
	hbox.Visible = false
	
	local sbox = Instance.new("SelectionBox", CoreGui)
	sbox.Color3 = Color3.fromRGB(230, 255, 0)
	sbox.Visible = true
	
	mouse.Move:Connect(function()
		local t = mouse.Target
		if self.MouseEnabled and t and t.Name == "Node" then
			hbox.Adornee = t
			hbox.Visible = true
		else
			hbox.Adornee = nil
			hbox.Visible = false
		end
	end)
	
	local Sel0
	mouse.Button1Up:Connect(function()
		if not self.MouseEnabled then 
			return
		end
		
		local t = hbox.Adornee
		
		if not t then
			Sel0 = nil
			sbox.Adornee = nil
			NewLaneUI.Step2.Visible = false
		else
			if not Sel0 then
				Sel0 = t
				sbox.Adornee = t
				
				NewLaneUI.Step2.Visible = true
			else
				local p0 = Sel0
				local p1 = t

				-- does this direction make sense?
				if p0.CFrame:ToObjectSpace(p1.CFrame).p.z > 0 then
					-- doesn't make sense
					-- does the other direction make MORE sense?

					if p1.CFrame:ToObjectSpace(p0.CFrame).p.z < 0 then
						-- yes, use this direction instead

						p0, p1 = p1, p0  -- swap
					end
				end

				local n = Instance.new("ObjectValue", p0)
				n.Name = "Next"
				n.Value = p1
				Sel0 = nil
				sbox.Adornee = nil
				
				if self.Enabled then
					self:ShowLane(n)
				end
				
				Updates.watch(n)
				
				NewLaneUI.Step2.Visible = false
			end
		end
	end)
	
	NewLaneUI.Step2.Cancel.MouseButton1Click:Connect(function()
		Sel0 = nil
		sbox.Adornee = nil
		NewLaneUI.Step2.Visible = false
	end)
	
	local cui
	game.Selection.SelectionChanged:Connect(function()
		if cui then
			cui.gui:Destroy()
		end
		
		local sel = game.Selection:Get()
		
		if not (#sel == 1 and sel[1]:FindFirstChild("Node")) then
			return
		end
		
		local group = sel[1]
		
		cui = LaneCreatorUI.new(group)
		cui.gui.Parent = self.GUIP
	end)
		
	-----------
	return self
end
	
local function attachment(part)
	local a = Instance.new("Attachment", part)
	a.Position = Vector3.new(0, part.Size.Y/2+.1, 0)
	return a
end

function LE:UME()
	-- update new connection ui
	
	if self.MouseEnabled then
		NewLaneUI.Parent = self.GUIP
	else
		NewLaneUI.Parent = script
	end
end
	
	
	-------------------
	
	-- lane display/removal --
	
	
	
function LE:ShowLane(nxt)
	-- takes Next node value and displays lane
	
	if not nxt.Value then return end
	
	local first, last = nxt.Parent, nxt.Value
	
	local line = script.__LaneDisplayLine__:Clone()
	line.Parent = workspace
	
	local lv = Instance.new("ObjectValue", line)
	lv.Name = "Lane"
	lv.Value = nxt
	
	local a0 = attachment(first)
	local a1 = attachment(last)
	
	line.Attachment0 = a0
	line.Attachment1 = a1
	
	local function remove(test)
		if not test:IsDescendantOf(game) then
			-- line removed
			
			if self.Enabled then
				-- line was deleted by user
				nxt:Destroy()
			end
			
			a0:Destroy()
			a1:Destroy()
		end
	end
	
	line.AncestryChanged:Connect(function ()
		remove(line)
	end)
		
	a0.AncestryChanged:Connect(function()
		remove(a0)
	end)
	a1.AncestryChanged:Connect(function()
		remove(a1)
	end)

	table.insert(self.LaneLines, line)
	return line
end

function LE:HideLanes()
	self.Enabled = false
	-- ensure next node values arent destroyed
	
	for _, l in ipairs(self.LaneLines) do
		l:Destroy()
	end
end





return LE
