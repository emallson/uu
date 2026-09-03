---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

function custom.chargeResource(parent, unit, resourceType, resourceToken, tickMarkCount, specIndexWhitelist, stack)
    local interior = private.frame.simpleResource(parent, unit, resourceType)
    local max = UnitPowerMax(unit, resourceType)

    local line = interior:CreateTexture(interior:GetName() .. '3line', 'OVERLAY')
    line:SetTexture('interface/buttons/white8x8')
    line:SetVertexColor(0, 0, 0, 1)
    local left = tickMarkCount / max * interior:GetWidth()
    PixelUtil.SetPoint(line, 'TOPLEFT', interior, 'TOPLEFT', left, 0)
    PixelUtil.SetPoint(line, 'BOTTOMRIGHT', interior, 'BOTTOMLEFT', left + 3, 0)

    local function checkVisibility()
        local hasPowerType = specIndexWhitelist == nil or specIndexWhitelist[C_SpecializationInfo.GetSpecialization()]
        if hasPowerType then
            interior:Show()
            private.util.rescaleBg(stack)
        else
            interior:Hide()
            private.util.rescaleBg(stack)
        end
    end

    local frame = CreateFrame('Frame')
    frame:SetScript('OnEvent', function(self, eventName, target, powerType)
        if eventName == 'PLAYER_SPECIALIZATION_CHANGED' then
            checkVisibility()
        elseif eventName == 'UNIT_MAXPOWER' and not InCombatLockdown() then
            if powerType == resourceToken then
                local max = UnitPowerMax(unit, resourceType)
                local left = tickMarkCount / max * interior:GetWidth()
                PixelUtil.SetPoint(line, 'TOPLEFT', interior, 'TOPLEFT', left, 0)
                PixelUtil.SetPoint(line, 'BOTTOMRIGHT', interior, 'BOTTOMLEFT', left + 3, 0)
            end
        end
    end)
    frame:RegisterUnitEvent('UNIT_MAXPOWER', unit)
    frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
    checkVisibility()
    return interior
end