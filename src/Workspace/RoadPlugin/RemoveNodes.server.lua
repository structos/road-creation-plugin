local not_allowed = {"__RoadPluginLine", "__LaneDisplayLine__", "__RoadPluginTypeEditDisp"}

for _, c in ipairs(workspace:GetDescendants()) do
	pcall(function()
		if c.Name == "Next" and c:IsA("ObjectValue") then
			c.Parent:Destroy()
		end

		if table.find(not_allowed, c.Name) then
			c:Destroy()
		end
	end)
end