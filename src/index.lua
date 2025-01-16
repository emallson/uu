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

-- todo heal absorb frame

frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function ()
    local stack = {}
    table.insert(stack, private.frame.health(frame, 'player'))
    table.insert(stack, private.frame.simpleResource(frame, 'player', 0))
    PixelUtil.SetPoint(bg, 'BOTTOMRIGHT', stack[#stack], 'BOTTOMRIGHT', 1, -1)
    PixelUtil.SetPoint(unitFrame, 'BOTTOMRIGHT', stack[#stack], 'BOTTOMRIGHT', 1, -1)

    private.frame.absorb(frame, 'player', stack)
    private.frame.healAbsorb(frame, 'player', stack)
end)

-- todo: target indicator (esp. friendly targets, and targets without nameplates)
-- okay i actually just need a real target frame for now because of target buffs/debuffs