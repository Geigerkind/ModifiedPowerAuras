--[[
    Name: Sol
    Revision: $Rev:  $
    $Date:  $
    Author(s): martinjlowm (martin@martinjlowm.dk)
    Git:

    Description:

    Sol reimplements common Lua functions that are only available in Lua
    versions post 5.0. Sol means ``Sun'' in Portuguese, thus this library
    attempts to balance out any shortcomings in the present Lua environment of
    World of Warcraft 1.12.


    Copyright (C) 2016 Martin Jesper Low Madsen

    License:

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2.1 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this library; if not, write to the Free Software Foundation,
    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
--]]


if not LibStub then return end

local Sol = LibStub:NewLibrary('Sol-1.0', 0)
if not Sol then return end

--[[
    Global empty function
--]]
NOOP = function() end


--[[
    Math
--]]
math.modf = math.modf or function(num)
    local int = math.floor(num)
    local frac = math.abs(num) - math.abs(int)

    return int, frac
end

math.fmod = math.fmod or function(x, y)
    return x - math.floor(x / y) * y
end


--[[
    Table and indexing
--]]
string.match = string.match or function(str, pattern)
    local tbl_res = { string.find(str, pattern) }

    if tbl_res[3] then
        return select(3, unpack(tbl_res))
    else
        return tbl_res[1], tbl_res[2]
    end
end

string.gmatch = string.gmatch or function(str, pattern)
    local init = 0

    return function()
        local tbl = { string.find(str, pattern, init) }

        local start_pos = tbl[1]
        local end_pos = tbl[2]

        if start_pos then
            init = end_pos + 1

            if tbl[3] then
                return unpack({select(3, unpack(tbl))})
            else
                return string.sub(str, start_pos, end_pos)
            end
        end
    end
end

string.join = string.join or function(delim, ...)
    if type(arg) == 'table' then
        return table.concat(arg, delim)
    else
        return delim
    end
end

string.split = string.split or function(delim, s, limit)
    local split_string = {}
    local rest = {}

    local i = 1
    for str in string.gfind(s, '([^' .. delim .. ']+)' .. delim .. '?') do
        if limit and i >= limit then
            table.insert(rest, str)
        else
            table.insert(split_string, str)
        end

        i = i + 1
    end

    if limit then
        table.insert(split_string, string.join(delim, unpack(rest)))
    end

    return unpack(split_string)
end

string.trim = string.trim or function(str)
    return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

strjoin = strjoin or string.join


--[[
    Table and indexing
--]]
select = select or function(idx, ...)
    local len = table.getn(arg)

    if type(idx) == 'string' and idx == '#' then
        return len
    else
        local tbl = {}

        for i = idx, len do
            table.insert(tbl, arg[i])
        end

        return unpack(tbl)
    end
end

table.wipe = table.wipe or function(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

wipe = wipe or table.wipe
