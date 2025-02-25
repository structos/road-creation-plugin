local cfcurve = require(script.Parent.CFCurve)
local Parts = require(script.Parts)
local Pattern = require(script.RoadPatterns)

local function lerpAbs(a, b, delta)
	local d = (b-a).Magnitude
	local alpha = delta/d
	
	return a:Lerp(b, alpha)
end
local function scopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

---

local CONCR = "rbxassetid://288525813"

---------------
local Road = {}

local SEGS_DEF = 20
local LP = 0.1

local COL = {}
COL.SD = Color3.new(1, 1, 1)
COL.OD = Color3.new(1, 1, 0)
COL.ASPH = Color3.fromRGB(99, 95, 98)

local Default = {SegmentLength = 10, MaxSegments = 60}

function Road.Node(p)
	local n = {}
	
	--n.CF = p.CFrame
	n.LCF = p.CFrame * CFrame.new(-p.Size.X/2, 0, 0)
	n.RCF = p.CFrame * CFrame.new(p.Size.X/2, 0, 0)
	n.p  = p
	
	return n
end

local function getRoadType(group)	
	for _, lane in ipairs(group) do
		if lane.roadtype ~= "Default" then
			return lane.roadtype
		end
	end

	return "Default"
end

local function extraDistance(a, b, c, w)
	local p0 = Vector2.new(b.x-a.x, b.z-a.z)
	local p1 = Vector2.new(c.x-b.x, c.z-b.z)

	local theta = math.pi*2 - (math.atan2(p1.y, p1.x) - math.atan2(p0.y, p0.x))
	return (math.tan(theta/2))/2
end

