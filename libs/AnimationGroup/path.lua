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

if AG.Path then return end
local Path = AG:New('Path', AG.Animation)
Path.curve_type = nil
Path.control_points = {}

function Path:__Initialize()
    assert(nil, 'Animation paths are not yet supported!')
end

-- Adds a new path control point.
function Path:CreateControlPoint(name, template, order)
    local control_point = { name = name,
                            template = template,
                            order = order }
    table.insert(self.control_points, control_points)
end

-- Returns an arg list of current path control points.
function Path:GetControlPoints()
    return unpack(self.control_points)
end

-- Returns the path 'curveType'.
function Path:GetCurve()
    return self.curve_type
end

-- Returns highest 'orderId' currently set for any of the control points .
function Path:GetMaxOrder()
    local highest_order = 0

    for _, point in next, self.control_points do
        if point.order > highest_order then
            highest_order = point.order
        end
    end

    return highest_order
end

-- Sets the path 'curveType'.
function Path:SetCurve(curve_type)
    self.curve_type = curve_type
end
