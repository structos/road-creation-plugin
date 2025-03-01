-- Color utilities with Material Design's 2014 Color Palette
-- @documentation https://rostrap.github.io/Libraries/RoStrapUI/Color/
-- @source https://raw.githubusercontent.com/RoStrap/RoStrapUI/master/Color.lua
-- @rostrap Color
-- @author Validark


local function _Load_Library_(Name)
	return require(script.Parent[Name])
end
local Table = _Load_Library_("Table")

local rgb = Color3.fromRGB

local Color = {
	Red = {
		[50] = rgb(255, 235, 238);
		[100] = rgb(255, 205, 210);
		[200] = rgb(239, 154, 154);
		[300] = rgb(229, 115, 115);
		[400] = rgb(239, 83, 80);
		[500] = rgb(244, 67, 54);
		[600] = rgb(229, 57, 53);
		[700] = rgb(211, 47, 47);
		[800] = rgb(198, 40, 40);
		[900] = rgb(183, 28, 28);

		Accent = {
			[100] = rgb(255, 138, 128);
			[200] = rgb(255, 82, 82);
			[400] = rgb(255, 23, 68);
			[700] = rgb(213, 0, 0);
		};
	};

	Pink = {
		[50] = rgb(252, 228, 236);
		[100] = rgb(248, 187, 208);
		[200] = rgb(244, 143, 177);
		[300] = rgb(240, 98, 146);
		[400] = rgb(236, 64, 122);
		[500] = rgb(233, 30, 99);
		[600] = rgb(216, 27, 96);
		[700] = rgb(194, 24, 91);
		[800] = rgb(173, 20, 87);
		[900] = rgb(136, 14, 79);

		Accent = {
			[100] = rgb(255, 128, 171);
			[200] = rgb(255, 64, 129);
			[400] = rgb(245, 0, 87);
			[700] = rgb(197, 17, 98);
		};
	};

	Purple = {
		[50] = rgb(243, 229, 245);
		[100] = rgb(225, 190, 231);
		[200] = rgb(206, 147, 216);
		[300] = rgb(186, 104, 200);
		[400] = rgb(171, 71, 188);
		[500] = rgb(156, 39, 176);
		[600] = rgb(142, 36, 170);
		[700] = rgb(123, 31, 162);
		[800] = rgb(106, 27, 154);
		[900] = rgb(74, 20, 140);

		Accent = {
			[100] = rgb(234, 128, 252);
			[200] = rgb(224, 64, 251);
			[400] = rgb(213, 0, 249);
			[700] = rgb(170, 0, 255);
		};
	};

	DeepPurple = {
		[50] = rgb(237, 231, 246);
		[100] = rgb(209, 196, 233);
		[200] = rgb(179, 157, 219);
		[300] = rgb(149, 117, 205);
		[400] = rgb(126, 87, 194);
		[500] = rgb(103, 58, 183);
		[600] = rgb(94, 53, 177);
		[700] = rgb(81, 45, 168);
		[800] = rgb(69, 39, 160);
		[900] = rgb(49, 27, 146);

		Accent = {
			[100] = rgb(179, 136, 255);
			[200] = rgb(124, 77, 255);
			[400] = rgb(101, 31, 255);
			[700] = rgb(98, 0, 234);
		};
	};

	Indigo = {
		[50] = rgb(232, 234, 246);
		[100] = rgb(197, 202, 233);
		[200] = rgb(159, 168, 218);
		[300] = rgb(121, 134, 203);
		[400] = rgb(92, 107, 192);
		[500] = rgb(63, 81, 181);
		[600] = rgb(57, 73, 171);
		[700] = rgb(48, 63, 159);
		[800] = rgb(40, 53, 147);
		[900] = rgb(26, 35, 126);

		Accent = {
			[100] = rgb(140, 158, 255);
			[200] = rgb(83, 109, 254);
			[400] = rgb(61, 90, 254);
			[700] = rgb(48, 79, 254);
		};
	};

	Blue = {
		[50] = rgb(227, 242, 253);
		[100] = rgb(187, 222, 251);
		[200] = rgb(144, 202, 249);
		[300] = rgb(100, 181, 246);
		[400] = rgb(66, 165, 245);
		[500] = rgb(33, 150, 243);
		[600] = rgb(30, 136, 229);
		[700] = rgb(25, 118, 210);
		[800] = rgb(21, 101, 192);
		[900] = rgb(13, 71, 161);

		Accent = {
			[100] = rgb(130, 177, 255);
			[200] = rgb(68, 138, 255);
			[400] = rgb(41, 121, 255);
			[700] = rgb(41, 98, 255);
		};
	};

	LightBlue = {
		[50] = rgb(225, 245, 254);
		[100] = rgb(179, 229, 252);
		[200] = rgb(129, 212, 250);
		[300] = rgb(79, 195, 247);
		[400] = rgb(41, 182, 246);
		[500] = rgb(3, 169, 244);
		[600] = rgb(3, 155, 229);
		[700] = rgb(2, 136, 209);
		[800] = rgb(2, 119, 189);
		[900] = rgb(1, 87, 155);

		Accent = {
			[100] = rgb(128, 216, 255);
			[200] = rgb(64, 196, 255);
			[400] = rgb(0, 176, 255);
			[700] = rgb(0, 145, 234);
		};
	};

	Cyan = {
		[50] = rgb(224, 247, 250);
		[100] = rgb(178, 235, 242);
		[200] = rgb(128, 222, 234);
		[300] = rgb(77, 208, 225);
		[400] = rgb(38, 198, 218);
		[500] = rgb(0, 188, 212);
		[600] = rgb(0, 172, 193);
		[700] = rgb(0, 151, 167);
		[800] = rgb(0, 131, 143);
		[900] = rgb(0, 96, 100);

		Accent = {
			[100] = rgb(132, 255, 255);
			[200] = rgb(24, 255, 255);
			[400] = rgb(0, 229, 255);
			[700] = rgb(0, 184, 212);
		};
	};

	Teal = {
		[50] = rgb(224, 242, 241);
		[100] = rgb(178, 223, 219);
		[200] = rgb(128, 203, 196);
		[300] = rgb(77, 182, 172);
		[400] = rgb(38, 166, 154);
		[500] = rgb(0, 150, 136);
		[600] = rgb(0, 137, 123);
		[700] = rgb(0, 121, 107);
		[800] = rgb(0, 105, 92);
		[900] = rgb(0, 77, 64);

		Accent = {
			[100] = rgb(167, 255, 235);
			[200] = rgb(100, 255, 218);
			[400] = rgb(29, 233, 182);
			[700] = rgb(0, 191, 165);
		};
	};

	Green = {
		[50] = rgb(232, 245, 233);
		[100] = rgb(200, 230, 201);
		[200] = rgb(165, 214, 167);
		[300] = rgb(129, 199, 132);
		[400] = rgb(102, 187, 106);
		[500] = rgb(76, 175, 80);
		[600] = rgb(67, 160, 71);
		[700] = rgb(56, 142, 60);
		[800] = rgb(46, 125, 50);
		[900] = rgb(27, 94, 32);

		Accent = {
			[100] = rgb(185, 246, 202);
			[200] = rgb(105, 240, 174);
			[400] = rgb(0, 230, 118);
			[700] = rgb(0, 200, 83);
		};
	};

	LightGreen = {
		[50] = rgb(241, 248, 233);
		[100] = rgb(220, 237, 200);
		[200] = rgb(197, 225, 165);
		[300] = rgb(174, 213, 129);
		[400] = rgb(156, 204, 101);
		[500] = rgb(139, 195, 74);
		[600] = rgb(124, 179, 66);
		[700] = rgb(104, 159, 56);
		[800] = rgb(85, 139, 47);
		[900] = rgb(51, 105, 30);

		Accent = {
			[100] = rgb(204, 255, 144);
			[200] = rgb(178, 255, 89);
			[400] = rgb(118, 255, 3);
			[700] = rgb(100, 221, 23);
		};
	};

	Lime = {
		[50] = rgb(249, 251, 231);
		[100] = rgb(240, 244, 195);
		[200] = rgb(230, 238, 156);
		[300] = rgb(220, 231, 117);
		[400] = rgb(212, 225, 87);
		[500] = rgb(205, 220, 57);
		[600] = rgb(192, 202, 51);
		[700] = rgb(175, 180, 43);
		[800] = rgb(158, 157, 36);
		[900] = rgb(130, 119, 23);

		Accent = {
			[100] = rgb(244, 255, 129);
			[200] = rgb(238, 255, 65);
			[400] = rgb(198, 255, 0);
			[700] = rgb(174, 234, 0);
		};
	};

	Yellow = {
		[50] = rgb(255, 253, 231);
		[100] = rgb(255, 249, 196);
		[200] = rgb(255, 245, 157);
		[300] = rgb(255, 241, 118);
		[400] = rgb(255, 238, 88);
		[500] = rgb(255, 235, 59);
		[600] = rgb(253, 216, 53);
		[700] = rgb(251, 192, 45);
		[800] = rgb(249, 168, 37);
		[900] = rgb(245, 127, 23);

		Accent = {
			[100] = rgb(255, 255, 141);
			[200] = rgb(255, 255, 0);
			[400] = rgb(255, 234, 0);
			[700] = rgb(255, 214, 0);
		};
	};

	Amber = {
		[50] = rgb(255, 248, 225);
		[100] = rgb(255, 236, 179);
		[200] = rgb(255, 224, 130);
		[300] = rgb(255, 213, 79);
		[400] = rgb(255, 202, 40);
		[500] = rgb(255, 193, 7);
		[600] = rgb(255, 179, 0);
		[700] = rgb(255, 160, 0);
		[800] = rgb(255, 143, 0);
		[900] = rgb(255, 111, 0);

		Accent = {
			[100] = rgb(255, 229, 127);
			[200] = rgb(255, 215, 64);
			[400] = rgb(255, 196, 0);
			[700] = rgb(255, 171, 0);
		};
	};

	Orange = {
		[50] = rgb(255, 243, 224);
		[100] = rgb(255, 224, 178);
		[200] = rgb(255, 204, 128);
		[300] = rgb(255, 183, 77);
		[400] = rgb(255, 167, 38);
		[500] = rgb(255, 152, 0);
		[600] = rgb(251, 140, 0);
		[700] = rgb(245, 124, 0);
		[800] = rgb(239, 108, 0);
		[900] = rgb(230, 81, 0);

		Accent = {
			[100] = rgb(255, 209, 128);
			[200] = rgb(255, 171, 64);
			[400] = rgb(255, 145, 0);
			[700] = rgb(255, 109, 0);
		};
	};

	DeepOrange = {
		[50] = rgb(251, 233, 231);
		[100] = rgb(255, 204, 188);
		[200] = rgb(255, 171, 145);
		[300] = rgb(255, 138, 101);
		[400] = rgb(255, 112, 67);
		[500] = rgb(255, 87, 34);
		[600] = rgb(244, 81, 30);
		[700] = rgb(230, 74, 25);
		[800] = rgb(216, 67, 21);
		[900] = rgb(191, 54, 12);

		Accent = {
			[100] = rgb(255, 158, 128);
			[200] = rgb(255, 110, 64);
			[400] = rgb(255, 61, 0);
			[700] = rgb(221, 44, 0);
		};
	};

	Brown = {
		[50] = rgb(239, 235, 233);
		[100] = rgb(215, 204, 200);
		[200] = rgb(188, 170, 164);
		[300] = rgb(161, 136, 127);
		[400] = rgb(141, 110, 99);
		[500] = rgb(121, 85, 72);
		[600] = rgb(109, 76, 65);
		[700] = rgb(93, 64, 55);
		[800] = rgb(78, 52, 46);
		[900] = rgb(62, 39, 35);
	};

	Grey = {
		[50] = rgb(250, 250, 250);
		[100] = rgb(245, 245, 245);
		[200] = rgb(238, 238, 238);
		[300] = rgb(224, 224, 224);
		[400] = rgb(189, 189, 189);
		[500] = rgb(158, 158, 158);
		[600] = rgb(117, 117, 117);
		[700] = rgb(97, 97, 97);
		[800] = rgb(66, 66, 66);
		[900] = rgb(33, 33, 33);
	};

	BlueGrey = {
		[50] = rgb(236, 239, 241);
		[100] = rgb(207, 216, 220);
		[200] = rgb(176, 190, 197);
		[300] = rgb(144, 164, 174);
		[400] = rgb(120, 144, 156);
		[500] = rgb(96, 125, 139);
		[600] = rgb(84, 110, 122);
		[700] = rgb(69, 90, 100);
		[800] = rgb(55, 71, 79);
		[900] = rgb(38, 50, 56);
	};

	Black = rgb(0, 0, 0);
	White = rgb(255, 255, 255);
}

