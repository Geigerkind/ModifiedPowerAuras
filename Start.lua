--------------- Frames and Funktionallity ---------------

function MPOWA:CreateSave(i)
	MPOWA_SAVE[i] = {
		texture = "Interface\\AddOns\\ModifiedPowerAuras\\images\\dummy.tga",
		alpha = 1,
		size = 0.75,
		x = 0,
		y = -30,
		buffname = "",
		isdebuff = false,
		timer = false,
		inverse = false,
		used = false,
		test = false,
		cooldown = false,
		enemytarget = false,
		friendlytarget = false,
		stacks = ">=0",
		targetduration = 0,
		alive = 0,
		mounted = 0,
		incombat = 0,
		inparty = 0,
		inraid = 0,
		inbattleground = 0,
		fontalpha = 1,
		fontoffsetx = 0,
		fontoffsety = 0,
		fontsize = 1.5,
		hundredth = false,
		usefontcolor = false,
		fontcolor_r = 1,
		fontcolor_g = 1,
		fontcolor_b = 1,
		usebeginsound = false,
		beginsound = 1,
		useendsound = false,
		endsound = 1,
		raidgroupmember = false,
		exactname = false,
		flashanim = false,
		flashanimstart = 5,
		unit = "player",
		rgmname = "",
		icon_r = 1,
		icon_b = 1,
		icon_g = 1,
		secsleft = false,
		secsleftdur = 0,
		inraidinstance = 0,
		hidestacks = false,
		secondspecifier = false,
		secondspecifiertext = "",
		animduration = 0.5,
		translateoffsetx = 50,
		translateoffsety = 50,
		fadealpha = 0.99,
		scalefactor = 0.8,
		isdynamicgroup = false,
		groupnumber = 0,
		cpstacks = ">=0",
		dynamicsorted = false,
		dynamiccenter = false,
		dynamicorientation = 1,
		timerfont = 1,
		dynamicspacing = 5,
		blendmode = 1,
		minutes = false,
	}
end

function MPOWA:Init()
	MPowa_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	
	SLASH_MPOWA1 = "/mpowa"
	SlashCmdList["MPOWA"] = function(msg)
		if MPowa_MainFrame:IsVisible() then
			MPowa_MainFrame:Hide()
		else
			self:Show()
		end
	end
	
	if MPOWA_SAVE == nil then
		MPOWA_SAVE = {}
		self:CreateSave(1)
	end
	
	if MPOWA_PROFILE == nil then
		MPOWA_PROFILE = {}
	end
	
	for cat, val in MPOWA_SAVE do
		if val["used"] or (MPOWA_SAVE[cat+1] and MPOWA_SAVE[cat+1]["used"]) then
			if not self.frames[cat] then
				self.frames[cat] = {}
			end
			
			if not self.auras[val["buffname"]] then
				self.auras[val["buffname"]] = {}
			end
			tinsert(self.auras[val["buffname"]], cat)
			
			if val["inverse"] or val["cooldown"] then
				self.NeedUpdate[cat] = true
			end
			
			if val["enemytarget"] or val["friendlytarget"] then
				MPOWA_SAVE[cat]["unit"] = "target"
			else
				MPOWA_SAVE[cat]["unit"] = nil
			end
			
			if val["used"] then
				self.NumBuffs = cat
			end
			
			if val["rgmname"] then
				self.RaidGroupMembers[val["rgmname"]] = true
			end
			
			if not val["secsleftdur"] or val["secsleftdur"] == "" then
				MPOWA_SAVE[cat]["secsleftdur"] = 0
			end
			
			if not val["inraidinstance"] then
				MPOWA_SAVE[cat]["inraidinstance"] = 0
			end

			if not val["secondspecifiertext"] then
				MPOWA_SAVE[cat]["secondspecifiertext"] = ""
			end
			
			-- Initializing animations
			if not val["animduration"] then
				MPOWA_SAVE[cat]["animduration"] = 0.5
			end
			
			if not val["translateoffsetx"] then
				MPOWA_SAVE[cat]["translateoffsetx"] = 50
			end
			
			if not val["translateoffsety"] then
				MPOWA_SAVE[cat]["translateoffsety"] = 50
 			end
			
			if not val["fadealpha"] then
				MPOWA_SAVE[cat]["fadealpha"] = 0.99
			end
			
			if not val["scalefactor"] then
				MPOWA_SAVE[cat]["scalefactor"] = 0.8
			end

			if not val["dynamicorientation"] then
				MPOWA_SAVE[cat]["dynamicorientation"] = 1
			end

			if not val["timerfont"] then
				MPOWA_SAVE[cat]["timerfont"] = 1
			end

			if not val["dynamicspacing"] then
				MPOWA_SAVE[cat]["dynamicspacing"] = 5
			end
			
			if not val["blendmode"] then
				MPOWA_SAVE[cat]["blendmode"] = 1
			end
			
			self:CreateIcon(cat)
			self:ApplyConfig(cat)

			if val["flashanim"] then
				self:AddAnimFlash(cat)
			end
			
			if val["growout"] then
				self:AddAnimGrowOut(cat)
			end
			
			if val["growin"] then
				self:AddAnimGrowIn(cat)
			end
			
			if val["fadeout"] then
				self:AddAnimFadeOut(cat)
			end
			
			if val["fadein"] then
				self:AddAnimFadeIn(cat)
			end
			
			if val["escapeanimout"] then
				self:AddAnimEscapeOut(cat)
			end
			
			if val["escapeanimin"] then
				self:AddAnimEscapeIn(cat)
			end
			
			if val["shrinkanim"] then
				self:AddAnimShrink(cat)
			end
			
			if val["sizeanim"] then
				self:AddAnimSizeIn(cat)
			end
			
			if val["translateanim"] then
				self:AddAnimTranslate(cat)
			end
			
			if val["rotateanimout"] then
				self:AddAnimRotateOut(cat)
			end
			
			if val["rotateanimin"] then
				self:AddAnimRotateIn(cat)
			end
			
			if val["batmananimout"] then
				self:AddAnimRotateShrinkFadeOut(cat)
			end
			
			if val["batmananimin"] then
				self:AddAnimRotateShrinkFadeIn(cat)
			end
			
			if not val["cpstacks"] then
				MPOWA_SAVE[cat]["cpstacks"] = ">=0"
			end

			MPOWA_SAVE[cat]["test"] = false
		else	
			MPOWA_SAVE[cat] = nil
		end
	end
	self.testAll = false
end

--------------- Post Init --------------------------

MPOWA:SetScript("OnUpdate", function() MPOWA:OnUpdate(arg1) end)
MPOWA:SetScript("OnEvent", function() MPOWA:OnEvent(event, arg1) end)
MPOWA:RegisterEvent("VARIABLES_LOADED")
MPOWA:RegisterEvent("UNIT_AURA")
MPOWA:RegisterEvent("PLAYER_TARGET_CHANGED")
MPOWA:RegisterEvent("RAID_ROSTER_UPDATE")
MPOWA:RegisterEvent("PARTY_MEMBERS_CHANGED")
MPOWA:RegisterEvent("PLAYER_AURAS_CHANGED")
MPOWA:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
MPOWA:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
MPOWA:RegisterEvent("PLAYER_REGEN_DISABLED")
MPOWA:RegisterEvent("PLAYER_REGEN_ENABLED")