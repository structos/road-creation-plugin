local Updates = require(script.Parent.LaneUpdates)
local RoadTypes = require(script.Parent.RoadNetwork.RoadTypes)

local PseudoInstance = require(script.PseudoInstance)
local Enumeration = require(script.Enumeration)
local Color = require(script.Color)

local TPrompt = require(script.TexturePrompt)
local CPrompt = require(script.ColorPrompt)

local REditor = {}
REditor.__index = REditor

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

function REditor.new(parent, rtypes, reftype, rtp)
    local self = setmetatable({}, REditor)

    self.gui = script.RoadEditor:Clone()
    self.gui.Parent = parent

    self.rtypes = rtypes
    self.ref = reftype
    self.rtp = rtp

    self.dropdown_open = false

    self.vals = rtypes:Get()[reftype]
    if not self.vals.Default then
        --self.vals = RoadTypes.Load(self.vals)
    end
    self.vals = RoadTypes.FillDefaults(self.vals)

    if not self.vals.Default then
        self.gui.SavePreset.name.Text = reftype
    end

    self.vals.Default = false

    self:init()

    return self
end

function REditor:init()
    -- make texture editors
    local function handleTexture(frame)
        local img = frame.TPreview.ImageButton

        local mat = self.vals[frame.Name]

        img.Image = mat.TextureID or ""
        img.ImageColor3 = mat.TextureColor
        img.ImageTransparency = mat.TextureTransparency
        img.TileSize = UDim2.new(0, 75*(mat.TextureSize.U/2), 0, 75*(mat.TextureSize.V/2))

        img.MouseButton1Click:Connect(function()
            local prompt = TPrompt.Prompt({
                Texture = mat.TextureID,
                ["Color3"] = mat.TextureColor,
                Transparency = mat.TextureTransparency,
                StudsPerTileU = mat.TextureSize.U,
                StudsPerTileV = mat.TextureSize.V
            }, function(props)
                img.Image = props.Texture
                img.ImageColor3 = props.Color3
                img.ImageTransparency = props.Transparency
                img.TileSize = UDim2.new(0, 75*(props.StudsPerTileU/2), 0, 75*(props.StudsPerTileV/2))

                self.vals[frame.Name].TextureID = props.Texture
                self.vals[frame.Name].TextureColor = props.Color3
                self.vals[frame.Name].TextureTransparency = props.Transparency
                self.vals[frame.Name].TextureSize = {
                    U = props.StudsPerTileU,
                    V = props.StudsPerTileV
                }
            end)
        end)
    end

    for _, mtype in ipairs({"Asphalt", "WhiteLine", "YellowLine"}) do
        handleTexture(self.gui[mtype])
    end
    -- / -

    -- custom texture checkbox for asphalt material

    self.asphalt_custom = self.vals.Asphalt.TextureID ~= nil
    self.gui.Asphalt.TPreview.Visible = self.asphalt_custom

    local CT = PseudoInstance.new("Checkbox")
    CT.Parent = self.gui.Asphalt.CustomTexture
	CT.Checked = self.asphalt_custom
	CT.OnChecked:Connect(function()
        self.asphalt_custom = not self.asphalt_custom
        self.gui.Asphalt.TPreview.Visible = self.asphalt_custom
	end)
	CT.Theme = Enumeration.MaterialTheme.Dark
    CT.PrimaryColor3 = Color.Yellow[600]

    -- color picker

    self.gui.Asphalt.PartColor.btn.BackgroundColor3 = self.vals.Asphalt.Color or Color3.new(1, 1, 1)


    self.gui.Asphalt.PartColor.btn.MouseButton1Click:Connect(function()
        local prompt = CPrompt.Prompt(self.vals.Asphalt.Color or Color3.new(1, 1, 1), function(col)
            self.gui.Asphalt.PartColor.btn.BackgroundColor3 = col
            self.vals.Asphalt.Color = col
        end)
    end)

    -- material input
    
    local mat_enums = {}
    for _, ei in ipairs(Enum.Material:GetEnumItems()) do
        mat_enums[ei.Name:lower()] = ei
    end

    local matinp = self.gui.Asphalt.PartMat.inp

    matinp.Text = self.vals.Asphalt.Material.Name or "Concrete"
    matinp.InputEnded:Connect(function(enter)
        -- check if entered material exists
        if mat_enums[matinp.Text:lower()] then
            self.vals.Asphalt.Material = mat_enums[matinp.Text:lower()]
            matinp.Text = mat_enums[matinp.Text:lower()].Name
        else
            matinp.Text = self.vals.Asphalt.Material.Name
        end
    end)
 
    -- saving

    local save = self.gui.SavePreset

    local function namevalid(s)
        if not s then
            return false, "nil"
        end

        if #s == 0 then
            return false, "short"
        end

        local alltypes = self.rtypes:Get()
        if alltypes[s] and alltypes[s].Default then
            return false, "exists"
        end

        return true, nil
    end

    save.name.Changed:Connect(function()
        local valid, err = namevalid(save.name.Text)
        self.gui.nope.Visible = err == "exists"
        save.submit.Visible = valid
    end)

    save.submit.MouseButton1Click:Connect(function()
        local svals = deepCopy(self.vals)

        if not self.asphalt_custom then
            svals.Asphalt.TextureID = nil
        end
        
        self.rtypes:Save(save.name.Text, deepCopy(svals))

        -- mark for re-render
        for _, nxt in ipairs(workspace:GetDescendants()) do
            if nxt:IsA("ObjectValue") and nxt.Name == "Next" and nxt.Value ~= nil then
                if nxt:FindFirstChild("RoadType") and nxt.RoadType.Value == save.name.Text then
                    Updates.tag(nxt)
                end
            end
        end

        self.rtp:safeSelect(save.name.Text)

        self.gui.yep.Visible = true
        wait(3)
        self.gui.yep.Visible = false
    end)
    
    --/--

    self.gui.title.back.MouseButton1Click:Connect(function()
        self.gui:Destroy()
    end)
end

function REditor:close()
    self.gui:Destroy()
end






----------
return REditor