function Color.toRGBString(c, a)
	local r = c.r * 255 + 0.5
	local g = c.g * 255 + 0.5
	local b = c.b * 255 + 0.5

	if a then
		return ("rgba(%u, %u, %u, %u)"):format(r, g, b, a * 255 + 0.5)
	else
		return ("rgb(%u, %u, %u)"):format(r, g, b)
	end
end
Color.ToRGBString = Color.toRGBString

function Color.toHexString(c, a)
	local r = c.r * 255 + 0.5
	local g = c.g * 255 + 0.5
	local b = c.b * 255 + 0.5

	if a then
		return ("#%X%X%X%X"):format(r, g, b, a * 255 + 0.5)
	else
		return ("#%X%X%X"):format(r, g, b)
	end
end
Color.ToHexString = Color.toHexString

local Hash = ("#"):byte()

function Color.fromHex(Hex)
	-- Converts a 3-digit or 6-digit hex color to RGB
	-- Takes in a string of the form: "#FFFFFF" or "#FFF" or a 6-digit hexadecimal number

	local Type = type(Hex)
	local Digits

	if Type == "string" then
		if Hex:byte() == Hash then Hex = Hex:sub(2) end -- Remove # from beginning

		Digits = #Hex

		if Digits == 8 then -- We got some alpha :D
			return Color.fromHex(Hex:sub(1, -3)), tonumber(Hex, 16) % 0x000100 / 255
		end

		Hex = tonumber(Hex, 16) -- Leverage Lua's base converter :D
	elseif Type == "number" then
		Digits = 6 -- Assume numbers are 6 digit hex numbers
	end

	if Digits == 6 then
		-- Isolate R as first digits 5 and 6, G as 3 and 4, B as 1 and 2

		local R = (Hex - Hex % 0x010000) / 0x010000
		Hex = Hex - R * 0x010000
		local G = (Hex - Hex % 0x000100) / 0x000100

		return rgb(R, G, Hex - G * 0x000100)
	elseif Digits == 3 then
		-- 3-digit to 6-digit conversion: 123 -> 112233
		-- Thus, we isolate each digits' value and multiply by 17

		local R = (Hex - Hex % 0x100) / 0x100
		Hex = Hex - R * 0x100
		local G = (Hex - Hex % 0x10) / 0x10

		return rgb(R * 0x11, G * 0x11, (Hex - G * 0x10) * 0x11)
	end
end
Color.FromHex = Color.fromHex

local floor = math.floor

function Color.toHex(Color3)
	return floor(Color3.r * 0xFF + 0.5) * 0x010000 +  floor(Color3.g * 0xFF + 0.5) * 0x000100 + floor(Color3.b * 0xFF + 0.5) * 0x000001
end
Color.ToHex = Color.toHex

return Table.Lock(Color)
