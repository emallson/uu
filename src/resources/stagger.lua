---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

local FIXED_COLORS = {
    [2] = { r = 0.7, g = 0, b = 0.95, a = 1},
    [3] = { r = 38 / 255, g = 183 / 255, b = 187 / 255, a = 1 }
}

function custom.stagger(parent, unit, stack)
    local staggerContainer = CreateFrame('Frame', parent:GetName() .. 'PowerStagger', parent)

    local baseStaggerColors = PowerBarColor['STAGGER']

    local maxHp = UnitHealthMax(unit)

    local bars = {}
    for i = 1, 3 do
        local bar = CreateFrame('StatusBar', staggerContainer:GetName() .. 'Stagger' .. i, staggerContainer)
        bar:SetAllPoints(staggerContainer)
        bar:SetStatusBarTexture('interface/buttons/white8x8')
        bar:SetFrameLevel(3 + i)

        bar:SetMinMaxValues((i - 1) * maxHp, i * maxHp)
        bar:SetValue(UnitStagger(unit))
        bar:Show()

        if FIXED_COLORS[i] then
            local c = FIXED_COLORS[i]
            bar:SetStatusBarColor(c.r, c.g, c.b, c.a)
        end

        bars[i] = bar
    end

    local function updateVisibility()
        if InCombatLockdown() then
            return
        end
        local specId = C_SpecializationInfo.GetSpecialization()

        if specId == 1 then
            PixelUtil.SetPoint(staggerContainer, 'TOPLEFT', parent, 'BOTTOMLEFT', 0, -1)
            PixelUtil.SetPoint(staggerContainer, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, -3)
        else
            -- TODO: this should unregister events since they aren't implicitly disabled by hiding
            PixelUtil.SetPoint(staggerContainer, 'TOPLEFT', parent, 'BOTTOMLEFT', 0, 0)
            PixelUtil.SetPoint(staggerContainer, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, 0)
        end

        private.util.rescaleBg(stack)
    end

    staggerContainer:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
    staggerContainer:RegisterUnitEvent('UNIT_MAXHEALTH', unit)
    staggerContainer:RegisterUnitEvent('UNIT_HEALTH', unit)
    -- actually no idea how to properly do this. normalized stagger used CLEU. base ui is not much help but it is lumped under power bars so...
    staggerContainer:RegisterUnitEvent('UNIT_POWER_UPDATE', unit)
    staggerContainer:SetScript('OnEvent', function(self, eventType)
        if eventType == 'PLAYER_SPECIALIZATION_CHANGED' then
            updateVisibility()
        elseif eventType == 'UNIT_MAXHEALTH' then
            local maxHp = UnitHealthMax(unit)
            for i, bar in ipairs(bars) do
                bar:SetMinMaxValues((i - 1) * maxHp, i * maxHp)
            end
        elseif eventType == 'UNIT_HEALTH' or eventType == 'UNIT_POWER_UPDATE' then
            for i, bar in ipairs(bars) do
                bar:SetValue(UnitStagger(unit))
                local threshold = UnitStagger(unit) / UnitHealthMax(unit)

                if i == 1 then
                    local color
                    if threshold > STAGGER_STATES.RED.threshold then
                        color = baseStaggerColors[STAGGER_STATES.RED.key]
                    elseif threshold > STAGGER_STATES.YELLOW.threshold then
                        color = baseStaggerColors[STAGGER_STATES.YELLOW.key]
                    else
                        color = baseStaggerColors[STAGGER_STATES.GREEN.key]
                    end

                    bar:SetStatusBarColor(color.r, color.g, color.b, 1)
                end
            end
        end
    end)

    updateVisibility()

    return staggerContainer
end
