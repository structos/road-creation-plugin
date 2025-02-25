return function()
    for _, n in ipairs(workspace:GetDescendants()) do
        if n.Name == "Next" and n:IsA("ObjectValue") then
            if n.Parent:FindFirstChild("arrow") then
                n.Parent.arrow.Texture = "rbxassetid://4920597083"
            end
        end
    end
end