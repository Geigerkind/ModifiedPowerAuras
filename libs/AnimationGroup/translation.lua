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

if AG.Translation then return end
local Translation = AG:New('Translation', AG.Animation)

function Translation:__Initialize()
    self.offset = {}
    self.offset.x = nil
    self.offset.y = nil
end

function Translation:SetOffset(x, y)
    self.offset.x = x
    self.offset.y = y
end

function Translation:GetOffset()
    return self.offset.x, self.offset.y
end

function Translation:OnUpdate(elapsed)
    self.progress = self.smoothing_func(self.time / self.duration).y

    local frame = self.group.parent

    local point = self.group.properties.point

    frame:ClearAllPoints()
    frame:SetPoint(point[1], point[2], point[3],
                   point[4] + self.progress * self.offset.x,
                   point[5] + self.progress * self.offset.y)
end