function Road.DrawLaneGroup(group, parent, rcfg, rtypes)
	
	local len = group[1]:leftlength()

	local W = rcfg.RoadThickness or 0.3
	Pattern.LineWidth = rcfg.LineWidth
	
	local segs = len / (rcfg.SegmentLength)
	local psegs = math.floor((10 / rcfg.SegmentLength) + 0.5)
	
	segs = math.ceil(segs/(2*psegs))*(2*psegs) + 1
	
	local segs = math.min(segs, rcfg.MaxSegments + 1)
	local cfg = {}
	cfg.segments = segs

	-- get material colors/textures
	local roadtype = getRoadType(group)
	local mats = rtypes:Get()[roadtype]
	if mats == nil then
		warn(("Missing material '%s', lane group failed to render"):format(roadtype))
		return
	end

	-- pepare lines	
	local curves = {}

	local lines0 = {{"nil"}}
	local lines1 = {{"nil"}}
	for idx, lane in ipairs(group) do
		local defleft, defright = "(.5W)", "(.5W)"
		
		if idx == 1 then
			defleft = ".5A;1Y"
		end
		if idx == #group then
			defright = "1.5A;1W"
		end

		local pattern = Pattern.LanePattern(defleft, defright, lane.customleft, lane.customright)
		table.insert(lines0[#lines0], pattern[1][1])
		table.insert(lines0, {pattern[1][2]})

		table.insert(lines1[#lines1], pattern[2][1])
		table.insert(lines1, {pattern[2][2]})

		table.insert(curves, lane:lcurve())
	end
	local linelists = {lines0, lines1}

	table.insert(curves, group[#group]:rcurve())
	
	-- render asphalt
	local edgelcurve = group[1]:lcurve()
	local edgercurve = group[#group]:rcurve()

	local mcf0 = group[1].LCF:Lerp(group[#group].RCF, 0.5)	
	local mcf1 = group[1].endLCF:Lerp(group[#group].endRCF, 0.5)	
	local middlecurve = cfcurve(mcf0, mcf1)

	local road_width = (edgelcurve:PointAtAlpha(0) - edgercurve:PointAtAlpha(0)).Magnitude
	local middle_width = (edgelcurve:PointAtAlpha(0.5) - edgercurve:PointAtAlpha(0.5)).Magnitude
	local uniform_width = math.abs(road_width - (edgelcurve:PointAtAlpha(1) - edgercurve:PointAtAlpha(1)).Magnitude) <= 1/20
	local extra_width = math.max(0, middle_width-road_width)

	-- asphalt loop

	local sl = CFrame.new(group[1].CF.p, group[1].endCF.p)

	local _, ry0, _ = group[1].CF:ToOrientation()
	local _, ry1, _ = sl:ToOrientation()
	local _, ry2, _ = group[1].endCF:ToOrientation()

	ry0 = (ry0 < 0 and ry0 + 360) or ry0
	ry1 = (ry1 < 0 and ry1 + 360) or ry1
	ry2 = (ry2 < 0 and ry2 + 360) or ry2

	-- total rotation
	local rot = math.abs(ry1-ry0) + math.abs(ry2-ry1)


	local hflat = true

	local bg_res
	if rot == 0 then
		bg_res = 0.001
	elseif rot <= math.pi/6 then
		bg_res = 0.7
	else
		bg_res = 1
	end

	if math.abs(group[1].CF.p.y - group[1].endCF.p.y) > 1/100 then
		bg_res = 1
		hflat = false
	end

	local asphalt_segs = math.max(2, math.floor(bg_res*segs))

	local rparts = {}


	local oldPoints = {}
	for j=1, asphalt_segs do
		local alpha = (j-1)/(asphalt_segs-1)
		local lalph = (j-2)/(asphalt_segs-1)
		local tl, tr = edgelcurve:PointAtAlpha(alpha), edgercurve:PointAtAlpha(alpha)

		local points = {}
		for _, curve in ipairs(curves) do
			table.insert(points, curve:PointAtAlpha(alpha))
		end

		if alpha > 0 then
			-- ROAD BACKGROUND
			do
				local props = {Material = Enum.Material.Concrete, Locked=true}
				
				props.TextureID = mats.Asphalt.TextureID
				props.Color = mats.Asphalt.Color
				props.TextureColor = mats.Asphalt.TextureColor
				props.TextureTransparency = mats.Asphalt.TextureTransparency
				props.TextureSize = mats.Asphalt.TextureSize
				props.Material = mats.Asphalt.Material

				-- decide whether to render parts or triangles

				local a, b, c, d = points[1], points[#points], oldPoints[1], oldPoints[#points]

				-- check if corners are same height
				-- if so, road is flat
				-- if not, render triangles
				local flat = uniform_width  -- use triangles if width changes
				local threshold = 1/1000

				for _, corner in ipairs({b, c, d}) do
					if math.abs(corner.y - a.y) > threshold then
						flat = false
						break
					end
				end

				if not flat then
					hflat = false
				end

				local tris = not flat

				--/--
				
				if tris then
					local cf_a, cf_b = edgelcurve:CFrameAtAlpha(alpha), edgercurve:CFrameAtAlpha(alpha)
					local cf_c, cf_d = edgelcurve:CFrameAtAlpha(lalph), edgercurve:CFrameAtAlpha(lalph)

					local u_a = cf_a.p + cf_a.UpVector * (W/2)
					local u_b = cf_b.p + cf_b.UpVector * (W/2)
					local u_c = cf_c.p + cf_c.UpVector * (W/2)
					local u_d = cf_d.p + cf_d.UpVector * (W/2)

					local tri0 = Parts.Triangle(u_a, u_b, u_c, props, W); tri0.Parent = parent
					local tri1 = Parts.Triangle(u_b, u_c, u_d, props, W); tri1.Parent = parent

					local function adjustPart(p)
						local dir = 1
						if p.CFrame.RightVector.y > 0 then
							dir = -1
						end

						p.CFrame = p.CFrame + p.CFrame.RightVector*(W/2)*dir
					end

					for _, p in ipairs(tri0:GetChildren()) do
						adjustPart(p)
					end
					for _, p in ipairs(tri1:GetChildren()) do
						adjustPart(p)
					end
				end

				if flat and j ~= 2 and j ~= asphalt_segs then
					-- use normal part

					local cf0 = middlecurve:CFrameAtAlpha(lalph)
					local cf1 = middlecurve:CFrameAtAlpha(alpha)

					local len0 = ((cf0.p + cf0.RightVector*(road_width/2+extra_width)) - (cf1.p + cf1.RightVector*(road_width/2+extra_width))).Magnitude
					local len1 = ((cf0.p - cf0.RightVector*(road_width/2+extra_width)) - (cf1.p - cf1.RightVector*(road_width/2+extra_width))).Magnitude
					local len = math.max(len0, len1)

					props.CFrame = CFrame.new(cf0.p:Lerp(cf1.p, 0.5), cf1.p)
					props.Size = Vector3.new(road_width, W, len)


					-- UPDATE THIS WHEN YOU ADD ROAD DIRECTIONS
					if extra_width > 0 then
						props.Size = Vector3.new(road_width+extra_width, W, props.Size.z)
						props.CFrame = props.CFrame - props.CFrame.RightVector * extra_width/2
					end

					local p = Parts.Part(props)
					p.Parent = parent

					table.insert(rparts, p)
				end
			end
		end	
		oldPoints = points
	end

	if hflat or #rparts > 0 then
		-- make beginning and end tri
		-- or straight road

		if bg_res == 0.001 then
			local props = {Material = Enum.Material.Concrete, Locked=true}
			
			props.TextureID = mats.Asphalt.TextureID
			props.Color = mats.Asphalt.Color
			props.TextureColor = mats.Asphalt.TextureColor
			props.TextureTransparency = mats.Asphalt.TextureTransparency
			props.TextureSize = mats.Asphalt.TextureSize
			props.Material = mats.Asphalt.Material
			props.CFrame = middlecurve:CFrameAtAlpha(0.5)
			props.Size = Vector3.new(road_width, W, (middlecurve:PointAtAlpha(1)-middlecurve:PointAtAlpha(0)).Magnitude)

			Parts.Part(props).Parent = parent
			
		else
			-- first
			local ta, tb = edgelcurve:CFrameAtAlpha(0).p, edgercurve:CFrameAtAlpha(0).p
			local tc, td
			if #rparts == 0 then
				tc, td = edgelcurve:CFrameAtAlpha(1).p, edgercurve:CFrameAtAlpha(1).p
			else
				tc = rparts[1].CFrame.p - rparts[1].CFrame.RightVector*(rparts[1].Size.x/2) - rparts[1].CFrame.LookVector*(rparts[1].Size.z/2)
				td = rparts[1].CFrame.p + rparts[1].CFrame.RightVector*(rparts[1].Size.x/2) - rparts[1].CFrame.LookVector*(rparts[1].Size.z/2)
			end

			local props = {Material = Enum.Material.Concrete, Locked=true}
				
			props.TextureID = mats.Asphalt.TextureID
			props.Color = mats.Asphalt.Color
			props.TextureColor = mats.Asphalt.TextureColor
			props.TextureTransparency = mats.Asphalt.TextureTransparency
			props.TextureSize = mats.Asphalt.TextureSize
			props.Material = mats.Asphalt.Material

			Parts.Triangle(ta, tb, tc, props, W).Parent = parent
			Parts.Triangle(tb, tc, td, props, W).Parent = parent

			-- second
			local ta, tb = edgelcurve:CFrameAtAlpha(1).p, edgercurve:CFrameAtAlpha(1).p
			local tc, td
			if #rparts == 0 then
				tc, td = edgelcurve:CFrameAtAlpha(0).p, edgercurve:CFrameAtAlpha(0).p
			else
				local prt = rparts[#rparts]
				tc = prt.CFrame.p - prt.CFrame.RightVector*(prt.Size.x/2) + prt.CFrame.LookVector*(prt.Size.z/2)
				td = prt.CFrame.p + prt.CFrame.RightVector*(prt.Size.x/2) + prt.CFrame.LookVector*(prt.Size.z/2)
			end

			local props = {Material = Enum.Material.Concrete, Locked=true}
				
			props.TextureID = mats.Asphalt.TextureID
			props.Color = mats.Asphalt.Color
			props.TextureColor = mats.Asphalt.TextureColor
			props.TextureTransparency = mats.Asphalt.TextureTransparency
			props.TextureSize = mats.Asphalt.TextureSize
			props.Material = mats.Asphalt.Material

			Parts.Triangle(ta, tb, tc, props, W).Parent = parent
			Parts.Triangle(tb, tc, td, props, W).Parent = parent
		end
	end

	

	-- line loop
	
	local oldPoints = {}
	local p_i = 0
	if CFrame.new(Vector3.new(), Vector3.new(math.pi/2, 0, 2.71)):PointToObjectSpace(group[1].CF.LookVector).Z > 0 then
		p_i = 0+psegs
	end

	-- lines
	for j=1, segs do
		local alpha = (j-1)/(segs-1)
		local lalph = (j-2)/(segs-1)
		local tl, tr = edgelcurve:PointAtAlpha(alpha), edgercurve:PointAtAlpha(alpha)

		local points = {}
		for _, curve in ipairs(curves) do
			table.insert(points, curve:PointAtAlpha(alpha))
		end

		
		if alpha > 0 then
			local lines = linelists[math.floor(p_i/psegs)+1]

			p_i = p_i + 1 
			if math.floor(p_i/psegs)+1 > 2 then
				p_i = 0
			end
					-- get extra distance to add to make lines align properly

			local pre_d = 0
			local post_d = 0

			if (j >= 1) then
				local a0, a1, a2 = (j-3)/(segs-1), (j-2)/(segs-1), (j-1)/(segs-1)
				local a, b, c = edgelcurve:PointAtAlpha(a0), edgelcurve:PointAtAlpha(a1), edgelcurve:PointAtAlpha(a2)
				pre_d = math.abs(extraDistance(a, b, c))
			end

			if j <= segs then
				local a0, a1, a2 = (j-2)/(segs-1), (j-1)/(segs-1), (j)/(segs-1)
				local a, b, c = edgelcurve:PointAtAlpha(a0), edgelcurve:PointAtAlpha(a1), edgelcurve:PointAtAlpha(a2)
				post_d = math.abs(extraDistance(a, b, c))
			end

			-- / --

			local trp = 1

			for j, line in ipairs(lines) do
				local left, right = line[1], line[2]

				-- if the initial lines of each side can be joined to form a middle line, do so
				local renderedMiddle = false
				if (left ~= "nil") and (right ~= nil) and (#left >= 1 and #right >= 1) then
					if left[1][1] ~= "Asphalt" and right[1][1] == left[1][1] then
						local width = left[1][2] + right[1][2]  -- total width

						-- find corners so we can get the midpoints
						local tl, tr = lerpAbs(points[j], points[j-1], left[1][2]), lerpAbs(points[j], points[j+1], right[1][2])
						local bl, br = lerpAbs(oldPoints[j], oldPoints[j-1], left[1][2]), lerpAbs(oldPoints[j], oldPoints[j+1], right[1][2])

						local a = bl:Lerp(br, 0.5)
						local b = tl:Lerp(tr, 0.5)

						-- create part
						local tW = W+LP
						local props = {Material = mats[left[1][1]].Material, Locked=true, CanCollide = false, Transparency = trp}

						props.TextureID = mats[left[1][1]].TextureID
						props.Color = mats[left[1][1]].Color
						props.TextureColor = mats[left[1][1]].TextureColor
						props.TextureTransparency = mats[left[1][1]].TextureTransparency
						props.TextureSize = mats[left[1][1]].TextureSize

						local theta, _, _ = CFrame.new(tl, tr):ToOrientation()
							
						props.CFrame = CFrame.new((a+b)/2, b) * CFrame.Angles(0, 0, theta)
						props.Size = Vector3.new(width, tW, (b-a).Magnitude + (pre_d + post_d)*width)
						
						local p = Parts.Part(props)
						p.Parent = parent

						-- stop lines from being rendered twice
						renderedMiddle = true
					end
				end

				if left ~= "nil" then
					local lp, lp2 = 0, 0
					for k, m in ipairs(left) do
						lp2 = lp + m[2]
						
						if m[1] ~= "Asphalt" and not (k==1 and renderedMiddle) then
							local tW = W+LP

							local props = {Material = mats[m[1]].Material, Locked=true, CanCollide = false, Transparency = trp}
							
							props.TextureID = mats[m[1]].TextureID
							props.Color = mats[m[1]].Color
							props.TextureColor = mats[m[1]].TextureColor
							props.TextureTransparency = mats[m[1]].TextureTransparency
							props.TextureSize = mats[m[1]].TextureSize
							
							local a = lerpAbs(oldPoints[j], oldPoints[j-1], (lp+lp2)/2)
							local b = lerpAbs(points[j], points[j-1], (lp+lp2)/2)

							local w = lp2-lp
					
							local theta, _, _ = CFrame.new(tl, tr):ToOrientation()
							
							props.CFrame = CFrame.new((a+b)/2, b) * CFrame.Angles(0, 0, theta)
							props.Size = Vector3.new(w, tW, (b-a).Magnitude + (pre_d + post_d)*w)
							
							local p = Parts.Part(props)
							p.Parent = parent
						end

						lp = lp2
					end
				end

				if right then
					local lp, lp2 = 0, 0
					for k, m in ipairs(right) do
						lp2 = lp + m[2]

						if m[1] ~= "Asphalt" and not (k==1 and renderedMiddle) then
							local tW = W+LP

							local props = {Material = mats[m[1]].Material, Locked=true, CanCollide = false, Transparency = trp}
							
							props.TextureID = mats[m[1]].TextureID
							props.Color = mats[m[1]].Color
							props.TextureColor = mats[m[1]].TextureColor
							props.TextureTransparency = mats[m[1]].TextureTransparency
							props.TextureSize = mats[m[1]].TextureSize
							
							local a = lerpAbs(oldPoints[j], oldPoints[j+1], (lp+lp2)/2)
							local b = lerpAbs(points[j], points[j+1], (lp+lp2)/2)

							local w = lp2-lp
					
							local theta, _, _ = CFrame.new(tl, tr):ToOrientation()
							
							props.CFrame = CFrame.new((a+b)/2, b) * CFrame.Angles(0, 0, theta)
							props.Size = Vector3.new(w, tW, (b-a).Magnitude + (pre_d + post_d)*w)
							
							local p = Parts.Part(props)
							p.Parent = parent
						end

						lp = lp2
					end
				end
			end
		end
		
		oldPoints = points
	end
	

end


return Road