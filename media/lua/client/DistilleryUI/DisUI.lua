DistilleryMenu = DistilleryMenu or {}
DistilleryMenu._index = DistilleryMenu

local rGood, gGood, bGood = 0,1,0
local rBad, gBad, bBad = 0,1,0
local richGood, richBad, richNeutral = " <RGB:0,1,0> ", " <RGB:1,0,0> ", " <RGB:1,1,1> "

if getCore().getGoodHighlitedColor then
	local good = getCore():getGoodHighlitedColor()
	local bad = getCore():getBadHighlitedColor()
	rGood, gGood, bGood, rBad, gBad, bBad = good:getR(), good:getG(), good:getB(), bad:getR(), bad:getG(), bad:getB()
	richGood, richBad = string.format(" <RGB:%.2f,%.2f,%.2f> ",rGood, gGood, bGood), string.format(" <RGB:%.2f,%.2f,%.2f> ",rBad, gBad, bBad)
end

local function activateDistillery (worlobjects,player,distillery,activate)
	local character = getSpecificPlayer(player)
	if luautils.walkAdj(character, distillery:getSquare(), true) then
		ISTimedActionQueue.add(DisActivateDistillery:new(character, distillery, activate))
	end
end

local function addInput (worlobjects,player,distillery,item)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, distillery:getSquare(), true) then
			ISTimedActionQueue.add(DisAddInput:new(character, distillery, item))
		end
end

local function distillEthanol (worlobjects,player,distillery)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, distillery:getSquare(), true) then
			ISTimedActionQueue.add(DisdistillEthanol:new(character, distillery))
		end
end


local function drainMoonshine (worlobjects,player,distillery,pot)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, distillery:getSquare(), true) then
			ISTimedActionQueue.add(DisdrainMoonshine:new(character, distillery, pot))
		end
end

local function drainGas (worlobjects,player,distillery,gasCan)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, distillery:getSquare(), true) then
			ISTimedActionQueue.add(DisDrainGas:new(character, distillery, gasCan))
		end
end

DistilleryMenu.createMenuEntries = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end

	local distillery

	for _,obj in ipairs(worldobjects) do
		local spritename = obj:getSprite() and obj:getSprite():getName()
		if spritename == "distillery_tileset_01_0" then
			distillery = obj
		end
	end

	if distillery then
		local square = distillery:getSquare()
		if test then return ISWorldObjectContextMenu.setTest() end
		local DistilleryMainMenu = context:addOption(getText("ContextMenu_Distillery_Distillery"), worldobjects);
		local DistillerySubMenu = ISContextMenu:getNew(context);
		context:addSubMenu(DistilleryMainMenu, DistillerySubMenu);

		if test then return ISWorldObjectContextMenu.setTest() end
		DistillerySubMenu:addOption(getText("ContextMenu_Distillery_DistilleryStatus"), worldobjects, DistilleryWindow.OnOpenPanel, square, player)

		local data = distillery:getModData()
		local playerObj = getSpecificPlayer(player)
		local playerInv = playerObj:getInventory()

		if data["input"] >= SandboxVars.Distillery.maxTankAmount then
			if ( getWorld():isHydroPowerOn() and not square:isOutside() ) or square:haveElectricity() then
				local textOn = data["active"] and getText("ContextMenu_Turn_Off") or getText("ContextMenu_Turn_On")

				if test then return ISWorldObjectContextMenu.setTest() end
				DistillerySubMenu:addOption(textOn, worldobjects, activateDistillery, player, distillery, not data["active"])
			end
		end
		
		if data["input"] == 0 and data["tank"] == 0 then
			local moonshineMash = playerInv:getItemFromType("MoonshineMash")
			
			if moonshineMash ~= nil then
				if test then return ISWorldObjectContextMenu.setTest() end
				DistillerySubMenu:addOption(getText("ContextMenu_Distillery_AddMash"), worldobjects, addInput, player, distillery, moonshineMash)
			end
		end

		if data["tank"] >= SandboxVars.Distillery.maxTankAmount and data["mode"] == "moonshine" then
			if test then return ISWorldObjectContextMenu.setTest() end
			DistillerySubMenu:addOption(getText("ContextMenu_Distillery_DistillEthanol"), worldobjects, distillEthanol, player, distillery)

			local pot = playerInv:getItemFromType("Base.Pot")

			if pot ~= nil then
				if test then return ISWorldObjectContextMenu.setTest() end
				DistillerySubMenu:addOption(getText("ContextMenu_Distillery_DrainMoonshine"), worldobjects, drainMoonshine, player, distillery, pot)
			end
		end
	
		if data["tank"] > 0 and data["mode"] == "ethanol" then
			local gasCan = DistilleryUtilities.getGasCan(playerObj)

			if gasCan ~= nil then
				if test then return ISWorldObjectContextMenu.setTest() end
				DistillerySubMenu:addOption(getText("ContextMenu_Distillery_DrainGas"), worldobjects, drainGas, player, distillery, gasCan)
			end
		end
	end
