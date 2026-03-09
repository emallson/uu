---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

-- if at least this many runes are available, the starve bar is not shown
local RUNE_STARVE_THRESHOLD = 1
local RUNE_NEUTRAL_THRESHOLD = 4

-- fixed rune duration, used for configuring bars
local RUNE_DURATION = 10

-- create a status bar that tracks the time til at least `runeCount` runes are available
local function createRuneTimerBar(runeContainer, color, runeCount)
    local bar = CreateFrame('StatusBar', runeContainer:GetName() .. 'Timer' .. runeCount, runeContainer)
    bar:Hide()
    bar:SetAllPoints(runeContainer)

    bar:SetStatusBarTexture('interface/buttons/white8x8')
    bar:SetStatusBarColor(color.r, color.g, color.b)

    ---update the rune timer. if availablerunes > runeCount, the bar is hidden. rune cooldowns are assumed to be sorted in ascending order of end time
    function bar:SetRuneTimer(runeCooldowns, availableRunes)
        if availableRunes >= runeCount then
            self:Hide()
            return
        end

        local delta = runeCount - availableRunes
        local start, cooldown = unpack(runeCooldowns[delta])
        local duration = C_DurationUtil.CreateDuration()
        duration:SetTimeFromEnd(start + cooldown, RUNE_DURATION)
        self:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.RemainingTime)
        self:Show()
    end

    return bar
end


function custom.runeWaste(parent, unit)
    local runeContainer = CreateFrame('Frame', parent:GetName() .. 'PowerRune', parent)
    PixelUtil.SetPoint(runeContainer, 'TOPLEFT', parent, 'BOTTOMLEFT', 0, -1)
    PixelUtil.SetPoint(runeContainer, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, -3)

    local neutralColor = PowerBarColor[Enum.PowerType.Runes]
    local runeStarveColor = { r = 255 / 255, g = 29 / 255, b = 26 / 255 }
    local runeStarveWarningColor = { r = 255 / 255, g = 244.8 / 255, b = 51 / 255 }

    local neutralBar = createRuneTimerBar(runeContainer, neutralColor, RUNE_NEUTRAL_THRESHOLD)
    neutralBar:SetFrameLevel(4)
    local warningBar = createRuneTimerBar(runeContainer, runeStarveWarningColor, RUNE_STARVE_THRESHOLD + 1)
    warningBar:SetFrameLevel(5)
    local starveBar = createRuneTimerBar(runeContainer, runeStarveColor, RUNE_STARVE_THRESHOLD)
    starveBar:SetFrameLevel(6)

    runeContainer:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    runeContainer:RegisterEvent('PLAYER_LOGIN')
    runeContainer:SetScript('OnEvent', function(self, eventType)
        if eventType == 'SPELL_UPDATE_COOLDOWN' or eventType == 'PLAYER_LOGIN' then
            local availableRunes = 0
            local runeCooldowns = {}

            for i = 1, 6 do
                local startTime, cooldownDuration, available = GetRuneCooldown(i)
                if available then
                    availableRunes = availableRunes + 1
                else
                    table.insert(runeCooldowns, { startTime, cooldownDuration })
                end
            end
            
            table.sort(runeCooldowns, function(a, b) return (a[1] + a[2]) < (b[1] + b[2]) end)

            neutralBar:SetRuneTimer(runeCooldowns, availableRunes)
            warningBar:SetRuneTimer(runeCooldowns, availableRunes)
            starveBar:SetRuneTimer(runeCooldowns, availableRunes)
        end
    end)

    return runeContainer
end