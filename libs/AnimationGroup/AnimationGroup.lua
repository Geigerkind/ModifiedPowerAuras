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

local MAJOR_VERSION, MINOR_VERSION = 'AnimationGroup-1.0', '$Format:%ct-%h$'

-- Probably not a release
if not string.find(MINOR_VERSION, '%d+') then MINOR_VERSION = 0 end

local AG = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not AG then return end

local Classy = LibStub('Classy-1.0')

function AG:New(name, parent)
    self[name] = Classy:New('Frame', parent)

    return self[name]
end

local function CreateAnimationGroup(self, name, inherits_from)
    local ag = AG.AnimationGroup:Bind(CreateFrame('Frame'))

    ag:__Initialize(self)

    return ag
end

local _CreateFrame = CreateFrame
function CreateFrame(...)
    local frame = _CreateFrame(unpack(arg))

    frame.CreateAnimationGroup = CreateAnimationGroup

    return frame
end
