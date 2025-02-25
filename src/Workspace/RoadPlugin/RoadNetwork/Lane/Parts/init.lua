local draw_triangle = require(script.Triangle)
local function scopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

local Parts = {}

function Parts.Object(class, props)
	-- Any Instance	
	
	local props = props or {}
	
	local obj = Instance.new(class)
	
	if obj:IsA("BasePart") then
		-- default values for parts		
		
		obj.Anchored = true
		
		obj.BottomSurface = Enum.SurfaceType.Smooth
		obj.TopSurface = Enum.SurfaceType.Smooth
	end
	
	if props.TextureID then
		for _, s in ipairs({Enum.NormalId.Top}) do
			local t = Instance.new("Texture", obj)
			
			t.Texture = props.TextureID
			t.Color3 = props.TextureColor -- or props.Color
			t.Transparency = props.TextureTransparency
			t.StudsPerTileU = props.TextureSize.U
			t.StudsPerTileV = props.TextureSize.V
			t.Face = s
		end
	end
	
	props.TextureID = nil
	props.TextureColor = nil
	props.TextureTransparency = nil
	props.TextureSize = nil

	
	for k, v in pairs(props) do
		obj[k] = v
	end
	
	return obj
end

function Parts.Part(props)
	-- shorthand for Part instance	
	
	return Parts.Object("Part", props)
end

function Parts.WedgePart(props)
	-- shorthand for WedgePart instance
	
	return Parts.Object("WedgePart", props)
end

function Parts.Rail(from, to, diameter, props)
	-- Creates a rail between two Vector3s
	
	local rail = Parts.Object("Part", props)
	rail.Shape = Enum.PartType.Cylinder
	
	local length = (to - from).Magnitude
	local center = (from + to)/2
	
	rail.Size = Vector3.new(length, diameter, diameter) 
	
	rail.CFrame = CFrame.new(center, to)  * CFrame.Angles(0, math.rad(90), 0)
	
	rail.Name = "rail"
	
	return rail
end

function Parts.CurvedRail(cf, segs, diameter, props)
	local folder = Instance.new("Model")

	local lp
	for i=0, segs do
		local p = cf:PointAtAlpha(i/segs)

		if i > 0 then
			Parts.Rail(lp, p, diameter, props).Parent = folder
		end

		lp = p
	end

	return folder
end

function Parts.Path(from, to, width, height, props)
	local length = (to - from).Magnitude
	local center = (from + to)/2

	local path = Parts.Part(props)
	path.Size = Vector3.new(width, height, length)
	path.CFrame = CFrame.new(center, to)

	return path
end

function Parts.CurvedPath(cf, segs, width, height, props, sa, fa)
	local folder = Instance.new("Model")

	sa = sa or 0
	fa = fa or 1

	local bl, br
	for i=0, segs do
		local alpha = (i/segs)*(fa-sa) + sa

		local tcf = cf:CFrameAtAlpha(alpha)
		local tl = tcf.p - (width/2)*tcf.RightVector
		local tr = tcf.p + (width/2)*tcf.RightVector

		if i > 0 then
			Parts.Triangle(tl, tr, bl, props, height).Parent = folder
			Parts.Triangle(bl, br, tr, props, height).Parent = folder
		end

		bl, br = tl, tr
	end

	return folder
end



function Parts.Triangle(a, b, c, props, width)
	-- Draws triangle between 3 points
	
	local props = props or {}
	local width = width or 0
	
	local triangle = draw_triangle(a, b, c, width)
	
	
	
	for _, obj in ipairs(triangle:GetChildren()) do
		if props.TextureID then
			for _, s in ipairs({Enum.NormalId.Left, Enum.NormalId.Right}) do
				local t = Instance.new("Texture", obj)
				
				t.Texture = props.TextureID
				t.Color3 = props.TextureColor-- or props.Color
				t.Transparency = props.TextureTransparency
				t.StudsPerTileU = props.TextureSize.U
				t.StudsPerTileV = props.TextureSize.V
				t.Face = s
			end
		end

		local rprops = scopy(props)
		rprops.TextureID = nil
		rprops.TextureColor = nil
		rprops.TextureTransparency = nil
		rprops.TextureSize = nil
		for k, v in pairs(rprops) do
			obj[k] = v
		end
		
		--obj.Locked = true
	end
	
	return triangle
end


return Parts
