local Bezier = require(script.Bezier)

local function cfcurve(cf0, cf1)
	local dist = (cf1.p - cf0.p).Magnitude
	
	local ttheta = math.acos(cf0.LookVector:Dot(cf1.LookVector))
	local cosa = math.cos(ttheta/2)
	
	if math.abs((cf0.LookVector - cf1.LookVector).Magnitude) < .05 then
		cosa = 1
	end
	
	local d = dist/(2*cosa + 1)
	
	local p0 = cf0.p
	local p1 = cf0.p + cf0.LookVector*d
	local p2 = cf1.p - cf1.LookVector*d
	local p3 = cf1.p
	
	return Bezier.new({p0, p1, p2, p3})
end  

return cfcurve