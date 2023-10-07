module Possessed

import Codeware.*
import Possessed.GimmickComponent

public class System extends ScriptableSystem {
    private let entities: ref<DynamicEntitySystem>;
    private let callbacks: wref<CallbackSystem>;

    private func OnAttach() {
        this.callbacks = GameInstance.GetCallbackSystem();
        this.callbacks.RegisterCallback(n"Entity/Assemble", this, n"OnEntityAssemble");
        
        this.entities = GameInstance.GetDynamicEntitySystem();
    }

    private cb func OnEntityAssemble(event: ref<EntityLifecycleEvent>) {
        let entity = event.GetEntity();

        if this.IsPlayerTemplate(entity.GetTemplatePath()) {
            let puppet = entity as PlayerPuppet;
            puppet.AddComponent(new GimmickComponent());
            puppet.AddTag(n"Possessed");

            this.callbacks.UnregisterCallback(n"Entity/Assemble", this);
        }
    }

    private func IsPlayerTemplate(path: ResRef) -> Bool {
        if path == r"base\\characters\\entities\\player\\player_ma_fpp.ent"
        || path == r"base\\characters\\entities\\player\\player_fa_fpp.ent" {
            return true;
        }
        return false;
    }

    public func GetGimmick() -> ref<GimmickComponent> {
        return new GimmickComponent();
    }
}