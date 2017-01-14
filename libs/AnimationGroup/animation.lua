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

if AG.Animation then return end
local Animation = AG:New('Animation')

local function OnUpdate(self, elapsed)
    if self.paused then
        return
    end

    self.time = self.time + (self.group.reverse and -elapsed or elapsed)

    if self.time > self.duration or (self.group.reverse and self.time < 0) then
        self:__Finished()
        return
    end

    -- Temporary until all animation types are implemented
    if self.OnUpdate then
        self:OnUpdate(elapsed)
    end
end


--[[
    API
--]]

function Animation:Play()
    self:__Play()
    self.group:__Notify(self, 'Play')
end


function Animation:Pause()
    self.__Pause()
    self.group:__Notify(self, 'Pause')
end


function Animation:Stop()
    self.__Stop()
    self.group:__Notify(self, 'Stop')
end

function Animation:IsDone()
    return not self.playing
end

function Animation:IsPlaying()
    return self.playing
end

function Animation:IsPaused()
    return not self.playing and self.paused
end

function Animation:IsStopped()
    return not self.playing
end

function Animation:IsDelaying()
    return not not self.delay
end

function Animation:GetElapsed()
    return self.time
end

function Animation:SetStartDelay(delay_sec)
    self.delay = delay_sec
end

function Animation:GetStartDelay()
    return self.delay
end

function Animation:SetEndDelay(delay_sec)
end

function Animation:GetEndDelay()
end

function Animation:SetDuration(duration)
    self.duration = duration
end

function Animation:GetDuration()
    return self.duration
end

function Animation:GetProgress()
    return self.progress
end

function Animation:GetSmoothProgress()
end

function Animation:GetProgressWithDelay()
end

function Animation:SetMaxFramerate(framerate)
end

function Animation:GetMaxFramerate()
end

function Animation:SetOrder(order)
    assert(order <= 10, 'How much memory do you have, bro?'
               .. ' (only 10 orders are supported)')
    assert(order >= 0, 'Negative orders are not supported!')

    self.group:__MoveOrder(self, order)

    self.order = order
end

function Animation:GetOrder()
    return self.order
end

function Animation:SetSmoothing(smoothing_type)
    self.smoothing_func = AG.Curves[smoothing_type]
    self.smoothing_type = smoothing_type
end

function Animation:GetSmoothing()
    return self.smooth_type
end

function Animation:GetRegionParent()
    return self.group.parent
end


--[[
    Private
--]]

function Animation:__SetScript(handler, func)
    if self.handlers[handler] then
        self.handlers[handler] = func
    else
        self:_SetScript(handler, func)
    end
end

function Animation:__Finished()
    self:__Stop()
    self.group:__Notify(self, 'Finished')
end

function Animation:__Pause()
    self.paused = true
end

function Animation:__Play()
    if not self.playing and self.group.parent:IsVisible() then
        self.time = self.group.reverse and self.duration or 0
        self.playing = true
        self:SetScript('OnUpdate', function() OnUpdate(this, arg1) end)
    end

    self.paused = false
end

function Animation:__Stop()
    self.time = 0

    if self.OnUpdate then
        self:SetScript('OnUpdate', nil)
    end

    self.playing = false
end
