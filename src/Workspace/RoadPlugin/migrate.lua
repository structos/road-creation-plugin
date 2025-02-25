local SS = game:GetService("ServerScriptService")

return function()
    if SS:FindFirstChild("RemoveNodes") then
        SS.RemoveNodes:Destroy()

        local s = script.Parent.RemoveNodes:Clone()
        s.Parent = SS
        s.Disabled = false	
    end

    local not_allowed = {"__RoadPluginLine", "__LaneDisplayLine__", "__RoadPluginTypeEditDisp"}
    for _, c in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if table.find(not_allowed, c.Name) then
                c:Destroy()
            end
        end)
    end
end

