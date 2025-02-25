local RT = {}

local ASPH = "rbxassetid://4627913212"
local CONCR = "rbxassetid://288525813"

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == "table" then
            v = deepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

local function rgb2hex(rgb)
    rgb = {
        math.floor(rgb.r*255),
        math.floor(rgb.g*255),
        math.floor(rgb.b*255)
    }
	local hexadecimal = ''

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(#hex == 0)then
			hex = '00'

		elseif(#hex == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

local function hex2rgb(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

function RT.FillDefaults(roadtype)
    roadtype = deepCopy(roadtype)

    for k, v in pairs(roadtype) do
        if type(v) == "table" then
            if not v.TextureSize then
                v.TextureSize = {U=2, V=2}
            end

            if not v.Color then
                v.Color = Color3.new(1, 1, 1)
            end

            if not v.TextureColor then
                v.TextureColor = Color3.new(1, 1, 1)
            end

            if not v.TextureTransparency then
                v.TextureTransparency = 0
            end

            if not v.Material then
                v.Material = Enum.Material.Concrete
            end
        end
    end

    return roadtype
end

function RT.Saveable(rt)
    rt = deepCopy(rt)

    for k, v in pairs(rt) do
        if type(v) == "table" then
            if v.Color then
                v.Color = rgb2hex(v.Color)
            end

            if v.TextureColor then
                v.TextureColor = rgb2hex(v.TextureColor)
            end
            
            if v.Material then
                v.Material = v.Material.Name
            end
        end
    end

    return rt
end

function RT.Load(rt)
    rt = deepCopy(rt)

    for k, v in pairs(rt) do
        if type(v) == "table" then
            if v.Color then
                v.Color = hex2rgb(v.Color)
            end

            if v.TextureColor then
                v.TextureColor = hex2rgb(v.TextureColor)
            end

            if v.Material then
                v.Material = Enum.Material[v.Material]
            end
        end
    end

    return rt
end

RT.Default = RT.FillDefaults({
    Default = true,
    Asphalt = {
        TextureID = ASPH,
        Color = Color3.fromRGB(99, 95, 98)
    },
    WhiteLine = {
        TextureID = CONCR,
        TextureColor = Color3.new(1, 1, 1)
    },
    YellowLine = {
        TextureID = CONCR,
        TextureColor = Color3.fromRGB(245, 205, 48)
    }
})

RT.Concrete = RT.FillDefaults({
    Default = true,
    Asphalt = {
        TextureID = "rbxassetid://4911798855"
    },
    WhiteLine = {
        TextureID = CONCR,
        TextureColor = Color3.new(1, 1, 1)
    },
    YellowLine = {
        TextureID = CONCR,
        TextureColor = Color3.fromRGB(245, 205, 48)
    }
})

RT.All = {
    Default = RT.Default,
    Concrete = RT.Concrete
}



---------
return RT