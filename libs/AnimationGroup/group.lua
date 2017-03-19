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

if AG.AnimationGroup then return end
local AnimationGroup = AG:New('AnimationGroup')

local ORDER_LIMIT = 10

--[[
    API
--]]

function AnimationGroup:Play()
    self:__SaveProperties()

    self.reverse = false
    self.finishing = false
    self.order = 0

    repeat
        self:__Play()

        if not self.playing then
            self.order = self.order + 1
        end
    until self.playing or self.order == (ORDER_LIMIT - 1)

    if self.playing then
        self:__Notify(nil, 'Play')
    end
end

function AnimationGroup:Pause()
    for _, animation in next, self.animations[self.order + 1] do
        animation:__Pause()
    end

    self:__Notify(nil, 'Pause')
end

function AnimationGroup:Stop()
    self:__Stop()
    self:__Notify(nil, 'Stop')
end

function AnimationGroup:Finish()
    self.finishing = true
end

function AnimationGroup:GetProgress()
    local lowest_progress = 1
    local anim_progress

    for _, animation in next, self.animations[self.order + 1] do
        anim_progress = animation.progress
        if anim_progress < lowest_progress then
            lowest_progress = anim_progress
        end
    end

    return lowest_progress
end

function AnimationGroup:IsDone()
    return self.done
end

function AnimationGroup:IsPlaying()
    return self.playing
end

function AnimationGroup:IsPaused()
    return self.playing and self.paused
end

function AnimationGroup:GetDuration()
    return self.duration
end

function AnimationGroup:SetLooping(loop_type)
    self.loop_type = loop_type
end

function AnimationGroup:GetLooping()
    return self.loop_type
end

function AnimationGroup:GetLoopState()
    return self.loop_state
end

function AnimationGroup:CreateAnimation(animation_type, name, inherits_from)
    local animation = AG[animation_type]:Bind(CreateFrame('Frame', name))

    animation.group = self
    animation:SetParent(self)
    animation.type = animation_type
    animation.duration = nil
    animation.progress = nil
    animation.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true
    }

    local default_smoothing = 'LINEAR'
    animation.smoothing_type = default_smoothing
    animation.smoothing_func = AG.Curves[default_smoothing]

    if animation.__Initialize then
        animation:__Initialize()
    end

    animation._SetScript = animation.SetScript
    animation.SetScript = animation.__SetScript

    table.insert(self.animations[1], animation)

    return animation
end


--[[
    Private
--]]

-- Make these functions local
function AnimationGroup:__Initialize(parent)
    self.parent = parent
    self:SetParent(parent)
    self.loop_type = nil
    self.loop_state = nil
    self.duration = nil
    self.playing = nil
    self.paused = nil
    self.done = nil
    self.finishing = false
    self.reverse = nil

    self.handlers = {
        ['OnLoad'] = true,
        ['OnPlay'] = true,
        ['OnPaused'] = true,
        ['OnStop'] = true,
        ['OnFinished'] = true,
        ['OnLoop'] = true
    }

    -- The original implementation claims to support up to 100 orders... yuck!
    -- Lets keep it at 10 for sanity.
    self.animations = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }

    self.properties = {
        alpha = nil,
        width = nil,
        height = nil,
        point = {}
    }

    self._SetScript = self.SetScript
    self.SetScript = self.__SetScript
end

function AnimationGroup:__SetScript(handler, func)
    if self.handlers[handler] then
        self.handlers[handler] = func
    else
        self:_SetScript(handler, func)
    end
end

function AnimationGroup:__SaveProperties()
    self.properties.alpha = self.parent:GetAlpha()
    self.properties.width = self.parent:GetWidth()
    self.properties.height = self.parent:GetHeight()
    self.properties.point = { self.parent:GetPoint() }
end

