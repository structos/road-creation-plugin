local Updates = require(script.Parent.LaneUpdates)
local RoadEditor = require(script.Parent.RoadEditor)

local RTP = {}
RTP.__index = RTP

function RTP.new(group, parent, rtypes)
    local self = setmetatable({}, RTP)

    self.gui = script.RTypePicker:Clone()
    self.gui.Parent = parent

    self.group = group

    self.current_type = group.roadtype or "Default"
    self.types_list = rtypes:Get()

    self.rtypes = rtypes

    self.dropdown_open = false

    self:init()

    return self
end

function RTP:close()
    self.gui:Destroy()
end

function RTP:closedrop()
    self.dropdown_open = false
    self.gui.LoadPreset.Visible = false
    self.gui.PresetBtns.drop.Rotation = 0
end

function RTP:select(name)
    self.current_type = name
    self.gui.PresetBtns.name.Text = self.current_type

    print(name)

    for _, lane in ipairs(self.group) do
        local nxt = lane.nxt
        local val = nxt:FindFirstChild("RoadType")
        if not val then
            val = Instance.new("StringValue", nxt)
            val.Name = "RoadType"
        end

        val.Value = name

        Updates.tag(nxt)
    end

    self.group.roadtype = name
end

function RTP:safeSelect(name)
    for _, lane in ipairs(self.group) do
        local nxt = lane.nxt
        local val = nxt:FindFirstChild("RoadType")
        if not val then
            val = Instance.new("StringValue", nxt)
            val.Name = "RoadType"
        end

        val.Value = name

        Updates.tag(nxt)
    end

    self.group.roadtype = name
end

function RTP:init()
    local PresetBtns = self.gui.PresetBtns
    local LoadPreset = self.gui.LoadPreset
    local scroll = LoadPreset.scroll

    PresetBtns.name.Text = self.current_type

    for k, v in pairs(self.types_list) do
        local btn = scroll.Template:Clone()
        btn.Name = "btn"
        btn.Parent = scroll
        btn.Text = k
        btn.Visible = true

        btn.MouseButton1Click:Connect(function()
            self:select(k)
            self:closedrop()
        end)
    end

    scroll.CanvasSize = UDim2.new(1, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y)

    PresetBtns.drop.MouseButton1Click:Connect(function()
        self.dropdown_open = not self.dropdown_open
        LoadPreset.Visible = self.dropdown_open
        PresetBtns.drop.Rotation = (self.dropdown_open and 180) or 0
    end)

    self.gui.edit.MouseButton1Click:Connect(function()
        local re = RoadEditor.new(self.gui.Parent, self.rtypes, self.current_type, self)
        game.Selection:Set({})
    end)

    self.gui.Parent.Changed:Connect(function()
		self:UpdateSize()
    end)
    
    self:UpdateSize()
end

function RTP:UpdateSize()
	self.gui.Size = UDim2.new(1, 0, 1, -160)
end


----------
return RTP