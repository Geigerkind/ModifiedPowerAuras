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

if AG.Curves then return end
local Curves = AG:New('Curves')

local Point = {}

function Point.Add(lhs, rhs)
    return Point:New(lhs.x + rhs.x, lhs.y + rhs.y)
end

function Point.Multiply(lhs, rhs)
    return Point:New(lhs * rhs.x, lhs * rhs.y)
end

local mt = {
    __add = Point.Add,
    __mul = Point.Multiply }

function Point:New(x, y)
    return setmetatable({x = x, y = y}, mt)
end

local function QuadraticBezier(p_0, p_1, p_2)
    return function(t)
        return
            (1 - t) * ((1 - t) * p_0 + t * p_1) +
            t * ((1 - t) * p_1 + t * p_2)
    end
end

local function CubicBezier(p_0, p_1, p_2, p_3)
    return function(t)
        return
            (1 - t) * QuadraticBezier(p_0, p_1, p_2)(t) +
            t * QuadraticBezier(p_1, p_2, p_3)(t)
    end
end

local CubicBezierEaseIn = function()
    local p_0 = Point:New(0, 0)
    local p_1 = Point:New(.5, 0)
    local p_2 = Point:New(1, 1)
    local p_3 = p_2

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local CubicBezierEaseOut = function()
    local p_0 = Point:New(0, 0)
    local p_1 = p_0
    local p_2 = Point:New(.5, 1)
    local p_3 = Point:New(1, 1)

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local CubicBezierEaseInOut = function()
    local p_0 = Point:New(0, 0)
    local p_1 = Point:New(.5, 0)
    local p_2 = Point:New(.5, 1)
    local p_3 = Point:New(1, 1)

    return CubicBezier(p_0, p_1, p_2, p_3)
end

local Linear = function(t)
    return {x = 0, y = t}
end

Curves.curves = {
    ['IN'] = CubicBezierEaseIn(),
    ['OUT'] = CubicBezierEaseOut(),
    ['INOUT'] = CubicBezierEaseInOut(),
    ['OUTIN'] = CubicBezierEaseInOut(),
    ['LINEAR'] = Linear
}

setmetatable(Curves, {__index = Curves.curves })
