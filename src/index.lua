---@class uuPrivate
---@field uuPrivate.frames uuFrames
local private = select(2, ...)

---@class uuFrames
private.frame = {}
---@class uuConfig
private.config = {
    chunkAnimMin = 0.4
}

private.util = {}

function private.util.scale(px)
    -- 768 vertical screen units, spanning GetScreenHeight() pixel units. that means
    -- that 1 screen unit has a size of GetScreenHeight() pixels / 768 screen units = 1 px/su / UIParent:GetEffectiveScale()
    local pxSize = 1 / UIParent:GetEffectiveScale()

    -- normally, the calculation is that we multiply by the parent scale.

end


---@type Frame
local frame = CreateFrame('Frame', 'uu', UIParent)
frame:SetPoint("TOP", UIParent, 'CENTER', 0, -0.125 * GetScreenHeight())
PixelUtil.SetSize(frame, 200, 8)
frame:Show()

local unitFrame = CreateFrame('Button', 'uuUnit', frame, 'SecureUnitButtonTemplate')

unitFrame:RegisterForClicks("AnyUp")
unitFrame:SetAttribute("unit", "player")
unitFrame:SetAttribute("*type1", "target")
unitFrame:SetAttribute("*type2", "togglemenu")

unitFrame:SetAllPoints()


local bg = frame:CreateTexture(frame:GetName() .. 'Background', 'BACKGROUND')
bg:SetTexture('interface/buttons/white8x8')
bg:SetVertexColor(0.2, 0, 0, 1)
PixelUtil.SetPoint(bg, 'TOPLEFT', frame, 'TOPLEFT', -1, 1)
PixelUtil.SetPoint(bg, 'BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)

local resizeHandlers = {}

---@param stack table<number, Frame>
function private.util.rescaleBg(stack)
    local bottom = nil
    local top = nil
    for _, f in ipairs(stack) do
        if f:IsShown() then
            if top == nil then top = f end
            bottom = f
        end
    end
    PixelUtil.SetPoint(bg, 'BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', 1, -1)
    PixelUtil.SetPoint(unitFrame, 'BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', 1, -1)

    for _, handler in ipairs(resizeHandlers) do
        handler(top, bottom)
    end
end

function private.util.addResizeHandler(handler)
    table.insert(resizeHandlers, handler)
end


local function addDefaultResources(stack)
    if select(2, UnitClass("player")) == "PALADIN" then
        table.insert(stack, private.frame.customResources.holyPower(frame, 'player'))
        table.insert(stack, private.frame.customResources.healerOnlyMana(stack[#stack], 'player', stack))
    else
        table.insert(stack, private.frame.simpleResource(frame, 'player'))
    end
end

frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function ()
    local stack = {}
    table.insert(stack, private.frame.health(frame, 'player'))
    addDefaultResources(stack)

    private.frame.absorb(frame, 'player')
    private.frame.healAbsorb(frame, 'player')

    private.util.rescaleBg(stack)
end)

-- todo: target indicator (esp. friendly targets, and targets without nameplates)
-- okay i actually just need a real target frame for now because of target buffs/debuffs