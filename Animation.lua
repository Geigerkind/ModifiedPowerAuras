local stf = strfind
local _G = getglobal
local tinsert = table.insert
local tremove = table.remove
local UN = UnitName
local strform = string.format
local flr = floor
local strgfind = string.gfind
local strfind = string.find
local GT = GetTime
local tnbr = tonumber

function MPOWA:PlayAnim(condition, key, anim)
	if self.SAVE[key][condition] then
		if self.frames[key][1][anim] and not self.frames[key][1][anim]:IsPlaying() then
			self.frames[key][1][anim]:Play()
		end
	end
end

function MPOWA:FHide(key)
	local p = self.SAVE[key]
	if p and self.frames[key] and self.frames[key][1]:IsVisible() and not self.testall and not p["test"] then
		if p["useendsound"] then
			if p.endsound < 16 then
				PlaySound(self.SOUND[p.endsound], "master")
			else
				PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..self.SOUND[p.endsound], "master")
			end
		end
		if p["batmananimout"] and not self.frames[key][1].batmananimout:IsPlaying() then
			self:PlayAnim("batmananimout", key, "batmananimout")
		elseif p["shrinkanim"] and not self.frames[key][1].translateanim:IsPlaying() 
				and not self.frames[key][1].fadeout:IsPlaying() and not self.frames[key][1].rotateanimout:IsPlaying() 
				and not self.frames[key][1].shrink:IsPlaying() then
			self:PlayAnim("translateanim", key, "translateanim")
			self:PlayAnim("fadeout", key, "fadeout")
			self:PlayAnim("rotateanimout", key, "rotateanimout")
			self:PlayAnim("shrinkanim", key, "shrink")
		else
			if p["growout"] and not self.frames[key][1].fadout:IsPlaying() and not self.frames[key][1].rotateanimout:IsPlaying() 
				and not self.frames[key][1].growout:IsPlaying() then
				self:PlayAnim("fadeout", key, "fadeout")
				self:PlayAnim("rotateanimout", key, "rotateanimout")
				self:PlayAnim("growout", key, "growout")
			elseif p["escapeanimout"] and not self.frames[key][1].rotateanimout:IsPlaying() and not self.frames[key][1].escapeanimout:IsPlaying() then
				self:PlayAnim("rotateanimout", key, "rotateanimout")
				self:PlayAnim("escapeanimout", key, "escapeanimout")
			else
				if p["fadeout"] and not self.frames[key][1].translateanim:IsPlaying() and not self.frames[key][1].rotateanimout:IsPlaying() 
					and not self.frames[key][1].fadeout:IsPlaying() then
					self:PlayAnim("translateanim", key, "translateanim")
					self:PlayAnim("rotateanimout", key, "rotateanimout")
					self:PlayAnim("fadeout", key, "fadeout")
				elseif p["translateanim"] and not self.frames[key][1].rotateanimout:IsPlaying() and not self.frames[key][1].translateanim:IsPlaying() then
					self:PlayAnim("rotateanimout", key, "rotateanimout")
					self:PlayAnim("translateanim", key, "translateanim")
				else
					if self.frames[key][1].flash and self.frames[key][1].flash:IsPlaying() then
						self.frames[key][1].flash:Stop()
						self.frames[key][1]:SetAlpha(tnbr(p["alpha"]))
					end
					if p["rotateanimout"] and not self.frames[key][1].rotateanimout:IsPlaying() then
						self:PlayAnim("rotateanimout", key, "rotateanimout")
					else
						self:AfterAnimationDynamicGroup(key)
						self.frames[key][1]:Hide()
					end
				end
			end
		end
	end
end

function MPOWA:AfterAnimationDynamicGroup(key)
	local p = self.SAVE[key]
	if p["isdynamicgroup"] then
		self:ApplyDynamicGroup(key)
	elseif p["groupnumber"] and tnbr(p["groupnumber"])>0 then
		self:ApplyDynamicGroup(tnbr(p["groupnumber"]))
	end
end

