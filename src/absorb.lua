local addonName, private = ...

---@class uuFrames
local frames = private.frame

---comment
---@param parent Frame
---@param unit UnitToken
---@return Frame
function frames.absorb(parent, unit)
    local absorb = CreateFrame('StatusBar', parent:GetName() .. 'Absorb', parent)
    absorb:SetFrameStrata("BACKGROUND")
    absorb:SetFrameLevel(100)
    absorb:SetAllPoints()

    private.util.addResizeHandler(function(top, bottom)
        PixelUtil.SetPoint(absorb, 'TOPLEFT', top, 'TOPLEFT', -2.5, 2.5)
        PixelUtil.SetPoint(absorb, 'BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', 2.5, -2.5)
    end)

    absorb:SetStatusBarTexture('interface/buttons/white8x8')
    absorb:SetStatusBarColor(255 / 255, 191 / 255, 45 / 255, 0.75)
    absorb:SetMinMaxValues(0, 100)
    absorb:SetValue(0)
    absorb:Show()
    
    absorb.animChunkFrame = frames.animatedChunkFrame(absorb)


    local absorbMaxHp, absorbAmount = nil, nil
    absorb:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
    absorb:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    absorb:RegisterEvent('PLAYER_ENTERING_WORLD')
    absorb:SetScript("OnEvent", function(self, eventType)
        local oldAbsorb = absorbAmount
        local updateScale = false
        if eventType == 'UNIT_ABSORB_AMOUNT_CHANGED' or eventType == 'PLAYER_ENTERING_WORLD' then
            if absorbMaxHp == nil then
                updateScale = true
                absorbMaxHp = UnitHealthMax(unit)
            end
            absorbAmount = UnitGetTotalAbsorbs(unit)
        elseif eventType == 'UNIT_MAXHEALTH' then
            absorbMaxHp = UnitHealthMax(unit)
            absorbAmount = UnitGetTotalAbsorbs(unit)
            updateScale = true
        end
    
        if updateScale then
            self:SetMinMaxValues(0, absorbMaxHp)
        end
        self:SetValue(absorbAmount)
    
        if oldAbsorb and absorbMaxHp and (oldAbsorb - absorbAmount) / absorbMaxHp >= private.config.chunkAnimMin then
            self.animChunkFrame:displayChunkAnim(oldAbsorb, absorbAmount, absorbMaxHp)
        end
    end)
    
    return absorb
end