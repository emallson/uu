local addonName, private = ...
---@class uuFrames
local frames = private.frame

---comment
---@param parent Frame
---@return StatusBar
function frames.animatedChunkFrame(parent)
    local animFrame = CreateFrame('StatusBar', parent:GetName() .. 'ChunkFrame')
    animFrame:Show()

    animFrame:SetAllPoints(parent)
    animFrame:SetPoint('RIGHT', parent, 'RIGHT', -1, 0)
    animFrame:SetStatusBarTexture('interface/buttons/white8x8')
    animFrame:SetStatusBarColor(1, 0.115, 0.1, 0.9)
    
    ---comment
    ---@param self StatusBar
    function animFrame:update(value)
        self:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
    end
    return animFrame
end