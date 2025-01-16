local addonName, private = ...
---@class uuFrames
local frames = private.frame

---comment
---@param parent Frame
---@return Texture
function frames.animatedChunkFrame(parent)
    local tex = parent:CreateTexture(parent:GetName() .. 'ChunkFrame')
    tex:SetDrawLayer("BACKGROUND")

    tex:SetAllPoints()
    tex:SetTexture('interface/buttons/white8x8')
    tex:SetVertexColor(1, 0.115, 0.1, 0.9)
    tex:Hide()

    local chunkAnimGroup = tex:CreateAnimationGroup()
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
    function tex:displayChunkAnim(oldHp, newHp, maxHp)
        chunkAnimGroup:Stop()
        self:SetPoint('TOPLEFT', parent, 'TOPLEFT', parent:GetWidth() * newHp / maxHp, 0)
        self:SetPoint('TOPRIGHT', parent, 'TOPLEFT', parent:GetWidth() * oldHp / maxHp, 0)
        chunkAnimGroup:Restart()
        chunkAnimGroup:Play()
    end

    chunkAnim:SetScript('OnPlay', function()
        tex:Show()
    end)
    chunkAnim:SetScript('OnFinished', function()
        tex:Hide()
    end)
    return tex
end