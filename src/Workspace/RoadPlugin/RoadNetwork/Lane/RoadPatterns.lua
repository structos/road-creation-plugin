local RP = {}

RP.LineWidth = .33

local function reverse(t)
	for i = 1, math.floor(#t/2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
	
	return t
end

local function width(line)
	local w = 0
	for _, s in ipairs(line) do
		w = w + s[2]
	end
	return w
end

local function lines(samedir, lchange, edge)
	-- returns line widths from color and lane change
	
	local c = (samedir or edge) and "WhiteLine" or "YellowLine"
	
	if lchange then
		return {
			{c, RP.LineWidth/2}
		}
	else
		if samedir then
			return {
				{c, RP.LineWidth/2}
			}
		else
			return {
				{"Asphalt", (edge and RP.LineWidth or RP.LineWidth/2)},
				{c, RP.LineWidth}
			}
		end
	end
end


local function newlines(str, lwoverride)
	local cols = {
		W = "WhiteLine",
		Y = "YellowLine",
		A = "Asphalt"
	}
	
	local mod = 1
	if lwoverride then
		mod = 1/RP.LineWidth
	end
	
	
	local items = str:split(";")
	local pattern0, pattern1 = {}, {}
	
	local dashed = false
	
	for _, item in ipairs(items) do
		local pure_item, _ = item:gsub("%(", "")
		pure_item, _ = pure_item:gsub("%)", "")
		
		if item:find("%(") then
			dashed = true
		end
		
		local col = pure_item:sub(-1, -1)
		local width = tonumber(pure_item:sub(1, -2))
		
		if cols[col] and width then
			table.insert(pattern0, {cols[col], RP.LineWidth*width*mod})
			if not dashed then
				table.insert(pattern1, {cols[col], RP.LineWidth*width*mod})
			end
			
			if item:find("%)") then
				dashed = false
			end
		end
	end
	
	return pattern0, pattern1
end

RP.Lines = newlines


function RP.LanePattern(defleft, defright, customleft, customright)
	-- change lane config into road pattern
	
	local left0, left1 = newlines(customleft or defleft)
	local right0, right1 = newlines(customright or defright)
	
	return {
		{left0, right0},
		{left1, right1}
	}
end

return RP