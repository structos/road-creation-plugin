local propnames = {"Color3", "OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV", "Texture", "Transparency"}

local M = {}
M.__index = M

function M.Prompt(props, cb)
	local self = setmetatable({}, M)
	
	local t = script.Texture:Clone()
	t.Name = "__TextureEditor__"
	t.Parent = workspace
	
	self.props = props
	self.cb = cb
	
	for k, v in pairs(props) do
		pcall(function() t[k] = v end)
	end
	
	t.Changed:Connect(function()
		for _, k in ipairs(propnames) do
			self.props[k] = t[k]
		end
		
		if self.cb then
			self.cb(self.props)
		end
	end)
		
	game.Selection:Set({t})
	game.Selection.SelectionChanged:Connect(function()
		t:Destroy()
	end)
	
	return self
end

return M