registerForEvent("onInit", function()
    print("CET:Addicted:onInit")

    Observe('PlayerPuppet', 'OnStatusEffectApplied', function(self, evt)
        print("CET:Addicted:OnStatusEffectApplied")
        local addictive = {}
        addictive[0] = TweakDB:GetRecord("BaseStatusEffect.FirstAidWhiffV0")
        addictive[1] = TweakDB:GetRecord("BaseStatusEffect.BonesMcCoy70V0")
        local effect = evt.staticData:GetID()
        local isAddictive = table.contains(addictive, effect)
        print("CET:Addicted: " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
        if evt.isNewApplication and isAddictive then
            print("CET:Addicted once again: " .. self.consumed)
        end
    end)
    Observe('PlayerPuppet', 'OnStatusEffectRemoved', function (self, evt)
        print("CET:Addicted:OnStatusEffectRemoved " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
    end)
end)

function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

-- local druggedID = TweakDBID.new("BaseStatusEffect.Drugged")
-- if evt.staticData ~= nil then
--     if evt.staticData:UiData() ~= nil then
--         if evt.staticData:UiData():DisplayName() ~= nil then
--             print(GetLocalizedText(evt.staticData:UiData():DisplayName()))
--         else
--             print('no evt.staticData:UiData:DisplayName')
--         end
--     else
--         print('no evt.staticData:UiData')
--     end
-- else print('no evt.staticData') end
-- local r = TweakDBInterface.GetItemRecord(evt.staticData:GetID()):LocalizedName()
-- print(record:GameplayTags())
-- print(record:DebugTags())
-- print(Dump(record, false))
-- print(r)

-- local applied = StatusEffectHelper.GetAppliedEffects(self)
-- for _, n in ipairs(applied) do
--     print("" .. TDBID.ToStringDEBUG(n.statusEffectRecordID))
-- end

-- Observe('PlayerPuppet', 'OnStatusEffectAppliedToxicity', function(self, evt)
--     print("CET:Addicted:OnStatusEffectAppliedToxicity")
--     print("CET:Addicted: " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
--     local applied = StatusEffectHelper.GetAppliedEffects(self)
--     for _, n in ipairs(applied) do
--         print("" .. TDBID.ToStringDEBUG(n.statusEffectRecordID))
--     end
-- end)
