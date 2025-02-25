local util = {}
function util.lerp(a, b, alph)
	return a:Lerp(b, alph)
end
function util.distance(a, b)
	return (b-a).Magnitude
end

-- Curve Class

local Curve = {}
Curve.__index = Curve

function Curve.new(points, cf)
	-- creates curve with optional list of points (Vector3, Vector2, or CFrames)
	
	local self = setmetatable({}, Curve)
	self.__Bezier = true
	
	-- cf = cf or CFrame.new()
	
	self.points = points or {}
	self.cf = cf
	if cf then
		for i=1, #self.points do
			self.points[i] = cf:PointToObjectSpace(self.points[i])
		end
	end
	
	self._dist_table = {resolution=0, points={}}
	
	return self
end

--

function Curve:ClearCache()
	self._dist_table = {resolution=0, points={}}
end

function Curve:AddPoint(p)
	self:ClearCache()	
	
	table.insert(self.points, p)
end

function Curve:AddPoints(pts)
	for _, p in ipairs(pts) do
		self:AddPoint(p)
	end
end

function Curve:RemovePoint(index)
	self:ClearCache()	
	
	local index = index or #self.points
	
	table.remove(self.points, index)
end

function Curve:NumPoints()
	-- returns number of points in curve
	
	return #self.points
end

function Curve.PointsFromParts(parts, sort)
	-- utility function returning a list of CFrames from a list of parts
	-- optional sort: sorts parts by name
	
	-- pre-sort table copy
	local parts = parts
	
	local sort = sort or false
	
	if sort then
		local function comp(a, b)
			return a.Name < b.Name
		end
		
		table.sort(parts, comp)
	end
	
	local points = {}
	
	for _, p in ipairs(parts) do
		table.insert(points, p.Position) -- position or cframe could work??
	end
	
	return points
end

--

function Curve:PointAtAlpha(alpha)
	-- returns point at alpha
	
	local points = self.points
	
	while #points > 1 do
		local ntb = {}
		
		for k, v in ipairs(points) do
			if k ~= 1 then
				ntb[k-1] = util.lerp(points[k-1], v, alpha)
			end
		end
		
		points = ntb
	end
	
	return points[1]
end 

-- fixed distances --
---------------------

function Curve:CalcDistances(res)
	-- calculate distances for res number of points
	
	local res = res or 100
	
	-- don't recalculate if not necessary
	if self._dist_table.resolution ~= res then
	
		-- print("calculating points/distance table")
	
		local da = 1/res -- delta alpha
		
		local pointsTable = {}
		local totalDist = 0
		
		local lastPoint = self:PointAtAlpha(0)
		
		-- set upper bound to 1+da to include alpha=1 in loop
		for a=0,1+da,da do
			local point = self:PointAtAlpha(a)
			local dist = util.distance(point, lastPoint)
			
			totalDist = totalDist + dist
			
			table.insert(pointsTable, {a, totalDist})
			
			lastPoint = point
		end
		
		self._dist_table = {["resolution"]=res, ["points"]=pointsTable}
	end
	
	return self._dist_table
end

function Curve:Length(res)
	-- calculate length of curve using res number of points (default 100)
	
	self:CalcDistances(res)
	
	return self._dist_table.points[#self._dist_table.points][2]
end

function Curve:AlphaAtDistance(d, res)
	-- returns alpha at specified distance
	-- optional: res- number of alpha points considered in calculation
	
	self:CalcDistances(res or 100)
	
	local points = self._dist_table.points -- shorthand
	
	local index = 1 -- store index for error correction
	
	-- find closest point to correct distance (always overshoots)
	for i, v in ipairs(points) do
		local alpha, dist = v[1], v[2]
		
		index = i
		
		if d < dist then
			break
		end
	end
	
	index = index-1	
	
	-- error correction
	
	-- error correction works by dividing the overshoot value between absolute distance to the next point
	-- then multiply by the difference in alpha
	
	local e = d - points[index][2] -- how much distance is left to go along curve
	local eP = e / (points[index+1][2] - points[index][2]) -- taking proportion of this to the distance to next point tells how much alpha to add
	
	local add_alpha = eP / self._dist_table.resolution
	
	return points[index][1]+add_alpha
end

function Curve:CFrameAtAlpha(alpha)
	return CFrame.new(self:PointAtAlpha(alpha), self:PointAtAlpha(alpha+.001))
end

function Curve:GetCFrameAt(distance, dAdjust)
	local add = 0.01
	
	local alpha = self:AlphaAtDistance(distance)
	local alpha2 = self:AlphaAtDistance(distance+add)
	
	local c = CFrame.new(self:PointAtAlpha(alpha), self:PointAtAlpha(alpha2))
	if self.cf and not dAdjust then
		c = self.cf * c
	end
	
	return c
end

------------
return Curve