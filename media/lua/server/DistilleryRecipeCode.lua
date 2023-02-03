function Recipe.OnTest.isSlurryCooked(sourceItem, result)
    if sourceItem:getFullType() == "Biofuel.CornSlurry" then
        return sourceItem:isCooked()
    end
    return true
end

function Recipe.OnTest.PotFull(sourceItem, result)
    if sourceItem:getFullType() == "Biofuel.UnfilteredMoonshinePot" then
        return sourceItem:getUsedDelta() == 1
    end
    return true
end

function Recipe.OnCreate.ConvertToPot(items, result, player)
    player:getInventory():AddItem("Base.Pot")
end

function Recipe.OnCreate.FillKeg(items, result, player)
	for i=0, items:size()-1 do
		local item = items:get(i)
        if item:getType() == "EmptyKeg" then
            result:setUsedDelta(result:getUseDelta() * 4);
            player:getInventory():AddItem("Base.Pot")
        elseif item:getType() == "KegofMoonshine" then
			result:setUsedDelta(item:getUsedDelta() + (item:getUseDelta() * 4));
            player:getInventory():AddItem("Base.Pot")
		end
	end
end

function Recipe.OnTest.KegAmount(sourceItem, result)
    if sourceItem:getFullType() == "Biofuel.KegofBeer" then
        return sourceItem:getUsedDelta() > 0
    end
    return true
end

function Recipe.OnCreate.FillCup(items, result, player)
	for i=0, items:size()-1 do
		local item = items:get(i)
        if item:getType() == "KegofBeer" then
            item:setUsedDelta(item:getUsedDelta() - item:getUseDelta());
            player:getInventory():AddItem(item)
		end
	end
end