local addonName, private = ...

---@class uuFrames
local frames = private.frame

---comment
---@param parent Frame
---@param unit UnitToken
---@return Frame
function frames.healAbsorb(parent, unit)
    local absorb = CreateFrame('StatusBar', parent:GetName() .. 'HealAbsorb', parent)
    absorb:SetFrameStrata("BACKGROUND")
    absorb:SetAllPoints()

    private.util.addResizeHandler(function(top, bottom)
        PixelUtil.SetPoint(absorb, 'TOPLEFT', top, 'TOPLEFT', -4, 4)
        PixelUtil.SetPoint(absorb, 'BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', 4, -4)
    end)

    absorb:SetStatusBarTexture('interface/buttons/white8x8')
    absorb:SetStatusBarColor(0x92 / 0xff, 0x70 / 0xff, 0xdb / 0xff, 0.9)
    absorb:SetMinMaxValues(0, 100)
    absorb:SetReverseFill(true)
    absorb:SetValue(0)
    absorb:Show()

    local absorbMaxHp, absorbAmount = nil, nil
    absorb:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
    absorb:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    absorb:RegisterEvent('PLAYER_ENTERING_WORLD')
    absorb:SetScript("OnEvent", function(self, eventType)
        local oldAbsorb = absorbAmount
        local updateScale = false
        if eventType == 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED' or eventType == 'PLAYER_ENTERING_WORLD' then
            if absorbMaxHp == nil then
                updateScale = true
                absorbMaxHp = UnitHealthMax(unit)
            end
            absorbAmount = UnitGetTotalHealAbsorbs(unit)
        elseif eventType == 'UNIT_MAXHEALTH' then
            absorbMaxHp = UnitHealthMax(unit)
            absorbAmount = UnitGetTotalHealAbsorbs(unit)
            updateScale = true
        end
    
        if updateScale then
            self:SetMinMaxValues(0, absorbMaxHp)
        end
        self:SetValue(absorbAmount)
    end)
    
    return absorb
end