end

function DistilleryMenu.getRGB()
	return rGood, gGood, bGood, rBad, gBad, bBad
end

function DistilleryMenu.getRGBRich()
	return richGood, richBad, richNeutral
end

DistilleryFixedGetText = function(getTextString)
	local text = getText(getTextString)
	text = string.gsub(text, '\\n', '\n')
	return text
end


function DistilleryMenu.ISInventoryPane_drawItemDetails_patch(drawItemDetails)
	return function(self,item, y, xoff, yoff, red)
		if not item then return end
			local hdrHgt = self.headerHgt
			local top = hdrHgt + y * self.itemHgt + yoff
			local fgBar = {r=0.69, g=0.69, b=0.1, a=1}
			if getCore().getGoodHighlitedColor then --41.78+
				local NewColorInfo = ColorInfo:new()
				getCore():getBadHighlitedColor():interp(getCore():getGoodHighlitedColor(), item:getCondition()/100, NewColorInfo)
				fgBar = {r=NewColorInfo:getR(),g=NewColorInfo:getG(),b=NewColorInfo:getB(),a=1}
			end
			local fgText = {r=0.6, g=0.8, b=0.5, a=0.6}
			if red then fgText = {r=0.0, g=0.0, b=0.5, a=0.7} end
			self:drawTextAndProgressBar(getText("Tooltip_weapon_Condition") .. ":", item:getCondition()/100, xoff, top, fgText, fgBar)
		--end
	end
end


function DistilleryMenu.DoTooltip_patch(DoTooltip)
	return function(item,tooltip)
			local lineHeight = tooltip:getLineSpacing()
			local font = tooltip:getFont()
			local y = 5
			--tooltip:render()
			tooltip:DrawText(font, item:getName(), 5, 5, 1, 1, 0.8, 1)
			y = y + lineHeight + 5
			--adjustWidth(5, name;
			local layout = tooltip:beginLayout()
			--setminwidth
			local option
			if tooltip:getWeightOfStack() > 0 then
				option = layout:addItem()
				option:setLabel(getText("Tooltip_item_StackWeight")..":",1,1,0.8,1)
				option:setValueRightNoPlus(tooltip:getWeightOfStack())
			else
				option = layout:addItem()
				option:setLabel(getText("Tooltip_item_Weight")..":",1,1,0.8,1)
				if item:isEquipped() or item:getAttachedSlot() > -1 then
					option:setValue(string.format("%.2f    (%.2f %s) ",item:getEquippedWeight(),item:getUnequippedWeight(),getText("Tooltip_item_Unequipped")),1,1,0.8,1)
				else
					option:setValue(string.format("%.2f    (%.2f %s) ",item:getUnequippedWeight(),item:getEquippedWeight(),getText("Tooltip_item_Equipped")),1,1,0.8,1)
				end
				option = layout:addItem()
				option:setLabel(getText("IGUI_invpanel_Remaining")..":",1,1,0.8,1)
				option:setValue(string.format("%d%%",item:getUsedDelta()*100),1,1,0.8,1)
				option = layout:addItem()
				option:setLabel(getText("Tooltip_weapon_Condition")..":",1,1,0.8,1)
				option:setValue(string.format("%d%%",item:getCondition()),1,1,0.8,1)
				option = layout:addItem()
				option:setLabel(getText("Tooltip_container_Capacity")..":",1,1,0.8,1)
				--option:setValue(string.format("%d / %d",max * (1 - math.pow((1 - (item:getCondition()/100)),6)),max),1,1,0.8,1)
			end
			y = layout:render(5,y,tooltip)
			tooltip:endLayout(layout)
			--tooltip:setWidth(tooltip:getWidth())
			tooltip:setHeight(y+5)
		--end
	end
end

--Events.OnPreFillWorldObjectContextMenu.Add(OnPreFillWorldObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(DistilleryMenu.createMenuEntries)