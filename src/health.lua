local addonName, private = ...

---@class uuFrames
local frames = private.frame

function frames.health(parent, unit)
    local hp = CreateFrame('StatusBar', parent:GetName() .. 'Health', parent)
    hp:SetPoint('TOPLEFT', parent, "TOPLEFT")
    hp:SetPoint('BOTTOMLEFT', parent, 'BOTTOMLEFT')
    PixelUtil.SetWidth(hp, parent:GetWidth())

    hp:SetStatusBarTexture('interface/buttons/white8x8')
    hp:SetStatusBarColor(216 / 255, 208 / 255, 211 / 255, 1)
    hp:Show()
    hp:SetMinMaxValues(0, 100)
    hp:SetValue(100)
    hp:SetFrameLevel(100)

    hp:RegisterUnitEvent("UNIT_HEALTH", unit)
    hp:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    -- TODO: do i need the max hp modifiers changed event?
    hp:RegisterEvent('PLAYER_ENTERING_WORLD')

    local reducedMaxHpTexture = hp:CreateTexture(nil, 'OVERLAY')
    reducedMaxHpTexture:SetPoint('TOPLEFT', hp, 'TOPRIGHT')
    reducedMaxHpTexture:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT')
    reducedMaxHpTexture:Hide()
    reducedMaxHpTexture:SetTexture('interface/buttons/white8x8')
    reducedMaxHpTexture:SetVertexColor(0.25 * 216 / 255, 0.25 * 208 / 255, 0.25 * 211 / 255, 1)

    local bg = hp:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints()
    bg:SetTexture('interface/buttons/white8x8')
    bg:SetVertexColor(0.25, 0, 0.02, 0.9)
    bg:SetDrawLayer('BACKGROUND', -8)

    hp.animChunkFrame = frames.animatedChunkFrame(hp)
    hp.animChunkFrame:SetFrameLevel(100)

    local maxHp, currentHp = nil, nil
    hp:SetScript("OnEvent", function(self, eventType)
        local updateScale = false
        if eventType == 'UNIT_HEALTH' or eventType == 'PLAYER_ENTERING_WORLD' then
            if maxHp == nil then
                updateScale = true
                maxHp = UnitHealthMax(unit)
            end
            currentHp = UnitHealth(unit)
        elseif eventType == 'UNIT_MAXHEALTH' then
            maxHp = UnitHealthMax(unit)
            currentHp = UnitHealth(unit)
            updateScale = true
        end

        local maxHpPctReduction = GetUnitTotalModifiedMaxHealthPercent(unit)
        maxHpPctReduction = Clamp(maxHpPctReduction, 0, 1)
        PixelUtil.SetWidth(self, parent:GetWidth() * (1 - maxHpPctReduction))

        if maxHpPctReduction > 0 then
            reducedMaxHpTexture:Show()
        else
            reducedMaxHpTexture:Hide()
        end

        if updateScale then
            self:SetMinMaxValues(0, maxHp)
            hp.animChunkFrame:SetMinMaxValues(0, maxHp)
        end
        self:SetValue(currentHp)

        hp.animChunkFrame:update(currentHp)
    end)
    return hp
end