function MPOWA:FShow(key)
	local p = self.SAVE[key]
	if not self.frames[key][1]:IsVisible() and p["used"] then
		if p["usebeginsound"] then
			if p.beginsound < 16 then
				PlaySound(self.SOUND[p.beginsound], "master")
			else
				PlaySoundFile("Interface\\AddOns\\ModifiedPowerAuras\\Sounds\\"..self.SOUND[p.beginsound], "master")
			end
		end
		if p["isdynamicgroup"] then
			self:ApplyDynamicGroup(key)
		elseif p["groupnumber"] and tnbr(p["groupnumber"])>0 then
			self:ApplyDynamicGroup(tnbr(p["groupnumber"]))
		end
		self.frames[key][1]:Show()
		if p["batmananimin"] and not self.frames[key][1].batmananimin:IsPlaying() then
			self:PlayAnim("batmananimin", key, "batmananimin")
		elseif p["sizeanim"] and not self.frames[key][1].fadein:IsPlaying() and not self.frames[key][1].rotateanimin:IsPlaying()
			and not self.frames[key][1].sizein:IsPlaying() then
			self:PlayAnim("fadein", key, "fadein")
			self:PlayAnim("rotateanimin", key, "rotateanimin")
			self:PlayAnim("sizeanim", key, "sizein")
		else
			if p["growin"] and not self.frames[key][1].fadein:IsPlaying() and not self.frames[key][1].rotateanimin:IsPlaying()
				and not self.frames[key][1].growin:IsPlaying() then
				self:PlayAnim("fadein", key, "fadein")
				self:PlayAnim("rotateanimin", key, "rotateanimin")
				self:PlayAnim("growin", key, "growin")
			elseif p["escapeanimin"] and not self.frames[key][1].rotateanimin:IsPlaying() and not self.frames[key][1].escapeanimin:IsPlaying() then
				self:PlayAnim("rotateanimin", key, "rotateanimin")
				self:PlayAnim("escapeanimin", key, "escapeanimin")
			else
				if p["fadein"] and not self.frames[key][1].rotateanimin:IsPlaying() and not self.frames[key][1].fadein:IsPlaying() then
					self:PlayAnim("rotateanimin", key, "rotateanimin")
					self:PlayAnim("fadein", key, "fadein")
				elseif p["rotateanimin"] and not self.frames[key][1].rotateanimin:IsPlaying() then
					self:PlayAnim("rotateanimin", key, "rotateanimin")
				end
			end
		end
	end
end

function MPOWA:Flash(elapsed, cat, timeLeft)
	local s = self.SAVE[cat]
	if s.flashanim and self.frames[cat][1].flash then
		if timeLeft < s.flashanimstart then
			if not self.frames[cat][1].flash:IsPlaying() then
				self.frames[cat][1].flash:Play()
			end
		else
			if self.frames[cat][1].flash:IsPlaying() then
				self.frames[cat][1].flash:Stop()
				self.frames[cat][1]:SetAlpha(s.alpha)
			end
		end
	end
end

function MPOWA:AddAnimFlash(frame)
	if not self.frames[frame][1].flash then
		self.frames[frame][1].flash = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].flash:SetLooping("BOUNCE")
		local anim = self.frames[frame][1].flash:CreateAnimation("Alpha")
		anim:SetChange(-0.99)
		anim:SetDuration(1)
	end
end

