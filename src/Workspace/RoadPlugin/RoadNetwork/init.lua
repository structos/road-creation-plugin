local insert = table.insert
local find = table.find

local Lane = require(script.Lane)
local cfcurve = require(script.CFCurve)

local Updates = require(script.Parent.LaneUpdates)

---------------
local function sameOrient(a, b)
	if not (a:IsA("BasePart") and b:IsA("BasePart")) then
		return false
	end
	
	local ra = math.floor(a.Orientation.Y*1)/1
	local rb = math.floor(b.Orientation.Y*1)/1
	
	if ra < 0 then
		ra = ra + 360
	end
	if rb < 0 then
		rb = rb + 360
	end
	
	return ra == rb
end

local function cf_ry(cf)
	local _, ry, _ = cf:ToOrientation()
	ry = math.deg(ry)
	ry = (ry < 0 and ry + 360) or ry
	ry = tostring(math.floor(ry/6)*6 or 0)

	return ry
end


local function lane_ry(lane)
	local p0 = Vector3.new(lane[1].Position.X, 0, lane[1].Position.Z)
	local p1 = Vector3.new(lane[2].Position.X, 0, lane[2].Position.Z)

	local cf = CFrame.new(p0, p1)

	return cf_ry(cf)
end

local function findLaneNeighbors(node)
	local neighbors = {}
	
	if not node then
		return {}
	end
	if not node.Parent then
		return {}
	end
	
	
	
	for _, n in ipairs(node.Parent:GetChildren()) do
		if sameOrient(n, node) then
			for _, v in ipairs(n:GetChildren()) do
				if v.Name == "Next" and v.Value ~= nil then
					insert(neighbors, v)
				end
			end
			
		end
	end
	
	return neighbors
end

local function sortLanes(t)
	local function k(a, b)
		if a[2].CFrame:ToObjectSpace(b[2].CFrame).p.X > 0 then
			return true
		end
		
		return false
	end
	
	table.sort(t, k)
end

local function mlane(nxt)
	local lane = {nxt.Parent, nxt.Value}
	
	lane.customleft, lane.customright = nil, nil

	lane.CF = lane[1].CFrame
	lane.endCF = lane[2].CFrame

	lane.LCF = lane[1].CFrame - lane[1].CFrame.RightVector*lane[1].Size.X/2
	lane.RCF = lane[1].CFrame + lane[1].CFrame.RightVector*lane[1].Size.X/2
	lane.endLCF = lane[2].CFrame - lane[2].CFrame.RightVector*lane[2].Size.X/2
	lane.endRCF = lane[2].CFrame + lane[2].CFrame.RightVector*lane[2].Size.X/2
	
	if nxt:FindFirstChild("CustomLeft") then
		lane.customleft = nxt.CustomLeft.Value
	end
	if nxt:FindFirstChild("CustomRight") then
		lane.customright = nxt.CustomRight.Value
	end

	lane.roadtype = "Default"
	if nxt:FindFirstChild("RoadType") then
		lane.roadtype = nxt.RoadType.Value
	end
	
	lane.CFG = {}
	for _, v in ipairs(nxt:GetChildren()) do
		lane.CFG[v.Name] = v.Value
	end
	lane.nxt = nxt
	lane.orient = math.floor(lane[1].Orientation.Y*10)/10
	
	function lane.length()
		local curve = cfcurve(lane[1].CFrame, lane[2].CFrame)
		return curve:Length()
	end
	
	function lane.lcurve()
		return cfcurve(lane[1].CFrame - lane[1].CFrame.RightVector*lane[1].Size.X/2,
					   lane[2].CFrame - lane[2].CFrame.RightVector*lane[2].Size.X/2)
	end
	function lane.leftlength()
		return lane.lcurve():Length()
	end
	
	function lane.rcurve()
		return cfcurve(lane[1].CFrame + lane[1].CFrame.RightVector*lane[1].Size.X/2,
					   lane[2].CFrame + lane[2].CFrame.RightVector*lane[2].Size.X/2)
	end
	
	return lane
end


---------------
local RN = {}
RN.__index = RN

function RN.new(parent, rendercfg)
	local self = setmetatable({}, RN)
	
	self.lanes = {}
	self.lanegroups = {}
	self.rcfg = rendercfg
	
	self.Parent = parent
	
	-----------
	return self
end

function RN:CleanGarbage()
	local deld = 0
	for _, p in ipairs(workspace:GetDescendants()) do
		if p:IsA("ObjectValue") and p.Name == "Next" and p.Value ~= nil then
			if p.Value.Parent == nil or p.Value.Parent.Parent == nil or p.Parent.Parent.Parent == nil then
				p:Destroy()
				deld = deld + 1
			end
		end
	end
	

	if deld > 0 then
		print(("Removed %s garbage lanes."):format(deld))
	end
end

function RN:FindLanes()
	-- returns nodes not found in lane groups

	local ungrouped = {}
	local exists = {}

	for _, p in ipairs(workspace:GetDescendants()) do
		if p:IsA("ObjectValue") and p.Name == "Next" and p.Value ~= nil then
			local valid = true

			if not (p.Parent.Parent.ClassName == "Model") then
				valid = false
				table.insert(ungrouped, p.Parent)
			end

			if not (p.Value.Parent.ClassName == "Model") then
				valid = false
				table.insert(ungrouped, p.Value)
			end

			if not valid then
				print(p.Parent)
			end

			if valid and p.Value.Parent.Parent ~= nil and p.Parent.Parent.Parent ~= nil then
				local lane_debug_id = p.Parent:GetDebugId() .. ":" .. p.Value:GetDebugId()

				if not find(exists, lane_debug_id) then
					insert(self.lanes, mlane(p))
					insert(exists, lane_debug_id)
				else
					-- lane exists
					p:Destroy()
					print("Deleted duplicate lane")
				end
			end
		end
	end

	return ungrouped