function AnimationGroup:__LoadProperties()
    self.parent:SetAlpha(self.properties.alpha)
    self.parent:SetWidth(self.properties.width)
    self.parent:SetHeight(self.properties.height)

    local point = self.properties.point
    if point and point[1] then
        local p1 = unpack(point)
        if p1 then
            self.parent:SetPoint(unpack(point))
        end
    end
end

function AnimationGroup:__Play()
    local animations = self.animations[self.order + 1]
	
    if not animations or table.getn(animations) < 1 then
        self.playing = false
        return
    end

    for _, animation in next, animations do
        animation.finished = false
        animation:__Play()
    end
	
    self.playing = true
end

function AnimationGroup:__Stop()
    for _, animation in next, self.animations[self.order + 1] do
        animation:__Stop()
    end

    self:__LoadProperties()

    self.playing = false
end


function AnimationGroup:__MoveOrder(animation, new_order)
    for order, anims in next, self.animations do
        for i, anim in next, anims do
            if anim == animation then
                table.remove(self.animations[order], i)
            end
        end
    end

    -- Zero-indexing, nope
    table.insert(self.animations[new_order + 1], animation)
end

-- TODO: Check shine effect callbacks!
function AnimationGroup:__Notify(animation, signal)
    local group_func, func
	
    -- Allocate table of functions
    func = not animation and {}

    local args = {}

    local all_finished = true
    local bouncing = self.loop_type == 'BOUNCE'

    -- Only animations notify with `FINISHED' signals!
    if signal == 'Finished' then
        animation.finished = true

        for _, anim in next, self.animations[self.order + 1] do
            all_finished = all_finished and anim.finished
        end

        -- Animation: Fires after this Animation finishes playing
        func = animation.handlers['OnFinished']
    elseif signal == 'Stop' then
        table.insert(args, not animation)
    end

    if signal == 'Play' or signal == 'Stop' or signal == 'Pause' then
        group_func = self.handlers['On' .. signal]

        if not animation then
            local handler_func
            for _, anim in next, self.animations[self.order + 1] do
                handler_func = anim.handlers['On' .. signal]
                if type(handler_func) == 'function' then
                    table.insert(func, {anim, handler_func})
                end
            end
        else
            func = animation.handlers['On' .. signal]
        end
    end

    -- Call Animation's callback
    if type(func) == 'function' then
        func(animation, unpack(args))
    elseif type(func) == 'table' then
        for _, f in next, func do
            f[2](f[1], unpack(args))
        end
    end

    local shift

    -- Try the remaining orders
    if (signal == 'Finished' and all_finished) or signal == 'Bounce' then
        if self.shifted then
            if not self.finishing then
                self.reverse = not self.reverse
                self:__Play()
            end
            self.shifted = false
        else
            local first_order, last_order
            repeat
                self.order = self.order + (self.reverse and -1 or 1)

                first_order = self.order == 0
                last_order = self.order == (ORDER_LIMIT - 1)

                shift = (not self.reverse and last_order) or (self.reverse and first_order)

                -- Play next order animations... if they exist!
                self:__Play()
            until self.playing or shift
        end
        -- Repeat the next
        if shift and self.playing then
            self.shifted = true
        end
    end

    -- self.finishing requires the animation to be notified first, thus this
    -- block must be performed AFTER the animation callback and BEFORE the
    -- group's callback
    if (signal == 'Finished' and all_finished and (shift or self.finishing)) then
        if (self.finishing and bouncing) or (not bouncing) then
            self:__Stop()
			
            group_func = self.handlers['OnFinished']
            table.insert(args, self.finishing)
        else
            group_func = self.handlers['OnLoop']

            table.insert(args, self.reverse and 'REVERSE' or 'FORWARD')
        end
    end

    -- We `bounce' if the boundary orders have no animations
    if (not self.playing and shift and
        (not self.finishing) and bouncing) then
        self.reverse = not self.reverse
        self:__Notify(nil, 'Bounce')
    end
	
	-- Call AnimationGroup's callback
    if type(group_func) == 'function' then
        group_func(self, unpack(args))
    end
end
