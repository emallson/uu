local addonName, private = ...

---@class uuFrames
local frames = private.frame

function frames.health(parent, unit)
    local hp = CreateFrame('StatusBar', parent:GetName() .. 'Health', parent)
    hp:SetAllPoints()
    hp:SetStatusBarTexture('interface/buttons/white8x8')
    hp:SetStatusBarColor(216 / 255, 208 / 255, 211 / 255, 1)
    hp:Show()
    hp:SetMinMaxValues(0, 100)
    hp:SetValue(100)
    hp:SetFrameLevel(100)

    hp:RegisterUnitEvent("UNIT_HEALTH", unit)
    hp:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    hp:RegisterEvent('PLAYER_ENTERING_WORLD')

    local bg = hp:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints()
    bg:SetTexture('interface/buttons/white8x8')
    bg:SetVertexColor(0.25, 0, 0.02, 0.9)
    bg:SetDrawLayer('BACKGROUND', -8)

    hp.animChunkFrame = frames.animatedChunkFrame(hp)
    hp.animChunkFrame:SetFrameLevel(100)

    local maxHp, currentHp = nil, nil
    hp:SetScript("OnEvent", function(self, eventType)
        local oldHp = currentHp
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

        if updateScale then
            self:SetMinMaxValues(0, maxHp)
            hp.animChunkFrame:SetMinMaxValues(0, maxHp)
        end
        self:SetValue(currentHp)

        hp.animChunkFrame:update(currentHp)
    end)
    return hp
end
