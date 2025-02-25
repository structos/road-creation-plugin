local priority = {
	"FormFactor";
	"Size";
	"Position";
	"CFrame";
}
local function create(class_name)
	return function(data)
		local obj = Instance.new(class_name)
		for _, v in pairs(priority) do
			if data[v] then
				obj[v] = data[v]
				data[v] = nil
			end
		end
		for i, v in pairs(data) do
			obj[i] = v
		end
		return obj
	end
end

local newV3 = Vector3.new
local newCF = CFrame.new
local angleCF = CFrame.Angles
local newRay = Ray.new
local rad = math.rad

local function newMesh(parent, width)
	local mesh = Instance.new("SpecialMesh")
	
	mesh.MeshType = Enum.MeshType.Wedge
	mesh.Scale = newV3(width, 1, 1)
	mesh.Parent = parent
	
	return mesh
end

local function create_wedge(size, cf, parent)
	return create "WedgePart" {
		Anchored = true;
		TopSurface = "SmoothNoOutlines";
		BottomSurface = "SmoothNoOutlines";
		RightSurface = "SmoothNoOutlines";
		LeftSurface = "SmoothNoOutlines";
		FrontSurface = "SmoothNoOutlines";
		BackSurface = "SmoothNoOutlines";
		FormFactor = "Custom";
		Size = size; --+ newV3(0, .05, .05);
		CFrame = cf;
		Parent = parent;
	}
end

local function draw_triangle(p1, p2, p3, width)
	local width = width or 0
	local meshScale = 1
	
	if width < 0.05 then
		meshScale = width/0.05
		
		width = 0.05
	end	
	
	local folder = Instance.new("Folder")
	folder.Name = "triangle"	
	
	local searching = true
	local d
	while searching do
		local d1 = newRay(p1, (p3 - p1).unit):ClosestPoint(p2)
		local d2 = newRay(p3, (p1 - p3).unit):ClosestPoint(p2)
		if (d1 - d2).magnitude > 0.001 then
			local p = p1
			p1 = p3
			p3 = p2
			p2 = p
		else
			d = d1
			searching = false
		end
		-- wait() -- Safety
	end
	local pos = p1:lerp(p2, 0.5)
	local v3 = (p2:lerp(d, 0.5) - pos).unit
	local v2 = (p1:lerp(d, 0.5) - pos).unit * (-1)
	local v1 = v2:Cross(v3)

	if meshScale ~= 1 then
		newMesh(create_wedge(newV3(width, (p2 - d).magnitude, (p1 - d).magnitude), newCF(pos.x, pos.y, pos.z, v1.x, v2.x, v3.x, v1.y, v2.y, v3.y, v1.z, v2.z, v3.z), folder), meshScale)
	else
		create_wedge(newV3(width, (p2 - d).magnitude, (p1 - d).magnitude), newCF(pos.x, pos.y, pos.z, v1.x, v2.x, v3.x, v1.y, v2.y, v3.y, v1.z, v2.z, v3.z), folder)
	end

	if (d - p1).magnitude > 0.001 or (d - p3).magnitude > 0.001 then
		local pos = p3:lerp(p2, 0.5)
		local v3 = (p2:lerp(d, 0.5) - pos).unit
		local v2 = (p3:lerp(d, 0.5) - pos).unit * (-1)
		local v1 = v2:Cross(v3)

		if meshScale ~= 1 then
			newMesh(create_wedge(newV3(width, (p2 - d).magnitude, (p3 - d).magnitude), newCF(pos.x, pos.y, pos.z, v1.x, v2.x, v3.x, v1.y, v2.y, v3.y, v1.z, v2.z, v3.z), folder), meshScale)
		else
			create_wedge(newV3(width, (p2 - d).magnitude, (p3 - d).magnitude), newCF(pos.x, pos.y, pos.z, v1.x, v2.x, v3.x, v1.y, v2.y, v3.y, v1.z, v2.z, v3.z), folder)
		end
	end

	return folder
end

return draw_triangle