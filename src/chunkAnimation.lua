local addonName, private = ...
---@class uuFrames
local frames = private.frame

---comment
---@param parent Frame
---@return Texture
function frames.animatedChunkFrame(parent)
    local frame = parent:CreateTexture(parent:GetName() .. 'ChunkFrame')

    frame:SetAllPoints()
    frame:SetTexture('interface/buttons/white8x8')
    frame:SetVertexColor(1, 0.115, 0.1, 0.9)
    frame:Hide()

    local chunkAnimGroup = frame:CreateAnimationGroup()
    chunkAnimGroup:SetLooping('NONE')
    local chunkAnim = chunkAnimGroup:CreateAnimation('Scale')
    chunkAnim:SetOrigin('LEFT', 0, 0)
    chunkAnim:SetScaleFrom(1, 1)
    chunkAnim:SetScaleTo(0, 1)
    chunkAnim:SetDuration(0.2)
    chunkAnim:SetSmoothing("OUT")

    ---comment
    ---@param self Texture
    ---@param oldHp number
    ---@param newHp number
    ---@param maxHp number
    function frame:displayChunkAnim(oldHp, newHp, maxHp)
        chunkAnimGroup:Stop()
        self:SetPoint('TOPLEFT', parent, 'TOPLEFT', parent:GetWidth() * newHp / maxHp, 0)
        self:SetPoint('TOPRIGHT', parent, 'TOPLEFT', parent:GetWidth() * oldHp / maxHp, 0)
        chunkAnimGroup:Restart()
        chunkAnimGroup:Play()
    end

    chunkAnim:SetScript('OnPlay', function()
        frame:Show()
    end)
    chunkAnim:SetScript('OnFinished', function()
        frame:Hide()
    end)
    return frame
end