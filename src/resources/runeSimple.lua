---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

function custom.runeSimple(parent, unit)
    local runeContainer = CreateFrame('Frame', parent:GetName() .. 'PowerRune', parent)
    PixelUtil.SetPoint(runeContainer, 'TOPLEFT', parent, 'BOTTOMLEFT', 0, -1)
    PixelUtil.SetPoint(runeContainer, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, -3)

    local color = PowerBarColor[Enum.PowerType.Runes]
    local runeBars = {}
    for i = 1, 6 do
        runeBars[i] = CreateFrame('StatusBar', runeContainer:GetName() .. i, runeContainer)
        runeBars[i]:SetStatusBarTexture('interface/buttons/white8x8')
        runeBars[i]:SetStatusBarColor(color.r, color.g, color.b)
        runeBars[i]:Show()

        if i ~= 6 then
            local tickMark = runeBars[i]:CreateTexture(runeBars[i]:GetName() .. 'Tick', 'OVERLAY')
            tickMark:SetTexture('interface/buttons/white8x8')
            tickMark:SetVertexColor(0, 0, 0, 1)
            PixelUtil.SetPoint(tickMark, 'TOPLEFT', runeBars[i], 'TOPRIGHT', -1, 0)
            PixelUtil.SetPoint(tickMark, 'BOTTOMRIGHT', runeBars[i], 'BOTTOMRIGHT', 0, 0)
        end
        
        if i == 1 then
            PixelUtil.SetPoint(runeBars[i], 'TOPLEFT', runeContainer, 'TOPLEFT', 0, 0)
            PixelUtil.SetPoint(runeBars[i], 'BOTTOMRIGHT', runeContainer, 'BOTTOMLEFT', runeContainer:GetWidth() / 6, 0)
        else
            local reference = runeBars[i - 1]
            PixelUtil.SetPoint(runeBars[i], 'TOPLEFT', reference, 'TOPRIGHT', 0, 0)
            PixelUtil.SetPoint(runeBars[i], 'BOTTOMRIGHT', reference, 'BOTTOMRIGHT', runeContainer:GetWidth() / 6, 0)
        end
    end

    runeContainer:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    runeContainer:SetScript('OnEvent', function(self, eventType)
        if eventType == 'SPELL_UPDATE_COOLDOWN' then
            for i = 1, 6 do
                local startTime, cooldownDuration, available = GetRuneCooldown(i)
                if available then
                    runeBars[i]:SetMinMaxValues(0, 1)
                    runeBars[i]:SetValue(1)
                else
                    local duration = C_DurationUtil.CreateDuration()
                    duration:SetTimeFromStart(startTime, cooldownDuration)
                    runeBars[i]:SetTimerDuration(duration)
                end
            end
        end
    end)

    return runeContainer
end