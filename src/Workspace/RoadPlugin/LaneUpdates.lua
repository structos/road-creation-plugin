local CS = game:GetService("CollectionService")

local m = {}

local function ch(nxt)
	CS:AddTag(nxt, "LaneChanged")
end

function m.watch(nxt)
	CS:AddTag(nxt, "LaneObject")
	
	nxt.Parent.Changed:Connect(function() ch(nxt) end)
	nxt.Value.Changed:Connect(function() ch(nxt) end)
	
	ch(nxt)  -- auto-render new nodes

end

-- end

function m.clearChanged()
	for _, n in ipairs(CS:GetTagged("LaneChanged")) do
		CS:RemoveTag(n, "LaneChanged")
	end
end

function m.tag(nxt)
	-- tag lane as changed
	
	ch(nxt)
end

function m.changed(nxt)
	-- return true if lane changed
	
	return CS:HasTag(nxt, "LaneChanged")
end

function m.tagged()
	return CS:GetTagged("LaneObject")
end

return m