end


function RN:FindGroup(lane)
	local first, last = lane[1], lane[2]
	
	local group = {lane}
	local fN = findLaneNeighbors(first)
	
	for _, nbr in ipairs(fN) do
		-- check if node family of this neigbor's next node contains current next node
		-- if so, lane is in same family
		if find(findLaneNeighbors(nbr.Value), last.Next) then
			insert(group, mlane(nbr))
		end
	end
	
	sortLanes(group)
	return group
end

function RN:MakeGroups()
	local used = {}
	
	for _, lane in pairs(self.lanes) do
		local first, last = lane[1], lane[2]
		
		if not find(used, lane.nxt) then		
			local groupsByOrient = {}
			local fN = findLaneNeighbors(first)
			
			for _, nbr in ipairs(fN) do
				-- sort lanes into groups by angle
				-- groups with same angle will be in same lane group (99.9% of cases, best method atm)
				local nbrlane = mlane(nbr)
				local ry = lane_ry(nbrlane)

				if not groupsByOrient[ry] then
					groupsByOrient[ry] = {}
				end
				insert(groupsByOrient[ry], nbrlane)

				insert(used, nbr)
			end

			for _, group in pairs(groupsByOrient) do
				sortLanes(group)
				group.id = group[1].nxt:GetDebugId()

				-- make middle curve
				local first = group[1].CF:Lerp(group[#group].CF, 0.5)
				local last = group[1].endCF:Lerp(group[#group].endCF, 0.5)
				group.curve = cfcurve(first, last)

				local width0 = 0
				for _, lane in ipairs(group) do
					width0 = width0 + lane[1].Size.X
				end
				local width1 = 0
				for _, lane in ipairs(group) do
					width1 = width1 + lane[2].Size.X
				end

				group.width = math.min(width0, width1)

				group.roadtype = "Default"
				for _, lane in ipairs(group) do
					if lane.roadtype and lane.roadtype ~= "Default" then
						group.roadtype = lane.roadtype
						break
					end
				end

				insert(self.lanegroups, group)
			end
			
			insert(used, lane.nxt)
			
		end
	end
end

local function v2s(v)
	local x, y, z = v.x, v.y, v.z
	x, y, z = math.floor(x/2), math.floor(y/2), math.floor(z/2)
	
	return ("%s:%s:%s"):format(x, y, z)
end

function RN:FindFullLines()
	-- finds all lines in network with no overlap
	
	local lines = {}
	for _, lane in ipairs(self.lanes) do
		local first, last = lane[1], lane[2]
		local flp = (first.CFrame - first.CFrame.RightVector * first.Size.X/2).p
		local frp = (first.CFrame + first.CFrame.RightVector * first.Size.X/2).p
		local llp = (last.CFrame - last.CFrame.RightVector * last.Size.X/2).p
		local lrp = (last.CFrame + last.CFrame.RightVector * last.Size.X/2).p
		
		for i, poses in ipairs({{flp, llp}, {frp, lrp}}) do	
			local fs, ls = v2s(poses[1]), v2s(poses[2])
			local id0, id1 = ("%s|%s"):format(fs, ls), ("%s|%s"):format(ls, fs)
			
			local eid
			if lines[id0] then
				eid = id0 
			elseif lines[id1] then
				eid = id1
			end
			
			local val ={
				["lane"] = lane,
				side = (i-1.5)*2,
				first = poses[1],
				last = poses[2]
			}

			local side = (i-1.5)*2
			
			if eid then
				table.insert(lines[eid], val)
				
				if lines[eid][1].lane.orient ~= lane.orient then
					lane.neighbor = lines[eid][1].lane
					lines[eid][1].lane.neighbor = lane
					
					lines[eid].samedir = false
				else
					lines[eid].samedir = true
				end
			else
				local list = {val}
				list.first = poses[1]
				list.last = poses[2]
				list.curve = (side==-1 and lane.lcurve()) or lane.rcurve()
				lines[id0] = list
				
			end
		end
	end
	
	return lines
end

function RN:ClearOldGroups()
	local gids = {}
	for _, group in ipairs(self.lanegroups) do
		table.insert(gids, group.id)
	end
	
	for _, f in ipairs(self.Parent:GetChildren()) do
		if not table.find(gids, f.Name) then
			f:Destroy()
		end
	end
end

function RN:FilterChanged()
	-- only render lanes with "LaneChanged" tag
	
	local i=1
	while i <= #self.lanegroups do
		local group = self.lanegroups[i]
		local keep = false
		for _, lane in ipairs(group) do
			if Updates.changed(lane.nxt) then
				keep = true
				break
			end
		end
		
		if keep then
			i = i + 1
		else
			table.remove(self.lanegroups, i)
		end
	end
end

function RN:RenderGroups(rtypes, cb)
	if cb then
		cb(0)
	end
	for idx, group in ipairs(self.lanegroups) do
		if self.Parent:FindFirstChild(group.id) then
			self.Parent[group.id]:Destroy()
		end
		local prnt = Instance.new("Folder", self.Parent)
		prnt.Name = group.id
		
		Lane.DrawLaneGroup(group, prnt, self.rcfg, rtypes)
		
		if cb then
			cb(idx/#self.lanegroups)
		end
		
		wait()
	end
	if cb then
		cb(1)
	end
end

---------
return RN