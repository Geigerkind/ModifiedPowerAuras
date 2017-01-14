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

if AG.Scale then return end
local Scale = AG:New('Scale', AG.Animation)

function Scale:__Initialize()
    self.origin = {}
    self.origin.point = nil
    self.origin.x = nil
    self.origin.y = nil
    self.scale = {}
    self.scale.x = nil
    self.scale.y = nil
end

function Scale:SetOrigin(point, offset_x, offset_y)
    self.origin.point = point
    self.origin.x = x
    self.origin.y = y
end

function Scale:GetOrigin()
    local origin = self.origin

    return origin.point, origin.x, origin.y
end

function Scale:SetScale(x, y)
    self.scale.x = x
    self.scale.y = y
end

function Scale:GetScale()
    local scale = self.scale

    return scale.x, scale.y
end

function Scale:OnUpdate(elapsed)
    local properties = self.group.properties

    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.group.parent
    frame:SetWidth(properties.width + self.progress * (properties.width * self.scale.x))
    frame:SetHeight(properties.height + self.progress * (properties.height * self.scale.y))
end
