---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

function custom.holyPower(parent, unit)
    local interior = private.frame.simpleResource(parent, unit, Enum.PowerType.HolyPower)
    local max = UnitPowerMax(unit, Enum.PowerType.HolyPower)

    local line = interior:CreateTexture(interior:GetName() .. '3line', 'OVERLAY')
    line:SetTexture('interface/buttons/white8x8')
    line:SetVertexColor(0, 0, 0, 1)
    local left = 3 / max * interior:GetWidth()
    PixelUtil.SetPoint(line, 'TOPLEFT', interior, 'TOPLEFT', left, 0)
    PixelUtil.SetPoint(line, 'BOTTOMRIGHT', interior, 'BOTTOMLEFT', left + 3, 0)

    local frame = CreateFrame('Frame')
    frame:SetScript('OnEvent', function(self, eventName, target, powerType)
        if powerType == 'HOLY_POWER' then
            local max = UnitPowerMax(unit, Enum.PowerType.HolyPower)
            local left = 3 / max * interior:GetWidth()
            PixelUtil.SetPoint(line, 'TOPLEFT', interior, 'TOPLEFT', left, 0)
            PixelUtil.SetPoint(line, 'BOTTOMRIGHT', interior, 'BOTTOMLEFT', left + 3, 0)
        end
    end)
    frame:RegisterUnitEvent('UNIT_MAXPOWER', unit)
    return interior
end