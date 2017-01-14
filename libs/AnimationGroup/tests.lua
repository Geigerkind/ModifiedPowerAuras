--[[

    Copyright (c) 2016 Martin Jesper Low Madsen <martin@martinjlowm.dk>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

--]]

if not LibStub then return end

local AG = LibStub:GetLibrary('AnimationGroup-1.0')
if not AG then return end

local tests = {}

local frame = CreateFrame('Frame')
local tex
local ag

local Setup = function()
    frame = CreateFrame('Frame')
    frame:SetWidth(128)
    frame:SetHeight(128)
    frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)

    tex = frame:CreateTexture('ARTWORK')
    tex:SetAllPoints(frame)
    tex:SetBlendMode('ADD')
    frame:Show()

    ag = frame:CreateAnimationGroup()
    ag:SetLooping('BOUNCE')
end

local TranslationScaleRotationAlphaAnimation = function()
    frame:ClearAllPoints()
    frame:SetPoint('CENTER', UIParent, 'CENTER', 200, 0)

    tex:SetTexture('Interface\\Icons\\Ability_Warrior_WarCry')

    local translation = ag:CreateAnimation('Translation')
    translation:SetOffset(100, 100)
    translation:SetDuration(1)
    translation:SetSmoothing('OUT')

    local scale = ag:CreateAnimation('Scale')
    scale:SetScale(.5, .5)
    scale:SetDuration(1)
    scale:SetSmoothing('OUT')

    local rotation = ag:CreateAnimation('Rotation')
    rotation:SetDegrees(90)
    rotation:SetDuration(2)
    rotation:SetSmoothing('INOUT')

    local alpha = ag:CreateAnimation('Alpha')
    alpha:SetChange(-0.9)
    alpha:SetDuration(3)
    alpha:SetSmoothing('OUT')

    ag:Play()
end
table.insert(tests, Setup)
table.insert(tests, TranslationScaleRotationAlphaAnimation)

local NewScaleAnimation = function()
    frame:ClearAllPoints()
    frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 250)

    tex:SetTexture('Interface\\Icons\\INV_Misc_Pelt_Bear_Ruin_02')

    local scale = ag:CreateAnimation('Scale')
    scale:SetScale(-2, -2)
    scale:SetDuration(2.5)
    scale:SetSmoothing('OUT')

    ag:Play()
end
table.insert(tests, Setup)
table.insert(tests, NewScaleAnimation)

local OrderAnimations = function()
    frame:ClearAllPoints()
    frame:SetPoint('CENTER', UIParent, 'CENTER', -150, 0)

    tex:SetTexture('Interface\\Icons\\Spell_Holy_InnerFire')

    local scale = ag:CreateAnimation('Scale')
    scale:SetScale(1.5, 1.5)
    scale:SetDuration(1)
    scale:SetSmoothing('OUT')
    scale:SetOrder(0)

    local rotation = ag:CreateAnimation('Rotation')
    rotation:SetDegrees(180)
    rotation:SetDuration(1)
    rotation:SetSmoothing('OUT')
    rotation:SetOrder(1)

    local alpha = ag:CreateAnimation('Alpha')
    alpha:SetChange(-0.5)
    alpha:SetDuration(1)
    alpha:SetSmoothing('OUT')
    alpha:SetOrder(2)

    ag:Play()
end
table.insert(tests, Setup)
table.insert(tests, OrderAnimations)

local function OnEvent()
    for _, test in next, tests do
        test()
    end
    tests = nil
end

frame:RegisterEvent('UPDATE_INSTANCE_INFO')
frame:SetScript('OnEvent', OnEvent)
