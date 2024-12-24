---@class uuPrivate
local private = select(2, ...)

---@class uuFrames
local frames = private.frame

local resourceOverrides = {}
resourceOverrides[Enum.PowerType.Mana] = {
    r = 0x4d / 0xff,
    g = 0x80 / 0xff,
    b = 0xd9 / 0xff
}

---@param parent Frame
---@param unit UnitToken
---@param resourceIndex number
---@return StatusBar
function frames.simpleResource(parent, unit, resourceIndex)
    local primaryResourceFrame = CreateFrame("StatusBar", parent:GetName() .. 'Power' .. resourceIndex, parent)
    primaryResourceFrame:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 0, -1)
    primaryResourceFrame:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, -3)
    primaryResourceFrame:SetStatusBarTexture('interface/buttons/white8x8')
    primaryResourceFrame:SetStatusBarColor(0.9, 0.9, 0.9, 0.9)
    primaryResourceFrame:Show()
    primaryResourceFrame:SetMinMaxValues(0, 100)
    primaryResourceFrame:SetValue(100)

    primaryResourceFrame:RegisterUnitEvent('UNIT_POWER_UPDATE', unit)
    primaryResourceFrame:RegisterUnitEvent('UNIT_POWER_FREQUENT', unit)
    primaryResourceFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    local lastKnownPowerType = nil
    primaryResourceFrame:SetScript('OnEvent', function(self, eventType)
        if lastKnownPowerType == nil or eventType == 'UNIT_POWER_UPDATE' or eventType == 'PLAYER_ENTERING_WORLD' then
            local newPowerType, slug, altR, altG, altB = UnitPowerType(unit, resourceIndex)

            if newPowerType ~= lastKnownPowerType then
                lastKnownPowerType = newPowerType
                local color = resourceOverrides[newPowerType] or PowerBarColor[slug]
                self:SetStatusBarColor(altR or color.r, altG or color.g, altB or color.b, 0.9)
            end
        end

        if lastKnownPowerType ~= nil then
            local max = UnitPowerMax(unit, lastKnownPowerType, true)
            self:SetMinMaxValues(0, max)
            local power = UnitPower(unit, lastKnownPowerType, true)
            self:SetValue(power)
        end
    end)

    return primaryResourceFrame
end