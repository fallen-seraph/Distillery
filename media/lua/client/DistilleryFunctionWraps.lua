local function wrap(class,method,before,after)
    local original = class[method]
    class[method] = function(...)
        if before then before(...) end
        local result = original(...)
        if after then after(...) end
        --if after then result = after(result,...) end
        return result
    end
end

local function patch(class,method,patchFn)
    class[method] = patchFn(class[method])
end

DistilleryUtilities.patchClassMetaMethod(zombie.inventory.types.DrainableComboItem.class,"DoTooltip",DistilleryMenu.DoTooltip_patch)

require "ISUI/ISInventoryPane"
patch(ISInventoryPane,"drawItemDetails",DistilleryMenu.ISInventoryPane_drawItemDetails_patch)

require "Moveables/ISMoveablesAction"
wrap(ISMoveablesAction,"perform",CDistillerySystem.onMoveablesAction,nil)