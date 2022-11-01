registerForEvent("onInit", function()
    print("CET:Addicted:onInit")

    Observe('PlayerPuppet', 'OnStatusEffectApplied', function(self, evt)
        print("CET:Addicted:OnStatusEffectApplied")
        local druggedID = TweakDBID.new("BaseStatusEffect.Drugged")
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
        print("CET:Addicted: " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
        local applied = StatusEffectHelper.GetAppliedEffects(self)
        for _, n in ipairs(applied) do
            print("" .. TDBID.ToStringDEBUG(n.statusEffectRecordID))
        end
        if evt.isNewApplication and evt.staticData:GetID() == druggedID then
            self.consumed = self.consumed + 1
            print("CET:Addicted once again: " .. self.consumed)
        end
    end)
    -- Observe('PlayerPuppet', 'OnStatusEffectAppliedToxicity', function(self, evt)
    --     print("CET:Addicted:OnStatusEffectAppliedToxicity")
    --     print("CET:Addicted: " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
    --     local applied = StatusEffectHelper.GetAppliedEffects(self)
    --     for _, n in ipairs(applied) do
    --         print("" .. TDBID.ToStringDEBUG(n.statusEffectRecordID))
    --     end
    -- end)
    Observe('PlayerPuppet', 'OnStatusEffectRemoved', function (self, evt)
        print("CET:Addicted:OnStatusEffectRemoved " .. TDBID.ToStringDEBUG(evt.staticData:GetID()))
    end)
end)
