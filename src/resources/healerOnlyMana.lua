---@class uuPrivate
local private = select(2, ...)

---@class uuCustomResources
local custom = private.frame.customResources

function custom.healerOnlyMana(parent, unit, stack)
    local specChangeFrame = CreateFrame('Frame')
    local interior = private.frame.simpleResource(parent, unit, Enum.PowerType.Mana)
    specChangeFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
    local function updateVisibility()
        local specId = GetSpecialization()
        if specId == nil then
            -- very low level character
            interior:Hide()
            return
        end

        local role = select(5, GetSpecializationInfo(specId))
        if role ~= "HEALER" then
            interior:Hide()
        else
            interior:Show()
        end

        private.util.rescaleBg(stack)
    end
    specChangeFrame:SetScript('OnEvent', updateVisibility)

    updateVisibility()
    return interior
end