function MPOWA:AddAnimGrowOut(frame)
	if not self.frames[frame][1].growout then
		self.frames[frame][1].growout = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].growout:SetLooping("NONE")
		self.frames[frame][1].growout:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].growout:Stop()
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		local scale = self.frames[frame][1].growout:CreateAnimation("Scale")
		scale:SetScale(tnbr(self.SAVE[frame]["scalefactor"]), tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimFadeIn(frame)
	if not self.frames[frame][1].fadein then
		self.frames[frame][1].fadein = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].fadein:SetLooping("NONE")
		self.frames[frame][1].fadein:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].fadein:Stop()
			MPOWA.frames[frame][1]:SetAlpha(tnbr(self.SAVE[frame]["alpha"]))
			MPOWA.frames[frame][1]:Show()
		end)
		
		local anim = self.frames[frame][1].fadein:CreateAnimation("Alpha")
		anim:SetChange(tnbr(self.SAVE[frame]["fadealpha"]))
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimFadeOut(frame)
	if not self.frames[frame][1].fadeout then
		self.frames[frame][1].fadeout = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].fadeout:SetLooping("NONE")
		self.frames[frame][1].fadeout:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].fadeout:Stop()
			MPOWA.frames[frame][1]:SetAlpha(tnbr(self.SAVE[frame]["alpha"]))
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local anim = self.frames[frame][1].fadeout:CreateAnimation("Alpha")
		anim:SetChange(-tnbr(self.SAVE[frame]["fadealpha"]))
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimRotateOut(frame)
	if not self.frames[frame][1].rotateanimout then
		self.frames[frame][1].rotateanimout = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].rotateanimout:SetLooping("NONE")
		self.frames[frame][1].rotateanimout:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].rotateanimout:Stop()
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local anim = self.frames[frame][1].rotateanimout:CreateAnimation("Rotation")
		anim:SetDegrees(360)
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimTranslate(frame)
	if not self.frames[frame][1].translateanim then
		self.frames[frame][1].translateanim = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].translateanim:SetLooping("NONE")
		self.frames[frame][1].translateanim:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].translateanim:Stop()
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local anim = self.frames[frame][1].translateanim:CreateAnimation("Translation")
		anim:SetOffset(tnbr(self.SAVE[frame]["translateoffsetx"]),tnbr(self.SAVE[frame]["translateoffsetx"]))
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimEscapeOut(frame)
	if not self.frames[frame][1].escapeanimout then
		self.frames[frame][1].escapeanimout = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].escapeanimout:SetLooping("BOUNCE")
		self.frames[frame][1].escapeanimout:SetScript("OnLoop", function()
			self.frames[frame][1].escapeanimout:Finish()
		end)
		self.frames[frame][1].escapeanimout:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].escapeanimout:Stop()
			MPOWA.frames[frame][1]:SetAlpha(tnbr(self.SAVE[frame]["alpha"]))
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local alpha = self.frames[frame][1].escapeanimout:CreateAnimation("Alpha")
		alpha:SetChange(-.5)
		alpha:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
		
		local scale = self.frames[frame][1].escapeanimout:CreateAnimation("Scale")
		scale:SetScale(tnbr(self.SAVE[frame]["scalefactor"]), tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimShrink(frame)
	if not self.frames[frame][1].shrink then
		self.frames[frame][1].shrink = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].shrink:SetLooping("NONE")
		self.frames[frame][1].shrink:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].shrink:Stop()
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local scale = self.frames[frame][1].shrink:CreateAnimation("Scale")
		scale:SetScale(-tnbr(self.SAVE[frame]["scalefactor"]), -tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimRotateShrinkFadeOut(frame)
	if not self.frames[frame][1].batmananimout then
		self.frames[frame][1].batmananimout = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].batmananimout:SetLooping("NONE")
		self.frames[frame][1].batmananimout:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].batmananimout:Stop()
			MPOWA.frames[frame][1]:SetAlpha(tnbr(self.SAVE[frame]["alpha"]))
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Hide()
			MPOWA:AfterAnimationDynamicGroup(frame)
		end)
		
		local scale = self.frames[frame][1].batmananimout:CreateAnimation("Scale")
		scale:SetScale(-10, -10)
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
		
		local anim = self.frames[frame][1].batmananimout:CreateAnimation("Rotation")
		anim:SetDegrees(1081)
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
		
		local alpha = self.frames[frame][1].batmananimout:CreateAnimation("Alpha")
		alpha:SetChange(-tnbr(self.SAVE[frame]["fadealpha"]))
		alpha:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimGrowIn(frame)
	if not self.frames[frame][1].growin then
		self.frames[frame][1].growin = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].growin:SetLooping("NONE")
		self.frames[frame][1].growin:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].growin:Stop()
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Show()
		end)
		
		local scale = self.frames[frame][1].growin:CreateAnimation("Scale")
		scale:SetScale(tnbr(self.SAVE[frame]["scalefactor"]), tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimRotateIn(frame)
	if not self.frames[frame][1].rotateanimin then
		self.frames[frame][1].rotateanimin = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].rotateanimin:SetLooping("NONE")
		self.frames[frame][1].rotateanimin:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].rotateanimin:Stop()
			MPOWA.frames[frame][1]:Show()
		end)
		
		local anim = self.frames[frame][1].rotateanimin:CreateAnimation("Rotation")
		anim:SetDegrees(-360)
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimRotateShrinkFadeIn(frame)
	if not self.frames[frame][1].batmananimin then
		self.frames[frame][1].batmananimin = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].batmananimin:SetLooping("BOUNCE")
		self.frames[frame][1].batmananimin:SetScript("OnLoop", function()
			self.frames[frame][1].batmananimin:Finish()
		end)
		self.frames[frame][1].batmananimin:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].batmananimin:Stop()
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Show()
		end)
		
		local scale = self.frames[frame][1].batmananimin:CreateAnimation("Scale")
		scale:SetScale(-10, -10)
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
		
		local anim = self.frames[frame][1].batmananimin:CreateAnimation("Rotation")
		anim:SetDegrees(1080.5)
		anim:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimSizeIn(frame)
	if not self.frames[frame][1].sizein then
		self.frames[frame][1].sizein = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].sizein:SetLooping("BOUNCE")
		self.frames[frame][1].sizein:SetScript("OnLoop", function()
			self.frames[frame][1].sizein:Finish()
		end)
		self.frames[frame][1].sizein:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].sizein:Stop()
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Show()
		end)
		
		local scale = self.frames[frame][1].sizein:CreateAnimation("Scale")
		scale:SetScale(-tnbr(self.SAVE[frame]["scalefactor"]), -tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end

function MPOWA:AddAnimEscapeIn(frame)
	if not self.frames[frame][1].escapeanimin then
		self.frames[frame][1].escapeanimin = self.frames[frame][1]:CreateAnimationGroup()
		self.frames[frame][1].escapeanimin:SetLooping("BOUNCE")
		self.frames[frame][1].escapeanimin:SetScript("OnLoop", function()
			self.frames[frame][1].escapeanimin:Finish()
		end)
		self.frames[frame][1].escapeanimin:SetScript("OnFinished", function() 
			MPOWA.frames[frame][1].escapeanimin:Stop()
			MPOWA.frames[frame][1]:SetAlpha(tnbr(self.SAVE[frame]["alpha"]))
			MPOWA.frames[frame][1]:SetWidth(64)
			MPOWA.frames[frame][1]:SetHeight(64)
			MPOWA.frames[frame][1]:Show()
		end)
		
		local alpha = self.frames[frame][1].escapeanimin:CreateAnimation("Alpha")
		alpha:SetChange(-.5)
		alpha:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
		
		local scale = self.frames[frame][1].escapeanimin:CreateAnimation("Scale")
		scale:SetScale(tnbr(self.SAVE[frame]["scalefactor"]), tnbr(self.SAVE[frame]["scalefactor"]))
		scale:SetDuration(tnbr(self.SAVE[frame]["animduration"]))
	end
end