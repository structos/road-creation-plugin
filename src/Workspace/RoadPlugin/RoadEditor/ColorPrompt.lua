local propnames = {"Color3"}

local M = {}
M.__index = M

function M.Prompt(color, cb)
	local self = setmetatable({}, M)
	
	local t = script.Value:Clone()
	t.Name = "__ColorEditor__"
	t.Parent = workspace
	
	self.color = color or Color3.new(1, 1, 1)
	self.cb = cb
	
	
	t.Value = color
	
	t.Changed:Connect(function()
		self.color = t.Value
		
		if self.cb then
			self.cb(self.color)
		end
	end)
		
	game.Selection:Set({t})
	game.Selection.SelectionChanged:Connect(function()
		t:Destroy()
	end)
	
	return self
end

return M